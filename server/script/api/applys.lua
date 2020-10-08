-- api/apply.lua
local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db
local admin_db  = nucleus.admin_db

--定义接口
local apply_doers = {
    GET = function(req, params, session)
        --获取项目申请列表
        log_debug("/apply GET params: %s", serialize(params))
        local records = {}
        local res = proj_db:find("applys", {}, {_id = 0})
        for k, mem in pairs(res) do
            tinsert(records, mem)
        end
        return { code = 0, data = records, total = #records }
    end,
    POST = function(req, params, session)
        --批准申请
        log_debug("/apply POST params: %s", serialize(params))
        local apply = params.args
        local record = proj_db:find_one("applys", {en_name = apply.en_name})
        if not record then
            return {code = -1, msg = "apply not exist"}
        end
        local ok, err = proj_db:delete("applys", {en_name = apply.en_name })
        if not ok then
            return {code = -1, msg = sformat("db update failed: %s", err)}
        end
        if apply.sure then
            local project = session.data.project
            local ok1, err1 = admin_db:insert("member_projs", { {en_name = apply.en_name, proj_id = project.id } })
            if not ok1 then
                return { code = -1, msg = sformat("member_projs insert failed:%s", err1)}
            end
            local ok2, err2 = proj_db:insert("members", { apply })
            if not ok2 then
                return { code = -1, msg = sformat("members insert failed:%s", err2)}
            end
        end
        return { code = 0, data = apply }
    end,
    PUT = function(req, params, session)
        --申请项目权限
        log_debug("/project PUT params: %s", serialize(params))
        local apply_info = params.args
        local record = proj_db:find_one("applys", {en_name = apply_info.en_name})
        if record then
            return {code = -1, msg = "applys is exist"}
        end
        local record2 = proj_db:find_one("members", {en_name = apply_info.en_name})
        if record2 then
            return {code = -1, msg = "members not exist"}
        end
        local apply = session.data.user
        local ok1, err1 = admin_db:insert("applys", { apply })
        if not ok1 then
            return { code = -1, msg = sformat("applys insert failed:%s", err1)}
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, apply_doers)

