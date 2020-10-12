-- api/databases.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db

--定义接口
local databases_doers = {
    GET = function(req, params, session)
        log_debug("/databases GET params: %s", serialize(params))
        local res = proj_db:find("databases", {}, {_id = 0})
        local records = {}
        for k, db in pairs(res) do
            tinsert(records, db)
        end
        return { code = 0, data = records, total = #records }
    end,
    POST = function(req, params, session)
        log_debug("/databases POST params: %s", serialize(params))
        local database = params.args
        local res = proj_db:find_one("databases", { name = database.name })
        if res and res.id ~= database.id then
            return { code = -1, msg = "database name aready exist!" }
        end
        local record = proj_db:find_one("databases", {id = database.id})
        if not record then
            return {code = -1, msg = "database not exist"}
        end
        local ok, err = proj_db:update("databases", database, { id = database.id })
        if not ok then
            return {code = -1, msg = sformat("db update failed: %s", err)}
        end
        return { code = 0, data = database }
    end,
    PUT = function(req, params, session)
        log_debug("/databases PUT params: %s", serialize(params))
        local database = params.args
        local res = proj_db:find_one("databases", { name = database.name })
        if res then
            return { code = -1, msg = "database name aready exist!" }
        end
        local ok, err = proj_db:insert("databases", { database })
        if not ok then
            return { code = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { code = 0, data = database }
    end,
    DELETE = function(req, params, session)
        log_debug("/databases DELETE params: %s", serialize(params))
        local databases = params.args
        if type(databases) == "string" then
            local ok, err = proj_db:delete("databases", { id = databases })
            if not ok then
                return {code = -1, msg = sformat("db delete failed: %s", err)}
            end
        else
            for _, did in pairs(databases) do
                local ok, err = proj_db:delete("databases", { id = did })
                if not ok then
                    return {code = -1, msg = sformat("db delete failed: %s", err)}
                end
            end
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, databases_doers)

