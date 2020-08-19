-- api/package.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize
local packpack  = data_pack.package

local apidoer   = utility.apidoer
local mongod    = nucleus.mongod

--定义接口
local package_doers = {
    GET = function(req, args)
        log_debug("/package GET params: %s", serialize(args))
        local res = mongod:find("packages", {})
        local records = {}
        for k, v in pairs(res) do
            tinsert(records, packpack(v))
        end
        return { package = 0, data = records, total = #records }
    end,
    POST = function(req, args)
        log_debug("/package POST params: %s", serialize(args))
        local name = args.name
        local db_project = mongod:find_one("packages", {name = name})
        if not db_project then
            return {package = -1, msg = "package not exist"}
        end
        db_project.packages = args.packages
        local ok, err = mongod:update("packages", db_project, { name = name })
        if not ok then
            return {package = -1, msg = sformat("db update failed: %s", err)}
        end
        return { package = 0, data = db_project.packages }
    end,
    DELETE = function(req, args)
        log_debug("/package DELETE params: %s", serialize(args))
        local packages = args.packages
        if type(packages) == "string" then
            local ok, err = mongod:delete("packages", { name = packages })
            if not ok then
                return {package = -1, msg = sformat("db delete failed: %s", err)}
            end
        else
            for _, cname in pairs(packages) do
                local ok, err = mongod:delete("packages", { name = cname })
                if not ok then
                    return {package = -1, msg = sformat("db delete failed: %s", err)}
                end
            end
        end
        return { package = 0 }
    end,
}

--执行
apidoer(ngx.req, package_doers)

