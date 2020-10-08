-- api/authkeys.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local jdecode   = json.decode
local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db

--定义接口
local authkeys_doers = {
    GET = function(req, args)
        log_debug("/authkeys GET params: %s", serialize(args))
        local res = proj_db:find("authkeys", {}, {_id = 0})
        local records = {}
        for k, key in pairs(res) do
            tinsert(records, key)
        end
        return { authkey = 0, data = records, total = #records }
    end,
    POST = function(req, args)
        log_debug("/authkeys POST params: %s", serialize(args))
        local authkey = jdecode(args.authkey)
        local record = proj_db:find_one("authkeys", {name = authkey.name})
        if not record then
            return {authkey = -1, msg = "authkey not exist"}
        end
        local ok, err = proj_db:update("authkeys", authkey, { name = authkey.name })
        if not ok then
            return {authkey = -1, msg = sformat("db update failed: %s", err)}
        end
        return { authkey = 0, data = authkey }
    end,
    PUT = function(req, args)
        log_debug("/authkeys PUT params: %s", serialize(args))
        local authkey = jdecode(args.authkey)
        local res = proj_db:find_one("authkeys", { name = authkey.name })
        if res then
            return { authkey = -1, msg = "name aready exist!" }
        end
        local ok, err = proj_db:insert("authkeys", { authkey })
        if not ok then
            return { authkey = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { authkey = 0, data = authkey }
    end,
    DELETE = function(req, args)
        log_debug("/authkeys DELETE params: %s", serialize(args))
        local authkeys = args.authkeys
        if type(authkeys) == "string" then
            local ok, err = proj_db:delete("authkeys", { name = authkeys })
            if not ok then
                return {authkey = -1, msg = sformat("db delete failed: %s", err)}
            end
        else
            for _, cname in pairs(authkeys) do
                local ok, err = proj_db:delete("authkeys", { name = cname })
                if not ok then
                    return {authkey = -1, msg = sformat("db delete failed: %s", err)}
                end
            end
        end
        return { authkey = 0 }
    end,
}

--执行
apidoer(ngx.req, authkeys_doers)

