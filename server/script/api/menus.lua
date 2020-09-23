-- api/menus.lua
local menus = require "config.menus"

local log_debug = logger.debug
local serialize = logger.serialize
local apidoer   = utility.apidoer

--定义接口
local menus_doers = {
    GET = function(req, params, session)
        log_debug("/menus params: %s", serialize(params))
        return { code = 0, menus = menus }
    end,
}

--执行
apidoer(ngx.req, menus_doers)