--utility.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local log_err   = logger.err
local jencode   = json.encode
local jdecode   = json.decode

utility = {}
utility.apidoer = function(req, doers)
    local url = ngx.var.uri
    local method = req.get_method()
    local func = doers[method]
    if func then
        local args
        if method == "POST" then
            --解析body 参数之前一定要先read_body
            req.read_body()
            --先按照json格式解析
            args = jdecode(req.get_body_data())
            if not args then
                --如果不是json格式，那么使用标准解析
                args = req.get_post_args()
            end
        else
            args = req.get_uri_args()
        end
        local ok, res = pcall(func, req, args)
        if not ok then
            log_err("[utility][apidoer] url(%s) doer failed: %s", url, res)
            return ngx.say(jencode({ code = -1, msg = res }))
        end
        json.encode_empty_table_as_object(false)
        local eok, eres = pcall(jencode, res)
        if not eok then
            log_err("[utility][apidoer] url(%s) jencode failed : %s", url, eres)
            return ngx.say(jencode({ code = -1, msg = eres }))
        end
        return ngx.say(eres)
    end
    ngx.say(jencode({ code = 501 }))
end

