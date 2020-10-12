-- api/hosts.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db

--定义接口
local hosts_doers = {
    GET = function(req, params, session)
        log_debug("/hosts GET params: %s", serialize(params))
        local res = proj_db:find("hosts", {}, {_id = 0})
        local records = {}
        for k, host in pairs(res) do
            tinsert(records, host)
        end
        return { code = 0, data = records, total = #records }
    end,
    POST = function(req, params, session)
        log_debug("/hosts POST params: %s", serialize(params))
        local host = params.args
        local res = proj_db:find_one("hosts", { name = host.name })
        if res and res.id ~= host.id then
            return { code = -1, msg = "host name aready exist!" }
        end
        local record = proj_db:find_one("hosts", {id = host.id})
        if not record then
            return {code = -1, msg = "host not exist"}
        end
        local ok, err = proj_db:update("hosts", host, { id = host.id })
        if not ok then
            return {code = -1, msg = sformat("db update failed: %s", err)}
        end
        return { code = 0, data = host }
    end,
    PUT = function(req, params, session)
        log_debug("/hosts PUT params: %s", serialize(params))
        local host = params.args
        local res = proj_db:find_one("hosts", { name = host.name })
        if res then
            return { code = -1, msg = "host name aready exist!" }
        end
        local ok, err = proj_db:insert("hosts", { host })
        if not ok then
            return { code = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { code = 0, data = host }
    end,
    DELETE = function(req, params, session)
        log_debug("/hosts DELETE params: %s", serialize(params))
        local hosts = params.args
        if type(hosts) == "string" then
            local ok, err = proj_db:delete("hosts", { id = hosts })
            if not ok then
                return {code = -1, msg = sformat("db delete failed: %s", err)}
            end
        else
            for _, hid in pairs(hosts) do
                local ok, err = proj_db:delete("hosts", { id = hid })
                if not ok then
                    return {code = -1, msg = sformat("db delete failed: %s", err)}
                end
            end
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, hosts_doers)

