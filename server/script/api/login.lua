-- api/login.lua

local log_err   = logger.err
local log_debug = logger.debug
local serialize = logger.serialize
local apidoer   = utility.apidoer

local admin_db  = nucleus.admin_db

--定义接口
local login_doers = {
    GET = function(req, params, session)
        log_debug("/login GET params: %s", serialize(params))
        local res = admin_db:find_one("users", params)
        if not res then
            log_err("/login %s mongo query failed", params.username)
            return { code = -1, msg = "mongo query failed" }
        end
        return { code = 0 }
    end,
    POST = function(req, params, session)
        log_debug("/login params: %s", serialize(params))
        return { code = 0 }
    end,
    PUT = function(req, params, session)
        log_debug("/login PUT params: %s", serialize(params))
        local res = admin_db:find_one("users", {username=params.username})
        if res then
            return {code = -2}
        end
        params.type = "costom"
        res = admin_db:insert("users", {params})
        if not res then
            log_err("/login PUT admin_db:insert failed")
            return { code = -1 }
        end

        return { code = 0 }
    end,
    DELETE = function(req, params, session)
        log_debug("/login params: %s", serialize(params))
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, login_doers)

