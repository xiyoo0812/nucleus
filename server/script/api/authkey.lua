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
local mongod    = nucleus.mongod

--定义接口
local authkey_doers = {
    GET = function(req, args)
        log_debug("/authkey GET params: %s", serialize(args))
        local res = mongod:find("authkeys", {})
        local records = {}
        for k, v in pairs(res) do
            tinsert(records, packikey(v))
        end
        return { authkey = 0, data = records, total = #records }
    end,
    POST = function(req, args)
        log_debug("/authkey POST params: %s", serialize(args))
        local name = args.name
        local db_project = mongod:find_one("authkeys", {name = name})
        if not db_project then
            return {authkey = -1, msg = "authkey not exist"}
        end
        db_project.authkeys = args.authkeys
        local ok, err = mongod:update("authkeys", db_project, { name = name })
        if not ok then
            return {authkey = -1, msg = sformat("db update failed: %s", err)}
        end
        return { authkey = 0, data = db_project.authkeys }
    end,
    PUT = function(req, args)
        log_debug("/authkey PUT params: %s", serialize(args))
        local authkey = jdecode(args.authkey)
        local res = mongod:find_one("authkeys", { name = authkey.name })
        if res then
            return { authkey = -1, msg = "name aready exist!" }
        end
        local ok, err = mongod:insert("authkeys", { authkey })
        if not ok then
            return { authkey = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { authkey = 0, data = authkey }
    end,
    DELETE = function(req, args)
        log_debug("/authkey DELETE params: %s", serialize(args))
        local authkeys = args.authkeys
        if type(authkeys) == "string" then
            local ok, err = mongod:delete("authkeys", { name = authkeys })
            if not ok then
                return {authkey = -1, msg = sformat("db delete failed: %s", err)}
            end
        else
            for _, cname in pairs(authkeys) do
                local ok, err = mongod:delete("authkeys", { name = cname })
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

