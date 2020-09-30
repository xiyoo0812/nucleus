-- api/owns.lua
local tinsert   = table.insert
local log_debug = logger.debug
local serialize = logger.serialize
local packproj  = data_pack.project

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db
local admin_db  = nucleus.admin_db

--定义接口
local owns_doers = {
    GET = function(req, params, session)
        --获取用户拥有的项目
        log_debug("/owns GET params: %s", serialize(params))
        local projects = {}
        local res = admin_db:find("member_projs", {en_name = params.key})
        for _, uproj in pairs(res) do
            local proj = admin_db:find_one("projects", {id = uproj.proj_id})
            if proj then
                tinsert(projects, packproj(proj))
                if not session.data.project then
                    --缓存project到session
                    session.data.project = proj
                    proj_db:set_db("nucleus_" .. proj.id)
                    session:save()
                end
            end
        end
        return { code = 0, data = projects }
    end,
    POST = function(req, params, session)
        --选择当前项目
        log_debug("/owns POST params: %s", serialize(params))
        local args = params.args
        local user = session.data.user
        local res = admin_db:find_one("member_projs", {en_name = user.en_name, proj_id = args.proj_id})
        if res then
            local proj = admin_db:find_one("projects", {id = res.proj_id})
            if proj then
                --缓存user到session
                session.data.project = proj
                session.data.admin = res.admin_db
                session:save()
                proj_db:set_db("nucleus_" .. proj.id)
                return { code = 0, data = packproj(proj) }
            end
        end
        return { code = -1, msg = "choosed project not exist" }
    end,
}

--执行
apidoer(ngx.req, owns_doers)

