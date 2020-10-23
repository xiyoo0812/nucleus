-- api/plugins.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local admin_db  = nucleus.admin_db

--定义接口
local plugins_doers = {
    GET = function(req, params, session)
        log_debug("/plugins GET params: %s", serialize(params))
        local res = admin_db:find("plugins", {}, {_id = 0})
        local records = {}
        for k, plugin in pairs(res) do
            tinsert(records, plugin)
        end
        return { code = 0, data = records, total = #records }
    end,
    POST = function(req, params, session)
        log_debug("/plugins POST params: %s", serialize(params))
        local plugin = params.args
        local res = admin_db:find_one("plugins", { name = plugin.name })
        if res and res.id ~= plugin.id then
            return { code = -1, msg = "plugin name aready exist!" }
        end
        local record = admin_db:find_one("plugins", {id = plugin.id})
        if not record then
            return {code = -1, msg = "plugin not exist"}
        end
        local lok, lerr = pcall(load(plugin.script))
        if not lok then
            return {code = -1, msg = sformat("plugin load script failed: %s", lerr)}
        end
        plugin.creator = session.data.user.name
        local ok, err = admin_db:update("plugins", plugin, { id = plugin.id })
        if not ok then
            return {code = -1, msg = sformat("plugin update failed: %s", err)}
        end
        return { code = 0, data = plugin }
    end,
    PUT = function(req, params, session)
        log_debug("/plugins PUT params: %s", serialize(params))
        local plugin = params.args
        local res = admin_db:find_one("plugins", { name = plugin.name })
        if res then
            return { code = -1, msg = "plugin name aready exist!" }
        end
        local lok, lerr = pcall(load(plugin.script))
        if not lok then
            return {code = -1, msg = sformat("plugin load script failed: %s", lerr)}
        end
        plugin.creator = session.data.user.name
        local ok, err = admin_db:insert("plugins", { plugin })
        if not ok then
            return { code = -1, msg = sformat("plugin insert failed:%s", err)}
        end
        return { code = 0, data = plugin }
    end,
    DELETE = function(req, params, session)
        log_debug("/plugins DELETE params: %s", serialize(params))
        local plugin_id = params.args
        local ok, err = admin_db:delete("plugins", { id = plugin_id })
        if not ok then
            return {code = -1, msg = sformat("plugin delete failed: %s", err)}
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, plugins_doers)

