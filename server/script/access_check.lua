--access_check.lua
--在这里进行权限校验

local log_err   = logger.err
local tindexof  = table_ex.indexof
local session   = require("resty.session")

local white_urls = {
    "/api/feishu",
    "/api/login",
}

local url = ngx.var.uri
if not tindexof(white_urls, url) then
    local now_session = session.open()
    local session_data = now_session.data
    if not session_data or not session_data.name then
        log_err("access_check(url %s) failed, session is nil", url)
        ngx.exit(ngx.HTTP_BAD_REQUEST)
        return
    end
    --url 权限校验
    --todo
end
