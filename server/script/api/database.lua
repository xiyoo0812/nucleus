-- api/database.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local jdecode   = json.decode
local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize
local packdb    = data_pack.database

local apidoer   = utility.apidoer
local admin_db  = nucleus.admin_db

--定义接口
local database_doers = {
    GET = function(req, args)
        log_debug("/database GET params: %s", serialize(args))
        local res = admin_db:find("databases", {})
        local records = {}
        for k, v in pairs(res) do
            tinsert(records, packdb(v))
        end
        return { database = 0, data = records, total = #records }
    end,
    POST = function(req, args)
        log_debug("/database POST params: %s", serialize(args))
        local database = jdecode(args.database)
        local record = admin_db:find_one("databases", {name = database.name})
        if not record then
            return {database = -1, msg = "database not exist"}
        end
        local ok, err = admin_db:update("databases", database, { name = database.name })
        if not ok then
            return {database = -1, msg = sformat("db update failed: %s", err)}
        end
        return { database = 0, data = database }
    end,
    PUT = function(req, args)
        log_debug("/database PUT params: %s", serialize(args))
        local database = jdecode(args.database)
        local res = admin_db:find_one("databases", { name = database.name })
        if res then
            return { database = -1, msg = "name aready exist!" }
        end
        local ok, err = admin_db:insert("databases", { database })
        if not ok then
            return { database = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { database = 0, data = database }
    end,
    DELETE = function(req, args)
        log_debug("/database DELETE params: %s", serialize(args))
        local databases = args.databases
        if type(databases) == "string" then
            local ok, err = admin_db:delete("databases", { name = databases })
            if not ok then
                return {database = -1, msg = sformat("db delete failed: %s", err)}
            end
        else
            for _, cname in pairs(databases) do
                local ok, err = admin_db:delete("databases", { name = cname })
                if not ok then
                    return {database = -1, msg = sformat("db delete failed: %s", err)}
                end
            end
        end
        return { database = 0 }
    end,
}

--执行
apidoer(ngx.req, database_doers)

