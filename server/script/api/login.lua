-- api/login.lua

local log_err   = logger.err
local log_debug = logger.debug
local serialize = logger.serialize
local apidoer   = utility.apidoer

local mongod    = nucleus.mongod

--定义接口
local login_doers = {
    GET = function(req, args)
        log_debug("/login GET params: %s", serialize(args))
        local res = mongod:find_one("users", args)
        if not res then
            log_err("/login %s mongo query failed", args.username)
            return { code = -1, msg = "mongo query failed" }
        end
        return { code = 0 }
    end,
    POST = function(req, args)
        log_debug("/login params: %s", serialize(args))
        return { code = 0 }
    end,
    PUT = function(req, args)
        log_debug("/login PUT params: %s", serialize(args))
        local res = mongod:find_one("users", {username=args.username})
        if res then
            return {code = -2}
        end
        args.type = "costom"
        res = mongod:insert("users", {args})
        if not res then
            log_err("/login PUT mongod:insert failed")
            return { code = -1 }
        end

        return { code = 0 }
    end,
    DELETE = function(req, args)
        log_debug("/login params: %s", serialize(args))
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, login_doers)

