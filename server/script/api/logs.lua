-- api/logs.lua
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db

--定义接口
local logs_doers = {
    GET = function(req, params, session)
        --获取用户拥有的项目
        log_debug("/logs GET params: %s", serialize(params))
        local query = {}
        --local tick = os.time() - 86400
        --local query = { time = { ["$gt"] = tick }}
        local logs = proj_db:find("logs", query, {_id = 0})
        return { code = 0, data = logs }
    end,
}

--执行
apidoer(ngx.req, logs_doers)

