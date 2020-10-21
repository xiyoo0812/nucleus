-- api/task.lua
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
local task_doers = {
    GET = function(req, args)
        log_debug("/task GET params: %s", serialize(args))
        local res = admin_db:find("tasks", {})
        local records = {}
        for k, v in pairs(res) do
            tinsert(records, packtask(v))
        end
        return { task = 0, data = records, total = #records }
    end,
    POST = function(req, args)
        log_debug("/task POST params: %s", serialize(args))
        local task = jdecode(args.task)
        local record = admin_db:find_one("tasks", {name = task.name})
        if not record then
            return {task = -1, msg = "task not exist"}
        end
        local ok, err = admin_db:update("tasks", task, { name = task.name })
        if not ok then
            return {task = -1, msg = sformat("db update failed: %s", err)}
        end
        return { task = 0, data = task }
    end,
    DELETE = function(req, args)
        log_debug("/task DELETE params: %s", serialize(args))
        local tasks = args.tasks
        if type(tasks) == "string" then
            local ok, err = admin_db:delete("tasks", { name = tasks })
            if not ok then
                return {task = -1, msg = sformat("db delete failed: %s", err)}
            end
        else
            for _, cname in pairs(tasks) do
                local ok, err = admin_db:delete("tasks", { name = cname })
                if not ok then
                    return {task = -1, msg = sformat("db delete failed: %s", err)}
                end
            end
        end
        return { task = 0 }
    end,
}

--执行
apidoer(ngx.req, task_doers)

