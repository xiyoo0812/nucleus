-- api/authkeys.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local shcall    = shell.call
local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db

--定义接口
local authkeys_doers = {
    GET = function(req, params, session)
        log_debug("/authkeys GET params: %s", serialize(params))
        local res = proj_db:find("authkeys", {}, {_id = 0})
        local records = {}
        for k, key in pairs(res) do
            tinsert(records, key)
        end
        return { code = 0, data = records, total = #records }
    end,
    POST = function(req, params, session)
        log_debug("/authkeys POST params: %s", serialize(params))
        local authkey = params.args
        local res = proj_db:find_one("authkeys", { name = authkey.name })
        if res and res.id ~= authkey.id then
            return { code = -1, msg = "authkey name aready exist!" }
        end
        local record = proj_db:find_one("authkeys", {id = authkey.id})
        if not record then
            return {code = -1, msg = "authkey not exist"}
        end
        authkey.time = os.time()
        authkey.sshkey = record.sshkey
        local ok, err = proj_db:update("authkeys", authkey, { id = authkey.id })
        if not ok then
            return {code = -1, msg = sformat("db update failed: %s", err)}
        end
        return { code = 0, data = authkey }
    end,
    PUT = function(req, params, session)
        log_debug("/authkeys PUT params: %s", serialize(params))
        local authkey = params.args
        local res = proj_db:find_one("authkeys", { name = authkey.name })
        if res then
            return { code = -1, msg = "authkey name aready exist!" }
        end
        if authkey.type == "SSHKey" then
            if #authkey.sshkey == 0 then
                local ok, shres = shcall(sformat("ssh-keygen -q -trsa -N -Cnucleus -f ~/.ssh/%s", authkey.id))
                if not ok then
                    return { code = -1, msg = sformat("ssh-keygen failed:%s", shres)}
                end
                authkey.sshkey = authkey.id
            end
            local ok, shres = shcall(sformat("cat ~/.ssh/%s.pub", authkey.id))
            if not ok then
                return { code = -1, msg = sformat("ssh read pub failed:%s", shres)}
            end
            authkey.sshkey_pub = shres
        end
        authkey.time = os.time()
        local ok, err = proj_db:insert("authkeys", { authkey })
        if not ok then
            return { code = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { code = 0, data = authkey }
    end,
    DELETE = function(req, params, session)
        log_debug("/authkeys DELETE params: %s", serialize(params))
        local authkeys = params.args
        if type(authkeys) == "string" then
            local ok, err = proj_db:delete("authkeys", { id = authkeys })
            if not ok then
                return {code = -1, msg = sformat("db delete failed: %s", err)}
            end
        else
            for _, kid in pairs(authkeys) do
                local ok, err = proj_db:delete("authkeys", { id = kid })
                if not ok then
                    return {code = -1, msg = sformat("db delete failed: %s", err)}
                end
            end
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, authkeys_doers)

