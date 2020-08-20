-- api/host.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local jdecode   = json.decode
local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize
local packhost  = data_pack.host

local apidoer   = utility.apidoer
local mongod    = nucleus.mongod

--定义接口
local host_doers = {
    GET = function(req, args)
        log_debug("/host GET params: %s", serialize(args))
        local res = mongod:find("hosts", {})
        local records = {}
        for k, v in pairs(res) do
            tinsert(records, packhost(v))
        end
        return { host = 0, data = records, total = #records }
    end,
    POST = function(req, args)
        log_debug("/host POST params: %s", serialize(args))
        local host = jdecode(args.host)
        local record = mongod:find_one("hosts", {name = host.name})
        if not record then
            return {host = -1, msg = "host not exist"}
        end
        local ok, err = mongod:update("hosts", host, { name = host.name })
        if not ok then
            return {host = -1, msg = sformat("db update failed: %s", err)}
        end
        return { host = 0, data = host }
    end,
    PUT = function(req, args)
        log_debug("/host PUT params: %s", serialize(args))
        local host = jdecode(args.host)
        local res = mongod:find_one("hosts", { name = host.name })
        if res then
            return { host = -1, msg = "name aready exist!" }
        end
        local ok, err = mongod:insert("hosts", { host })
        if not ok then
            return { host = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { host = 0, data = host }
    end,
    DELETE = function(req, args)
        log_debug("/host DELETE params: %s", serialize(args))
        local hosts = args.hosts
        if type(hosts) == "string" then
            local ok, err = mongod:delete("hosts", { name = hosts })
            if not ok then
                return {host = -1, msg = sformat("db delete failed: %s", err)}
            end
        else
            for _, cname in pairs(hosts) do
                local ok, err = mongod:delete("hosts", { name = cname })
                if not ok then
                    return {host = -1, msg = sformat("db delete failed: %s", err)}
                end
            end
        end
        return { host = 0 }
    end,
}

--执行
apidoer(ngx.req, host_doers)

