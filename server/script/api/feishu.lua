-- api/feishu.lua
local json      = require("cjson")
local http      = require("resty.http")
local session   = require("resty.session")

local sformat   = string.format
local log_debug = logger.debug
local log_err   = logger.err
local serialize = logger.serialize

local apidoer   = utility.apidoer
local admin_db  = nucleus.admin_db
local jdecode   = json.decode

local feishu_url = "http://ex.idreamsky.com:40008/userInfo"
local avatar_url = "https://exs.idreamsky.com:40000/commonapi/oa/avatar"

--定义接口
local feishu_doers = {
    GET = function(req, params)
        log_debug("/feishu params: %s", serialize(params))

        local httpc = http.new()
        local check_url = sformat("%s?ticket=%s", feishu_url, params.ticket)
        local res, err = httpc:request_uri(check_url, { method = "GET" })
        if not res then
            return { code = -1, err = err }
        end
        local data = jdecode(res.body).data
        local db_res = admin_db:find_one("users", {en_name = data.en_name})
        local user = {
            type = "feishu",
            name = data.name,
            email = data.email,
            en_name = data.en_name,
            empCode = data.empCode,
            dept = data.dept:sub(data.dept:find("/") + 1),
            avatar = sformat("%s/%s", avatar_url, data.en_name),
            roles = {},
        }
        if not db_res then
            local ok = admin_db:insert("users", {user})
            if not ok then
                log_err("/feishu admin_db:insert failed")
                return { code = -1, msg = "admin_db insert failed" }
            end
        end
        --保存会话
        local new_session = session.start()
        new_session.data.user = user
        new_session:save()
        return { code = 0, user = user }
    end,
}

--执行
apidoer(ngx.req, feishu_doers)