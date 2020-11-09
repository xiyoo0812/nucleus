-- api/taskss.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local sformat   = string.format
local tcopy     = table_ex.copy
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
        return false, sformat("plugin script load failed:\n %s", plugin)
    end
    if plugin.run then
        local pbargs = tcopy(pipeline.args)
        pbargs.time = os.time()
        pbargs.task = pipeline.task
        pbargs.path = session.data.project.path
        pbargs.module = sformat("pipelines/%s", pipeline.id)
        local _ok, code, res = pcall(plugin.run, pbargs, plugin_res.run_book)
        if not _ok or code ~= 0 then
            return false, sformat("plugin script run failed:\n %s", _ok and res or code)
        end
        log_debug("/pipeline plugin_run success name:%s: res:%s", plugin_res.name, serialize(res))
        return true, res
    end
    log_debug("/pipeline plugin_run success no res name: %s ", plugin_res.name)
    return true, {}
end

--定义接口
local tasks_doers = {
    GET = function(req, params, session)
        log_debug("/tasks GET params: %s", serialize(params))
        local task_id = params.key
        local query = (#task_id > 0) and {id = task_id} or {}
        local res = proj_db:find_one("tasks", query, {_id = 0})
        if not res then
            return {code = -1, msg = "task not exist"}
        end
        return { code = 0, data = { res } }
    end,
    PUT = function(req, params, session)
        log_debug("/tasks PUT params: %s", serialize(params))
        local form = params.args
        local pipeline_id = form.pipeline
        local pipeline = proj_db:find_one("pipelines", { id = pipeline_id}, {_id = 0})
        if not pipeline then
            return {code = -1, msg = "pipeline not exist"}
        end
        pipeline.args = form.args
        pipeline.task = form.task
        local ok, err = proj_db:update("pipelines", pipeline, { id = pipeline.id })
        if not ok then
            return { code = -1, msg = sformat("pipeline insert failed:%s", err)}
        end
        local task = {
            steps = {},
            id = form.task,
            time = os.time(),
            name = pipeline.name,
            pipeline = pipeline_id,
            status = "process",
            output = sformat("start run pipeline: %s", pipeline.name),
        }
        for index, plugin in ipairs(pipeline.plugins) do
            task.steps[index] = {name = plugin.nick, status="wait"}
        end
        local tok, terr = proj_db:insert("tasks", { task })
        if not tok then
            return { code = -1, msg = sformat("task insert failed:%s", terr)}
        end
        local delay_ctx = {}
        delay_ctx.handler = function(premature)
            local task_res = true
            for index, plugin in ipairs(pipeline.plugins) do
                task.steps[index].status = "process"
                task.output = sformat("%s\nstart run plugin: %s", task.output, plugin.name)
                proj_db:update("tasks", task, { id = task.id })
                local rok, rres = plugin_run(session, pipeline, plugin.pid)
                if not rok then
                    task.steps[index].status = "error"
                    task.output = sformat("%s\nstart exec plugin: %s failed: %s\n", task.output, plugin.name, rres)
                    proj_db:update("tasks", task, { id = task.id })
                    task_res = false
                    break
                end
                task.steps[index].status = "success"
                for _, atask in ipairs(rres) do
                    task.output = sformat("%s\n%s\n%s", task.output, atask.cmd, atask.stdout)
                end
                proj_db:update("tasks", task, { id = task.id })
            end
            task.status = task_res and "success" or "error"
            proj_db:update("tasks", task, { id = task.id })
            pipeline.task_id = nil
            proj_db:update("pipelines", pipeline, { id = pipeline.id })
        end
        return { code = 0, data = task }, delay_ctx
    end,
    DELETE = function(req, params, session)
        log_debug("/tasks DELETE params: %s", serialize(params))
        local taskid = params.args
        local ok, err = proj_db:delete("tasks", { id = taskid })
        if not ok then
            return {code = -1, msg = sformat("task delete failed: %s", err)}
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, tasks_doers)

