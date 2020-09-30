--utility.lua
local json      = require "cjson.safe"
local session   = require("resty.session")
json.encode_sparse_array(true)

local log_err   = logger.err
local jencode   = json.encode
local jdecode   = json.decode
local traceback = debug.traceback

utility = {}
utility.apidoer = function(req, doers)
    local url = ngx.var.uri
    local method = req.get_method()
    local func = doers[method]
    if func then
        local params
        if method == "POST" then
            --解析body 参数之前一定要先read_body
            req.read_body()
            --先按照json格式解析
            params = jdecode(req.get_body_data())
            if not params then
                --如果不是json格式，那么使用标准解析
                params = req.get_post_args()
            end
        else
            params = req.get_uri_args()
            if type(params.args) == "string" then
                --如果是json格式，尝试先解码
                local jargs = jdecode(params.args)
                if jargs then
                    params.args = jargs
                end
            end
        end
        local cur_session = session.start()
        local ok, res = xpcall(func, traceback, req, params, cur_session)
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

utility.add_log = function(proj_db, en_name, log)
    local log_info = {
        log = log,
        name = en_name,
        time = os.time(),
    }
    proj_db:insert("logs", { log_info })
end

