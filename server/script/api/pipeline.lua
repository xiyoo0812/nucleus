-- api/pipeline.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db

--定义接口
local pipeline_doers = {
    POST = function(req, params, session)
        log_debug("/pipeline POST params: %s", serialize(params))
        local pipeline = params.args
        local res = proj_db:find_one("pipeline", { name = pipeline.name })
        if res and res.id ~= pipeline.id then
            return { code = -1, msg = "pipeline name aready exist!" }
        end
        local record = proj_db:find_one("pipeline", {id = pipeline.id})
        if not record then
            return {code = -1, msg = "pipeline not exist"}
        end
        pipeline.creator = session.data.user.name
        local ok, err = proj_db:update("pipeline", pipeline, { id = pipeline.id })
        if not ok then
            return {code = -1, msg = sformat("db update failed: %s", err)}
        end
        return { code = 0, data = pipeline }
    end,
    PUT = function(req, params, session)
        log_debug("/pipeline PUT params: %s", serialize(params))
        local pipeline = params.args
        local res = proj_db:find_one("pipeline", { name = pipeline.name })
        if res then
            return { code = -1, msg = "pipeline name aready exist!" }
        end
        pipeline.creator = session.data.user.name
        local ok, err = proj_db:insert("pipeline", { pipeline })
        if not ok then
            return { code = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { code = 0, data = pipeline }
    end,
}

--执行
apidoer(ngx.req, pipeline_doers)

