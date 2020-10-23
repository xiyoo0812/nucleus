-- api/pipeline.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db
local admin_db  = nucleus.admin_db

local function plugin_init(session, pipeline, plugin_id)
    local plugin_res = admin_db:find_one("plugins", {id = plugin_id})
    if not plugin_res then
        return false, sformat("plugin %s not exist: %s", plugin_id)
    end
    local ok, plugin = pcall(load(plugin_res.script))
    if not ok then
        return false, sformat("plugin script load failed: %s", plugin)
    end
    if plugin.init then
        pipeline.args.module = "code"
        pipeline.args.path = session.data.project.path
        local _ok, code, res = pcall(plugin.init, pipeline.args, plugin_res.init_book)
        if not _ok or code ~= 0 then
            return false, sformat("plugin script init failed: %s", _ok and res or ok)
        end
        return true, res
    end
    return true, {}
end

--定义接口
local pipeline_doers = {
    POST = function(req, params, session)
        log_debug("/pipeline POST params1: %s", serialize(params))
        local pipeline_id = params.args
        local pipeline = proj_db:find_one("pipelines", { id = pipeline_id}, {_id = 0})
        if not pipeline then
            return {code = -1, msg = "pipeline not exist"}
        end
        local newArgs = {}
        for _, plugin in pairs(pipeline.plugins) do
            local ok, res = plugin_init(session, pipeline, plugin.pid)
            if not ok then
                return {code = -1, msg = res}
            end
            for key, value in pairs(res.args) do
                newArgs[key] = value
            end
        end
        return { code = 0, data = { args = newArgs }}
    end,
    PUT = function(req, params, session)
        log_debug("/pipeline PUT params1: %s", serialize(params))
        local pipeline = params.args
        local ok, res = plugin_init(session, pipeline, pipeline.plugin)
        if not ok then
            return {code = -1, msg = res}
        end
        return { code = 0, data = res }
    end,
}

--执行
apidoer(ngx.req, pipeline_doers)

