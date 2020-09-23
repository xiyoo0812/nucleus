-- api/user.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local jdecode   = json.decode
local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize
local packuser  = data_pack.user

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db

--定义接口
local user_doers = {
    GET = function(req, params, session)
        log_debug("/user GET params: %s", serialize(params))
        local res = proj_db:find("users", {})
        local records = {}
        for k, v in pairs(res) do
            tinsert(records, packuser(v))
        end
        return { code = 0, data = records, total = #records }
    end,
    POST = function(req, params, session)
        log_debug("/user POST params: %s", serialize(params))
        local user = jdecode(params.args)
        local record = proj_db:find_one("users", {en_name = user.en_name})
        if not record then
            return {code = -1, msg = "user not exist"}
        end
        local ok, err = proj_db:update("users", user, {en_name = user.en_name})
        if not ok then
            return {code = -1, msg = sformat("db update failed: %s", err)}
        end
        return { code = 0, data = user }
    end,
    DELETE = function(req, params, session)
        log_debug("/user DELETE params: %s", serialize(params))
        local users = params.args
        if type(users) == "string" then
            users = { users }
        end
        for _, en_name in pairs(users) do
            local ok, err = proj_db:delete("users", {en_name = en_name })
            if not ok then
                return {code = -1, msg = sformat("db delete failed: %s", err)}
            end
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, user_doers)

