-- api/feishu.lua
local http      = require("resty.http")

local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local mongod    = nucleus.mongod

local feishu_url = "http://ex.idreamsky.com:40008/userInfo"

--定义接口
local feishu_doers = {
    GET = function(req)
        local args = req.get_uri_args()
        log_debug("/feishu params: %s", serialize(args))
        local httpc = http.new()
        local check_url = sformat("%s?ticket=%s", feishu_url, args.ticket)
        local res, err = httpc:request_uri(check_url, { method = "GET" })
        log_debug("/feishu res: %s, %s", serialize(res), err)
        if not res then
            return { code = -1, err = err }
        end
        return { code = 0 }
    end
}

--执行
apidoer(ngx.req, feishu_doers)