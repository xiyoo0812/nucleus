-- api/menus.lua
local menus = require "config.menus"

local log_debug = logger.debug
local serialize = logger.serialize
local apidoer   = utility.apidoer

--定义接口
local menus_doers = {
    GET = function(req)
        local args = req.get_uri_args()
        log_debug("/menus params: %s", serialize(args))
        return { menus = menus }
    end,
}

--执行
apidoer(ngx.req, menus_doers)