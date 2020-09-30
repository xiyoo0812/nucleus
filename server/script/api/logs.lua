-- api/logs.lua
local tinsert   = table.insert
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db

--定义接口
local logs_doers = {
    GET = function(req, params, session)
        --获取用户拥有的项目
        log_debug("/logs GET params: %s", serialize(params))
        local logs = {}
        local tick = os.time() - 86400
        local db_res = proj_db:find("logs", { time = { ["$lt"] = tick }}, {_id = 0})
        for _, log in pairs(db_res) do
            tinsert(logs, log)
        end
        return { code = 0, data = logs }
    end,
}

--执行
apidoer(ngx.req, logs_doers)

