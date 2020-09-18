-- api/package.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize
local packpack  = data_pack.package

local apidoer   = utility.apidoer
local admin_db  = nucleus.admin_db

--定义接口
local package_doers = {
    GET = function(req, args)
        log_debug("/package GET params: %s", serialize(args))
        local res = admin_db:find("packages", {})
        local records = {}
        for k, v in pairs(res) do
            tinsert(records, packpack(v))
        end
        return { package = 0, data = records, total = #records }
    end,
    DELETE = function(req, args)
        log_debug("/package DELETE params: %s", serialize(args))
        local packages = args.packages
        if type(packages) == "string" then
            local ok, err = admin_db:delete("packages", { name = packages })
            if not ok then
                return {package = -1, msg = sformat("db delete failed: %s", err)}
            end
        else
            for _, cname in pairs(packages) do
                local ok, err = admin_db:delete("packages", { name = cname })
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

