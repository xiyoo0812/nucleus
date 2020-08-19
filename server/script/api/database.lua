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
local mongod    = nucleus.mongod

--定义接口
local database_doers = {
    GET = function(req, args)
        log_debug("/database GET params: %s", serialize(args))
        local res = mongod:find("databases", {})
        local records = {}
        for k, v in pairs(res) do
            tinsert(records, packdb(v))
        end
        return { database = 0, data = records, total = #records }
    end,
    POST = function(req, args)
        log_debug("/database POST params: %s", serialize(args))
        local name = args.name
        local db_project = mongod:find_one("databases", {name = name})
        if not db_project then
            return {database = -1, msg = "database not exist"}
        end
        db_project.databases = args.databases
        local ok, err = mongod:update("databases", db_project, { name = name })
        if not ok then
            return {database = -1, msg = sformat("db update failed: %s", err)}
        end
        return { database = 0, data = db_project.databases }
    end,
    PUT = function(req, args)
        log_debug("/database PUT params: %s", serialize(args))
        local database = jdecode(args.database)
        local res = mongod:find_one("databases", { name = database.name })
        if res then
            return { database = -1, msg = "name aready exist!" }
        end
        local ok, err = mongod:insert("databases", { database })
        if not ok then
            return { database = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { database = 0, data = database }
    end,
    DELETE = function(req, args)
        log_debug("/database DELETE params: %s", serialize(args))
        local databases = args.databases
        if type(databases) == "string" then
            local ok, err = mongod:delete("databases", { name = databases })
            if not ok then
                return {database = -1, msg = sformat("db delete failed: %s", err)}
            end
        else
            for _, cname in pairs(databases) do
                local ok, err = mongod:delete("databases", { name = cname })
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

