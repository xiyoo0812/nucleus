-- api/project.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local jdecode   = json.decode
local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize
local packproj  = data_pack.project

local apidoer   = utility.apidoer
local mongod    = nucleus.mongod

--定义接口
local project_doers = {
    GET = function(req, args)
        log_debug("/project GET params: %s", serialize(args))
        local res = mongod:find("projects", {})
        local records = {}
        for k, v in pairs(res) do
            tinsert(records, packproj(v))
        end
        return { code = 0, data = records, total = #records }
    end,
    POST = function(req, args)
        log_debug("/project POST params: %s", serialize(args))
        local project = jdecode(args.project)
        local record = mongod:find_one("projects", {name = project.name})
        if not record then
            return {code = -1, msg = "project not exist"}
        end
        local ok, err = mongod:update("projects", project, { name = project.name })
        if not ok then
            return {code = -1, msg = sformat("db update failed: %s", err)}
        end
        return { code = 0, data = project }
    end,
    PUT = function(req, args)
        log_debug("/project PUT params: %s", serialize(args))
        local project = jdecode(args.project)
        local res = mongod:find_one("projects", { name = project.name })
        if res then
            return { code = -1, msg = "name aready exist!" }
        end
        local ok, err = mongod:insert("projects", { project })
        if not ok then
            return { code = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { code = 0, data = project }
    end,
    DELETE = function(req, args)
        log_debug("/project DELETE params: %s", serialize(args))
        local projects = args.projects
        if type(projects) == "string" then
            local ok, err = mongod:delete("projects", { name = projects })
            if not ok then
                return {code = -1, msg = sformat("db delete failed: %s", err)}
            end
        else
            for _, pname in pairs(projects) do
                local ok, err = mongod:delete("projects", { name = pname })
                if not ok then
                    return {code = -1, msg = sformat("db delete failed: %s", err)}
                end
            end
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, project_doers)

