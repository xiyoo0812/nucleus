-- api/products.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db

--定义接口
local products_doers = {
    GET = function(req, params, session)
        log_debug("/products GET params: %s", serialize(params))
        local res = proj_db:find("products", {}, {_id = 0})
        local records = {}
        for _, record in pairs(res) do
            tinsert(records, record)
        end
        return { code = 0, data = records, total = #records }
    end,
    DELETE = function(req, params, session)
        log_debug("/products DELETE params: %s", serialize(params))
        local productid = params.args
        if type(productid) == "string" then
            local ok, err = proj_db:delete("products", { id = productid })
            if not ok then
                return {code = -1, msg = sformat("product delete failed: %s", err)}
            end
        else
            for _, pid in pairs(productid) do
                local ok, err = proj_db:delete("products", { id = pid })
                if not ok then
                    return {code = -1, msg = sformat("product delete failed: %s", err)}
                end
            end
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, products_doers)

