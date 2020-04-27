-- api/login.lua

local log_err   = logger.err
local log_debug = logger.debug
local serialize = logger.serialize
local apidoer   = utility.apidoer

local mongod    = nucleus.mongod

--定义接口
local login_doers = {
    GET = function(req)
        local args = req.get_uri_args()
        log_debug("/login params: %s", serialize(args))
        local res = mongod:find_one("users", args)
        if not res then
            log_err("/login %s mongo query failed: %s", args.username, res)
            return { code = -1 }
        end
        return { code = 0 }
    end,
    POST = function(req)
        req.read_body()
        --解析 body 参数之前一定要先read_body
        local args = req.get_post_args()
        log_debug("/login params: %s", serialize(args))
        return { code = 0 }
    end,
    PUT = function(req)
        local args = req.get_uri_args()
        log_debug("/login params: %s", serialize(args))
        return { code = 0 }
    end,
    DELETE = function(req)
        local args = req.get_uri_args()
        log_debug("/login params: %s", serialize(args))
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, login_doers)

