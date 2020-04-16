-- controller/login.lualocal bson = require "bson"
--ocal bson = require "bson"

local log_err   = logger.err
local log_debug = logger.debug
local serialize = logger.serialize

local mongo_mgr = nucleus.mongo_mgr

local args = ngx.req.get_uri_args()
log_debug("/login params: %s", serialize(args))


local code, res = mongo_mgr:mongo_find_one(1, "users", args)
if code ~= 0 then
    log_debug("/login %s mongo query failed: %s", args.username, res)
    ngx.say('{ "code" : -1 }')
    return
end
log_debug("/login res: %s", res.username)

ngx.say('{ "code" : 0 }')

--解析 body 参数之前一定要先读取 body
--[[
ngx.req.read_body() 
local arg = ngx.req.get_post_args()
]]
