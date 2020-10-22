-- api/pipeline.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer

--定义接口
local pipeline_doers = {
    POST = function(req, params, session)
        log_debug("/pipeline POST params1: %s", serialize(params))
        local pipeline = params.args
        return { code = 0, data = pipeline }
    end,
    PUT = function(req, params, session)
        log_debug("/pipeline POST params1: %s", serialize(params))
        local pipeline = params.args
        local ok, plugin = pcall(load(pipeline.script))
        if not ok then
            return {code = -1, msg = sformat("plugin script load failed: %s", plugin)}
        end
        if plugin.init then
            local curproj = session.data.project
            pipeline.args.path = curproj.path
            local _ok, code, res = pcall(plugin.init, pipeline.args)
            if not _ok or code ~= 0 then
                return {code = -1, msg = sformat("plugin script init failed: %s", _ok and res or ok)}
            end
            return { code = 0, data = { args = res }}
        end
        return { code = 0, data = {} }
    end,
}

--执行
apidoer(ngx.req, pipeline_doers)

