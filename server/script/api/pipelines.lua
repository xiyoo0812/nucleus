-- api/pipelines.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db

--定义接口
local pipelines_doers = {
    GET = function(req, params, session)
        log_debug("/pipelines GET params: %s", serialize(params))
        local res = proj_db:find("pipelines", {}, {_id = 0})
        local records = {}
        for k, pipeline in pairs(res) do
            tinsert(records, pipeline)
        end
        return { code = 0, data = records, total = #records }
    end,
    POST = function(req, params, session)
        log_debug("/pipelines POST params: %s", serialize(params))
        local pipeline = params.args
        local res = proj_db:find_one("pipelines", { name = pipeline.name })
        if res and res.id ~= pipeline.id then
            return { code = -1, msg = "pipeline name aready exist!" }
        end
        local record = proj_db:find_one("pipelines", {id = pipeline.id})
        if not record then
            return {code = -1, msg = "pipeline not exist"}
        end
        pipeline.creator = session.data.user.name
        local ok, err = proj_db:update("pipelines", pipeline, { id = pipeline.id })
        if not ok then
            return {code = -1, msg = sformat("db update failed: %s", err)}
        end
        return { code = 0, data = pipeline }
    end,
    PUT = function(req, params, session)
        log_debug("/pipelines PUT params: %s", serialize(params))
        local pipeline = params.args
        local res = proj_db:find_one("pipelines", { name = pipeline.name })
        if res then
            return { code = -1, msg = "pipeline name aready exist!" }
        end
        pipeline.creator = session.data.user.name
        local ok, err = proj_db:insert("pipelines", { pipeline })
        if not ok then
            return { code = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { code = 0, data = pipeline }
    end,
    DELETE = function(req, params, session)
        log_debug("/pipelines DELETE params: %s", serialize(params))
        local pipeline_id = params.args
        local ok, err = proj_db:delete("pipelines", { id = pipeline_id })
        if not ok then
            return {code = -1, msg = sformat("db delete failed: %s", err)}
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, pipelines_doers)

