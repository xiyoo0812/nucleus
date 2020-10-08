-- api/hosts.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local jdecode   = json.decode
local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db

--定义接口
local hosts_doers = {
    GET = function(req, args)
        log_debug("/hosts GET params: %s", serialize(args))
        local res = proj_db:find("hosts", {}, {_id = 0})
        local records = {}
        for k, host in pairs(res) do
            tinsert(records, host)
        end
        return { host = 0, data = records, total = #records }
    end,
    POST = function(req, args)
        log_debug("/hosts POST params: %s", serialize(args))
        local host = jdecode(args.host)
        local record = proj_db:find_one("hosts", {name = host.name})
        if not record then
            return {host = -1, msg = "host not exist"}
        end
        local ok, err = proj_db:update("hosts", host, { name = host.name })
        if not ok then
            return {host = -1, msg = sformat("db update failed: %s", err)}
        end
        return { host = 0, data = host }
    end,
    PUT = function(req, args)
        log_debug("/hosts PUT params: %s", serialize(args))
        local host = jdecode(args.host)
        local res = proj_db:find_one("hosts", { name = host.name })
        if res then
            return { host = -1, msg = "name aready exist!" }
        end
        local ok, err = proj_db:insert("hosts", { host })
        if not ok then
            return { host = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { host = 0, data = host }
    end,
    DELETE = function(req, args)
        log_debug("/hosts DELETE params: %s", serialize(args))
        local hosts = args.hosts
        if type(hosts) == "string" then
            local ok, err = proj_db:delete("hosts", { name = hosts })
            if not ok then
                return {host = -1, msg = sformat("db delete failed: %s", err)}
            end
        else
            for _, cname in pairs(hosts) do
                local ok, err = proj_db:delete("hosts", { name = cname })
                if not ok then
                    return {host = -1, msg = sformat("db delete failed: %s", err)}
                end
            end
        end
        return { host = 0 }
    end,
}

--执行
apidoer(ngx.req, hosts_doers)

