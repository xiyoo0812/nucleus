-- api/codes.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db

--定义接口
local codes_doers = {
    GET = function(req, params, session)
        log_debug("/codes GET params: %s", serialize(params))
        local records = {}
        local res = proj_db:find("codes", {}, {_id = 0})
        for k, code in pairs(res) do
            tinsert(records, code)
        end
        return { code = 0, data = records, total = #records }
    end,
    POST = function(req, params, session)
        log_debug("/codes POST params: %s", serialize(params))
        local code = params.args
        local record = proj_db:find_one("codes", {name = code.name})
        if not record then
            return {code = -1, msg = "code not exist"}
        end
        local ok, err = proj_db:update("codes", code, { name = code.name })
        if not ok then
            return {code = -1, msg = sformat("db update failed: %s", err)}
        end
        return { code = 0, data = code }
    end,
    PUT = function(req, params, session)
        log_debug("/codes PUT params: %s", serialize(params))
        local code = params.args
        local res = proj_db:find_one("codes", { name = code.name })
        if res then
            return { code = -1, msg = "name aready exist!" }
        end
        local ok, err = proj_db:insert("codes", { code })
        if not ok then
            return { code = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { code = 0, data = code }
    end,
    DELETE = function(req, params, session)
        log_debug("/codes DELETE params: %s", serialize(params))
        local codes = params.args
        if type(codes) == "string" then
            local ok, err = proj_db:delete("codes", { id = codes })
            if not ok then
                return {code = -1, msg = sformat("db delete failed: %s", err)}
            end
        else
            for _, cid in pairs(codes) do
                local ok, err = proj_db:delete("codes", { id = cid })
                if not ok then
                    return {code = -1, msg = sformat("db delete failed: %s", err)}
                end
            end
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, codes_doers)

