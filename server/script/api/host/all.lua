-- controller/test/test.lua
local json  = require "cjson"
local jencode   = json.encode

ngx.say(jencode({ hosts = {}, code = 0 }))
