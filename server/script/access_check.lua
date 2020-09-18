--access_check.lua
local json      = require "cjson.safe"
local session   = require("resty.session")
json.encode_sparse_array(true)
--在这里进行权限校验

local log_err   = logger.err
local tindexof  = table_ex.indexof
local jencode   = json.encode

local white_urls = {
    "/api/feishu",
    "/api/login",
}

local url = ngx.var.uri
if tindexof(white_urls, url) == 0 then
    local now_session = session.open()
    local session_data = now_session.data
    if not session_data or not session_data.user then
        log_err("access_check(url %s) failed, session is nil", url)
        ngx.say(jencode({ code = -2 }))
        return
    end
    --url 权限校验
    --todo
end
