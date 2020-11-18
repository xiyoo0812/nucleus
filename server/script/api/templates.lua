-- api/templates.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db

--定义接口
local templates_doers = {
    GET = function(req, params, session)
        log_debug("/templates GET params: %s", serialize(params))
        local res = proj_db:find("templates", {}, {_id = 0})
        local records = {}
        for k, template in pairs(res) do
            tinsert(records, template)
        end
        return { code = 0, data = records, total = #records }
    end,
    POST = function(req, params, session)
        log_debug("/templates POST params: %s", serialize(params))
        local template = params.args
        local record = proj_db:find_one("templates", {id = template.id})
        if not record then
            return {code = -1, msg = "template not exist"}
        end
        local ok, err = proj_db:update("templates", template, { id = template.id })
        if not ok then
            return {code = -1, msg = sformat("template update failed: %s", err)}
        end
        return { code = 0, data = template }
    end,
    PUT = function(req, params, session)
        log_debug("/templates PUT params: %s", serialize(params))
        local template = params.args
        template.creator = session.data.user.name
        local ok, err = proj_db:insert("templates", { template })
        if not ok then
            return { code = -1, msg = sformat("template insert failed:%s", err)}
        end
        return { code = 0, data = template }
    end,
    DELETE = function(req, params, session)
        log_debug("/templates DELETE params: %s", serialize(params))
        local dbid = params.args
        local ok, err = proj_db:delete("templates", { id = dbid })
        if not ok then
            return {code = -1, msg = sformat("template delete failed: %s", err)}
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, templates_doers)

