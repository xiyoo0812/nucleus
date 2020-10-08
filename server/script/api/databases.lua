-- api/databases.lua
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
local database_doers = {
    GET = function(req, args)
        log_debug("/databases GET params: %s", serialize(args))
        local res = proj_db:find("databases", {}, {_id = 0})
        local records = {}
        for k, db in pairs(res) do
            tinsert(records, db)
        end
        return { database = 0, data = records, total = #records }
    end,
    POST = function(req, args)
        log_debug("/databases POST params: %s", serialize(args))
        local database = jdecode(args.database)
        local record = proj_db:find_one("databases", {name = database.name})
        if not record then
            return {database = -1, msg = "database not exist"}
        end
        local ok, err = proj_db:update("databases", database, { name = database.name })
        if not ok then
            return {database = -1, msg = sformat("db update failed: %s", err)}
        end
        return { database = 0, data = database }
    end,
    PUT = function(req, args)
        log_debug("/databases PUT params: %s", serialize(args))
        local database = jdecode(args.database)
        local res = proj_db:find_one("databases", { name = database.name })
        if res then
            return { database = -1, msg = "name aready exist!" }
        end
        local ok, err = proj_db:insert("databases", { database })
        if not ok then
            return { database = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { database = 0, data = database }
    end,
    DELETE = function(req, args)
        log_debug("/databases DELETE params: %s", serialize(args))
        local databases = args.databases
        if type(databases) == "string" then
            local ok, err = proj_db:delete("databases", { name = databases })
            if not ok then
                return {database = -1, msg = sformat("db delete failed: %s", err)}
            end
        else
            for _, cname in pairs(databases) do
                local ok, err = proj_db:delete("databases", { name = cname })
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

