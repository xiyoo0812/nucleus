-- api/role.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local jdecode   = json.decode
local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize
local packrole  = data_pack.role

local mongod    = nucleus.mongod
local apidoer   = utility.apidoer

--定义接口
local role_doers = {
    GET = function(req, args)
        log_debug("/role GET params: %s", serialize(args))
        local res = mongod:find("roles", {})
        local records = {}
        for _, record in pairs(res) do
            tinsert(records, packrole(record))
        end
        return { code = 0, data = records }
    end,
    POST = function(req, args)
        log_debug("/role POST params: %s", serialize(args))
        local role = jdecode(args.role)
        local record = mongod:find_one("roles", {id = role.id})
        if not record then
            return {code = -1, msg = "role not exist"}
        end
        local ok, err = mongod:update("roles", role, {id = role.id})
        if not ok then
            return {code = -1, msg = sformat("db update failed:%s", err)}
        end
        return { code = 0, data = role }
    end,
    PUT = function(req, args)
        log_debug("/role PUT params: %s", serialize(args))
        local role = jdecode(args.role)
        local res = mongod:find_one("roles", {["$or"] = {{name = role.name}, {en_name = role.en_name}}})
        if res then
            return { code = -1, msg = "name aready exist!" }
        end
        local ok, err = mongod:insert("roles", { role })
        if not ok then
            return { code = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { code = 0, data = role }
    end,
    DELETE = function(req, args)
        log_debug("/role DELETE params: %s", serialize(args))
        local roles = args.roles
        if type(roles) == "string" then
            local ok, err = mongod:delete("roles", {id = roles })
            if not ok then
                return {code = -1, msg = sformat("db delete failed: %s", err)}
            end
        else
            for _, id in pairs(roles) do
                local ok, err = mongod:delete("roles", { id = id })
                if not ok then
                    return {code = -1, msg = sformat("db delete failed: %s", err)}
                end
            end
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, role_doers)

