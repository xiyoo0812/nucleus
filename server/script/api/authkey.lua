-- api/authkey.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local jdecode   = json.decode
local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize
local packikey  = data_pack.authkey

local apidoer   = utility.apidoer
local admin_db  = nucleus.admin_db

--定义接口
local authkey_doers = {
    GET = function(req, args)
        log_debug("/authkey GET params: %s", serialize(args))
        local res = admin_db:find("authkeys", {})
        local records = {}
        for k, v in pairs(res) do
            tinsert(records, packikey(v))
        end
        return { authkey = 0, data = records, total = #records }
    end,
    POST = function(req, args)
        log_debug("/authkey POST params: %s", serialize(args))
        local authkey = jdecode(args.authkey)
        local record = admin_db:find_one("authkeys", {name = authkey.name})
        if not record then
            return {authkey = -1, msg = "authkey not exist"}
        end
        local ok, err = admin_db:update("authkeys", authkey, { name = authkey.name })
        if not ok then
            return {authkey = -1, msg = sformat("db update failed: %s", err)}
        end
        return { authkey = 0, data = authkey }
    end,
    PUT = function(req, args)
        log_debug("/authkey PUT params: %s", serialize(args))
        local authkey = jdecode(args.authkey)
        local res = admin_db:find_one("authkeys", { name = authkey.name })
        if res then
            return { authkey = -1, msg = "name aready exist!" }
        end
        local ok, err = admin_db:insert("authkeys", { authkey })
        if not ok then
            return { authkey = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { authkey = 0, data = authkey }
    end,
    DELETE = function(req, args)
        log_debug("/authkey DELETE params: %s", serialize(args))
        local authkeys = args.authkeys
        if type(authkeys) == "string" then
            local ok, err = admin_db:delete("authkeys", { name = authkeys })
            if not ok then
                return {authkey = -1, msg = sformat("db delete failed: %s", err)}
            end
        else
            for _, cname in pairs(authkeys) do
                local ok, err = admin_db:delete("authkeys", { name = cname })
                if not ok then
                    return {authkey = -1, msg = sformat("db delete failed: %s", err)}
                end
            end
        end
        return { authkey = 0 }
    end,
}

--执行
apidoer(ngx.req, authkey_doers)

