-- api/task.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize
local packtask = data_pack.task

local apidoer   = utility.apidoer
local mongod    = nucleus.mongod

--定义接口
local task_doers = {
    GET = function(req, args)
        log_debug("/task GET params: %s", serialize(args))
        local res = mongod:find("tasks", {})
        local records = {}
        for k, v in pairs(res) do
            tinsert(records, packtask(v))
        end
        return { task = 0, data = records, total = #records }
    end,
    POST = function(req, args)
        log_debug("/task POST params: %s", serialize(args))
        local name = args.name
        local db_project = mongod:find_one("tasks", {name = name})
        if not db_project then
            return {task = -1, msg = "task not exist"}
        end
        db_project.tasks = args.tasks
        local ok, err = mongod:update("tasks", db_project, { name = name })
        if not ok then
            return {task = -1, msg = sformat("db update failed: %s", err)}
        end
        return { task = 0, data = db_project.tasks }
    end,
    DELETE = function(req, args)
        log_debug("/task DELETE params: %s", serialize(args))
        local tasks = args.tasks
        if type(tasks) == "string" then
            local ok, err = mongod:delete("tasks", { name = tasks })
            if not ok then
                return {task = -1, msg = sformat("db delete failed: %s", err)}
            end
        else
            for _, cname in pairs(tasks) do
                local ok, err = mongod:delete("tasks", { name = cname })
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

