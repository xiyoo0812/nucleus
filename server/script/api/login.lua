-- controller/login.lua
local json = require "cjson"

local log_err   = logger.err
local log_debug = logger.debug
local serialize = logger.serialize
local jencode   = json.encode

local mongod    = nucleus.mongod

local args = ngx.req.get_uri_args()
log_debug("/login params: %s", serialize(args))

local res = mongod:find_one("users", args)
if not res then
    log_err("/login %s mongo query failed: %s", args.username, res)
    ngx.say(jencode({ code = -1 }))
    return
end
log_debug("/login res: %s", res.username)

ngx.say(jencode({ code = 0 }))

--解析 body 参数之前一定要先读取 body
--[[
ngx.req.read_body()
local arg = ngx.req.get_post_args()
]]
