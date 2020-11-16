-- api/products.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize
local playbookn = ansible.playbookn

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db

--定义接口
local products_doers = {
    GET = function(req, params, session)
        log_debug("/products GET params: %s", serialize(params))
        local code = params.key
        local query = (#code > 0) and {code = code} or {}
        local res = proj_db:find("products", query, {_id = 0})
        local records = {}
        for _, record in pairs(res) do
            tinsert(records, record)
        end
        return { code = 0, data = records, total = #records }
    end,
    DELETE = function(req, params, session)
        log_debug("/products DELETE params: %s", serialize(params))
        local productid = params.args
        local res = proj_db:find_one("products", {id = productid}, {_id = 0})
        if not res then
            return {code = -1, msg = "product not exist"}
        end
        local ok, err = proj_db:delete("products", { id = productid })
        if not ok then
            return {code = -1, msg = sformat("product delete failed: %s", err)}
        end
        local project = session.data.project
        local args = {
            host = res.host,
            name = sformat("%s/products/%s/%s", project.path, res.code, res.name),
        }
        local sok, shres = playbookn("rmfr", args)
        if not sok then
            return { code = -1, msg = sformat("delete product failed:%s", shres)}
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, products_doers)

