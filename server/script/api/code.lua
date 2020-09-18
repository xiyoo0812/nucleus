-- api/code.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local jdecode   = json.decode
local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize
local packcode  = data_pack.code

local apidoer   = utility.apidoer
local admin_db  = nucleus.admin_db

--定义接口
local code_doers = {
    GET = function(req, args)
        log_debug("/code GET params: %s", serialize(args))
        local res = admin_db:find("codes", {})
        local records = {}
        for k, v in pairs(res) do
            tinsert(records, packcode(v))
        end
        return { code = 0, data = records, total = #records }
    end,
    POST = function(req, args)
        log_debug("/code POST params: %s", serialize(args))
        local code = jdecode(args.code)
        local record = admin_db:find_one("codes", {name = code.name})
        if not record then
            return {code = -1, msg = "code not exist"}
        end
        local ok, err = admin_db:update("codes", code, { name = code.name })
        if not ok then
            return {code = -1, msg = sformat("db update failed: %s", err)}
        end
        return { code = 0, data = code }
    end,
    PUT = function(req, args)
        log_debug("/code PUT params: %s", serialize(args))
        local code = jdecode(args.code)
        local res = admin_db:find_one("codes", { name = code.name })
        if res then
            return { code = -1, msg = "name aready exist!" }
        end
        local ok, err = admin_db:insert("codes", { code })
        if not ok then
            return { code = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { code = 0, data = code }
    end,
    DELETE = function(req, args)
        log_debug("/code DELETE params: %s", serialize(args))
        local codes = args.codes
        if type(codes) == "string" then
            local ok, err = admin_db:delete("codes", { name = codes })
            if not ok then
                return {code = -1, msg = sformat("db delete failed: %s", err)}
            end
        else
            for _, cname in pairs(codes) do
                local ok, err = admin_db:delete("codes", { name = cname })
                if not ok then
                    return {code = -1, msg = sformat("db delete failed: %s", err)}
                end
            end
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, code_doers)

