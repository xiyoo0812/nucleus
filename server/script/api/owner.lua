-- api/owner.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local tinsert   = table.insert
local log_debug = logger.debug
local serialize = logger.serialize
local packproj  = data_pack.project
local jdecode   = json.decode

local apidoer   = utility.apidoer
local admin_db  = nucleus.admin_db

--定义接口
local owner_doers = {
    GET = function(req, params, session)
        log_debug("/owner GET params: %s", serialize(params))
        local projects = {}
        local res = admin_db:find("user_projs", {user_name = params.key})
        for _, uproj in pairs(res) do
            local proj = admin_db:find_one("projects", {id = uproj.proj_id})
            if proj then
                tinsert(projects, packproj(proj))
                if not session.data.project then
                    --缓存user到session
                    session.data.project = proj
                    session:save()
                end
            end
        end
        return { code = 0, data = projects, total = #projects }
    end,
    POST = function(req, params, session)
        log_debug("/owner POST params: %s", serialize(params))
        local user = session.data.user
        local args = jdecode(params.args)
        local res = admin_db:find_one("user_projs", {user_name = user.en_name, proj_id = args.proj_id})
        for _, uproj in pairs(res) do
            local proj = admin_db:find_one("projects", {id = uproj.proj_id})
            if proj then
                --缓存user到session
                session.data.project = proj
                session:save()
                return { code = 0, data = proj }
            end
        end
        return { code = -1, msg = "choosed project not exist" }
    end,
}

--执行
apidoer(ngx.req, owner_doers)

