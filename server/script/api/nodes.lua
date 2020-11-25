-- api/nodes.lua

local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db

--定义接口
local nodes_doers = {
    GET = function(req, params, session)
        log_debug("/nodes GET params: %s", serialize(params))
        local res = proj_db:find("nodes", {}, {_id = 0})
        local records = {}
        for k, node in pairs(res) do
            tinsert(records, node)
        end
        return { code = 0, data = records, total = #records }
    end,
    POST = function(req, params, session)
        log_debug("/nodes POST params: %s", serialize(params))
        local node = params.args
        local record = proj_db:find_one("nodes", {id = node.id})
        if not record then
            return {code = -1, msg = "node not exist"}
        end
        local ok, err = proj_db:update("nodes", node, { id = node.id })
        if not ok then
            return {code = -1, msg = sformat("node update failed: %s", err)}
        end
        return { code = 0, data = node }
    end,
    PUT = function(req, params, session)
        log_debug("/nodes PUT params: %s", serialize(params))
        local node = params.args
        node.creator = session.data.user.name
        local ok, err = proj_db:insert("nodes", { node })
        if not ok then
            return { code = -1, msg = sformat("node insert failed:%s", err)}
        end
        return { code = 0, data = node }
    end,
    DELETE = function(req, params, session)
        log_debug("/nodes DELETE params: %s", serialize(params))
        local nodeid = params.args
        local ok, err = proj_db:delete("nodes", { id = nodeid })
        if not ok then
            return {code = -1, msg = sformat("node delete failed: %s", err)}
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, nodes_doers)

