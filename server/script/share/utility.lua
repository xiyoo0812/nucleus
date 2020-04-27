--utility.lua
local json = require "cjson"

local jencode   = json.encode

utility = {}
utility.apidoer = function(req, doers)
    local method = req.get_method()
    local func = doers[method]
    if func then
        ngx.say(jencode(func(req)))
        return
    end
    ngx.say(jencode({ code = 501 }))
end

