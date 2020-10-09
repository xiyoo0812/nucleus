-- api/node.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local jdecode   = json.decode
local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local admin_db  = nucleus.admin_db

--定义接口
local node_doers = {
    GET = function(req, args)
        log_debug("/node GET params: %s", serialize(args))
        local res = admin_db:find("nodes", {}, {_id = 0})
        local records = {}
        for k, node in pairs(res) do
            tinsert(records, node)
        end
        return { node = 0, data = records, total = #records }
    end,
    POST = function(req, args)
        log_debug("/node POST params: %s", serialize(args))
        local node = jdecode(args.node)
        local record = admin_db:find_one("nodes", {name = node.name})
        if not record then
            return {node = -1, msg = "node not exist"}
        end
        local ok, err = admin_db:update("nodes", node, { name = node.name })
        if not ok then
            return {node = -1, msg = sformat("db update failed: %s", err)}
        end
        return { node = 0, data = node }
    end,
    PUT = function(req, args)
        log_debug("/node PUT params: %s", serialize(args))
        local node = jdecode(args.node)
        local res = admin_db:find_one("nodes", { name = node.name })
        if res then
            return { node = -1, msg = "name aready exist!" }
        end
        local ok, err = admin_db:insert("nodes", { node })
        if not ok then
            return { node = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { node = 0, data = node }
    end,
    DELETE = function(req, args)
        log_debug("/node DELETE params: %s", serialize(args))
        local nodes = args.nodes
        if type(nodes) == "string" then
            local ok, err = admin_db:delete("nodes", { name = nodes })
            if not ok then
                return {node = -1, msg = sformat("db delete failed: %s", err)}
            end
        else
            for _, cname in pairs(nodes) do
                local ok, err = admin_db:delete("nodes", { name = cname })
                if not ok then
                    return {node = -1, msg = sformat("db delete failed: %s", err)}
                end
            end
        end
        return { node = 0 }
    end,
}

--执行
apidoer(ngx.req, node_doers)

