-- controller/menus.lua
local json  = require "cjson"
local menus = require "config.menus"

local jencode   = json.encode

local log_debug = logger.debug
local serialize = logger.serialize

local args = ngx.req.get_uri_args()
log_debug("/menus params: %s", serialize(args))

ngx.say(jencode({ menus = menus }))
