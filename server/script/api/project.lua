-- api/project.lua
local json      = require "cjson.safe"
local session   = require("resty.session")
json.encode_sparse_array(true)

local jdecode   = json.decode
local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize
local packproj  = data_pack.project

local apidoer   = utility.apidoer
local admin_db  = nucleus.admin_db
local proj_db   = nucleus.proj_db

--定义接口
local project_doers = {
    GET = function(req, params)
        log_debug("/project GET params: %s", serialize(params))
        local res = admin_db:find("projects", {})
        local records = {}
        for k, v in pairs(res) do
            tinsert(records, packproj(v))
        end
        return { code = 0, data = records, total = #records }
    end,
    POST = function(req, params)
        log_debug("/project POST params: %s", serialize(params))
        local project = jdecode(params.args)
        local record = admin_db:find_one("projects", {name = project.name})
        if not record then
            return {code = -1, msg = "project not exist"}
        end
        local ok, err = admin_db:update("projects", project, { name = project.name })
        if not ok then
            return {code = -1, msg = sformat("db update failed: %s", err)}
        end
        return { code = 0, data = project }
    end,
    PUT = function(req, params)
        log_debug("/project PUT params: %s", serialize(params))
        local new_session = session.start()
        local usrres = new_session.data.user
        if not usrres then
            return { code = -1, msg = "project admin not find" }
        end
        local project = jdecode(params.args)
        project.admin = usrres.en_name
        local res = admin_db:find_one("projects", { name = project.name })
        if res then
            return { code = -1, msg = "name aready exist!" }
        end
        local ok, err = admin_db:insert("projects", { project })
        if not ok then
            return { code = -1, msg = sformat("project insert failed:%s", err)}
        end
        proj_db:set_db("nucleus_proj_" .. project.id)
        local ok1, err1 = proj_db:insert("users", { usrres })
        if not ok1 then
            return { code = -1, msg = sformat("project admin insert failed:%s", err1)}
        end
        return { code = 0, data = project }
    end,
    DELETE = function(req, params)
        log_debug("/project DELETE params: %s", serialize(params))
        local project = params.args
        local ok, err = admin_db:delete("projects", { id = project })
        if not ok then
            return {code = -1, msg = sformat("db delete failed: %s", err)}
        end
        proj_db:drop()
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, project_doers)

