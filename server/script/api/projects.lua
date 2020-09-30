-- api/projects.lua
local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize
local packproj  = data_pack.project
local add_log   = utility.add_log

local apidoer   = utility.apidoer
local admin_db  = nucleus.admin_db
local proj_db   = nucleus.proj_db

--定义接口
local projects_doers = {
    GET = function(req, params, session)
        --获取所有项目
        log_debug("/projects GET params: %s", serialize(params))
        local res = admin_db:find("projects", {})
        local records = {}
        for k, v in pairs(res) do
            tinsert(records, packproj(v))
        end
        return { code = 0, data = records, total = #records }
    end,
    POST = function(req, params, session)
        --修改项目内容
        log_debug("/projects POST params: %s", serialize(params))
        local project = params.args
        local record = admin_db:find_one("projects", {name = project.name})
        if not record then
            return {code = -1, msg = "project not exist"}
        end
        local ok, err = admin_db:update("projects", project, { name = project.name })
        if not ok then
            return {code = -1, msg = sformat("projects update failed: %s", err)}
        end
        return { code = 0, data = project }
    end,
    PUT = function(req, params, session)
        --新建项目
        log_debug("/projects PUT params: %s", serialize(params))
        local project = params.args
        local member = session.data.user
        project.creator = member.en_name
        --查询是否重复
        local res = admin_db:find_one("projects", { name = project.name })
        if res then
            return { code = -1, msg = "name aready exist!" }
        end
        local proj_info = {
            admin = true,
            proj_id = project.id,
            en_name = member.en_name,
        }
        --插入用户和项目关系
        local ok1, err1 = admin_db:insert("member_projs", { proj_info })
        if not ok1 then
            return { code = -1, msg = sformat("member_projs insert failed:%s", err1)}
        end
        --插入项目
        local ok2, err2 = admin_db:insert("projects", { project })
        if not ok2 then
            return { code = -1, msg = sformat("project insert failed:%s", err2)}
        end
        local old_db = proj_db:get_db()
        proj_db:set_db("nucleus_" .. project.id)
        --插入成员信息
        local ok3, err3 = proj_db:insert("members", { member })
        if not ok3 then
            proj_db:set_db(old_db)
            return { code = -1, msg = sformat("members insert failed:%s", err3)}
        end
        --添加日志
        add_log(proj_db, member.en_name, sformat("创建了项目：%s", project.name))
        proj_db:set_db(old_db)
        return { code = 0, data = project }
    end,
    DELETE = function(req, params, session)
        --删除项目
        log_debug("/projects DELETE params: %s", serialize(params))
        local project = params.args
        --删除project数据
        local ok1, err1 = admin_db:delete("projects", { id = project })
        if not ok1 then
            return {code = -1, msg = sformat("projects delete failed: %s", err1)}
        end
        --删除用户和项目关系
        local ok2, err2 = admin_db:delete("member_projs", { proj_id = project })
        if not ok2 then
            return { code = -1, msg = sformat("member_projs delete failed:%s", err2)}
        end
        --删除project数据库
        local old_db = proj_db:get_db()
        proj_db:set_db("nucleus_" .. project)
        proj_db:drop()
        proj_db:set_db(old_db)
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, projects_doers)

