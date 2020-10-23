-- api/task.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db
local admin_db  = nucleus.admin_db

local function plugin_run(session, pipeline, plugin_id)
    local plugin_res = admin_db:find_one("plugins", {id = plugin_id})
    if not plugin_res then
        return false, sformat("plugin %s not exist: %s", plugin_id)
    end
    local ok, plugin = pcall(load(plugin_res.script))
    if not ok then
        return false, sformat("plugin script load failed: %s", plugin)
    end
    if plugin.run then
        pipeline.args.module = "pipeline"
        pipeline.args.path = session.data.project.path
        local _ok, code, res = pcall(plugin.run, pipeline.args, plugin_res.run_book)
        if not _ok or code ~= 0 then
            return false, sformat("plugin script run failed: %s", _ok and res or ok)
        end
        return true, res
    end
    return true, {}
end

--定义接口
local task_doers = {
    GET = function(req, params, session)
        log_debug("/task GET params: %s", serialize(params))
        local task_id = params.args
        local res = admin_db:find_one("tasks", {id = task_id}, {_id = 0})
        if not res then
            return {task = -1, msg = "task not exist"}
        end
        return { task = 0, data = { res } }
    end,
    PUT = function(req, params, session)
        log_debug("/task PUT params: %s", serialize(params))
        local pipeline_id = params.pipeline
        local pipeline = proj_db:find_one("pipelines", { id = pipeline_id}, {_id = 0})
        if not pipeline then
            return {code = -1, msg = "pipeline not exist"}
        end
        pipeline.args = params.args
        pipeline.task_id = params.task_id
        local ok, err = proj_db:update("pipelines", pipeline, { id = pipeline.id })
        if not ok then
            return { code = -1, msg = sformat("pipeline insert failed:%s", err)}
        end
        local task = {
            id = params.task_id,
            pipeline = pipeline_id,
            outputs = {},
        }
        local tok, terr = proj_db:insert("tasks", { task })
        if not tok then
            return { code = -1, msg = sformat("task insert failed:%s", terr)}
        end
        for _, plugin in pairs(pipeline.plugins) do
            local rok, res = plugin_run(session, pipeline, plugin.pid)
            if not rok then
                return {code = -1, msg = res}
            end
        end
        return { code = 0, data = { pipeline = pipeline, task = task }}
    end,
    DELETE = function(req, params, session)
        log_debug("/task DELETE params: %s", serialize(params))
        local taskid = params.tasks
        local ok, err = admin_db:delete("tasks", { id = taskid })
        if not ok then
            return {code = -1, msg = sformat("db delete failed: %s", err)}
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, task_doers)

