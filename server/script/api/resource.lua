-- api/resource.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local jdecode       = json.decode
local tinsert       = table.insert
local sformat       = string.format
local log_debug     = logger.debug
local serialize     = logger.serialize
local packresource  = data_pack.resource

local admin_db      = nucleus.admin_db
local apidoer       = utility.apidoer

--定义接口
local resource_doers = {
    GET = function(req, args)
        log_debug("/resource GET params: %s", serialize(args))
        local res = admin_db:find("resources", {})
        local records = {}
        for _, record in pairs(res) do
            tinsert(records, packresource(record))
        end
        return { code = 0, data = records }
    end,
    POST = function(req, args)
        log_debug("/resource POST params: %s", serialize(args))
        local resource = jdecode(args.resource)
        local record = admin_db:find_one("resources", {id = resource.id})
        if not record then
            return {code = -1, msg = "resource not exist"}
        end
        local ok, err = admin_db:update("resources", resource, {id = resource.id})
        if not ok then
            return {code = -1, msg = sformat("db update failed:%s", err)}
        end
        return { code = 0, data = resource }
    end,
    PUT = function(req, args)
        log_debug("/resource PUT params: %s", serialize(args))
        local resource = jdecode(args.resource)
        local res = admin_db:find_one("resources", {["$or"] = {{name = resource.name}, {path = resource.path}}})
        if res then
            return { code = -1, msg = "name aready exist!" }
        end
        local ok, err = admin_db:insert("resources", { resource })
        if not ok then
            return { code = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { code = 0, data = resource }
    end,
    DELETE = function(req, args)
        log_debug("/resource DELETE params: %s", serialize(args))
        local resources = args.resources
        if type(resources) == "string" then
            local ok, err = admin_db:delete("resources", {id = resources })
            if not ok then
                return {code = -1, msg = sformat("db delete failed: %s", err)}
            end
        else
            for _, id in pairs(resources) do
                local ok, err = admin_db:delete("resources", {id = id })
                if not ok then
                    return {code = -1, msg = sformat("db delete failed: %s", err)}
                end
            end
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, resource_doers)

