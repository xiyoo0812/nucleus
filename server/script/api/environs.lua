-- api/environs.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db

--定义接口
local environs_doers = {
    GET = function(req, params, session)
        log_debug("/environs GET params: %s", serialize(params))
        local res = proj_db:find("environs", {}, {_id = 0})
        local records = {}
        for k, db in pairs(res) do
            tinsert(records, db)
        end
        return { code = 0, data = records, total = #records }
    end,
    POST = function(req, params, session)
        log_debug("/environs POST params: %s", serialize(params))
        local environ = params.args
        local res = proj_db:find_one("environs", { name = environ.name })
        if res and res.id ~= environ.id then
            return { code = -1, msg = "environ name aready exist!" }
        end
        local record = proj_db:find_one("environs", {id = environ.id})
        if not record then
            return {code = -1, msg = "environ not exist"}
        end
        local ok, err = proj_db:update("environs", environ, { id = environ.id })
        if not ok then
            return {code = -1, msg = sformat("db update failed: %s", err)}
        end
        return { code = 0, data = environ }
    end,
    PUT = function(req, params, session)
        log_debug("/environs PUT params: %s", serialize(params))
        local environ = params.args
        local res = proj_db:find_one("environs", { name = environ.name })
        if res then
            return { code = -1, msg = "environ name aready exist!" }
        end
        local ok, err = proj_db:insert("environs", { environ })
        if not ok then
            return { code = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { code = 0, data = environ }
    end,
    DELETE = function(req, params, session)
        log_debug("/environs DELETE params: %s", serialize(params))
        local dbid = params.args
        local ok, err = proj_db:delete("environs", { id = dbid })
        if not ok then
            return {code = -1, msg = sformat("db delete failed: %s", err)}
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, environs_doers)

