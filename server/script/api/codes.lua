-- api/codes.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local tinsert       = table.insert
local ssub          = string.sub
local sfind         = string.find
local sformat       = string.format
local log_debug     = logger.debug
local serialize     = logger.serialize
local playbookn     = ansible.playbookn

local apidoer       = utility.apidoer
local proj_db       = nucleus.proj_db

local function format_addr(code)
    local pbegin, pend = sfind(code.addr, "http://")
    if pbegin and pend then
        local sbengin = ssub(code.addr, 1, pend)
        local send = ssub(code.addr, pend + 1)
        return sformat("%soauth2:%s@%s", sbengin, code.authkey, send)
    end
    return code.addr
end

local function code_clone_code(session, code)
    if code.type == "git" then
        local project = session.data.project
        local args = {
            module = "codes",
            host = code.host,
            code = code.name,
            path = project.path,
            addr = format_addr(code)
        }
        return playbookn("gitclone", args)
    end
    return true
end

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
        local res = proj_db:find_one("codes", { name = code.name }, {_id = 0})
        if res and res.id ~= code.id then
            return { code = -1, msg = "code name aready exist!" }
        end
        local record = proj_db:find_one("codes", {id = code.id}, {_id = 0})
        if not record then
            return {code = -1, msg = "code not exist"}
        end
        if code.is_remote then
            local ok, ccres = code_clone_code(session, code)
            if not ok then
                return {code = -1, msg = sformat("code clone failed: %s", ccres)}
            end
        end
        local ok, err = proj_db:update("codes", code, { id = code.id })
        if not ok then
            return {code = -1, msg = sformat("code update failed: %s", err)}
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
        if code.is_remote then
            local ok, ccres = code_clone_code(session, code)
            if not ok then
                return {code = -1, msg = sformat("code clone failed: %s", ccres)}
            end
        end
        local ok, err = proj_db:insert("codes", { code })
        if not ok then
            return { code = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { code = 0, data = code }
    end,
    DELETE = function(req, params, session)
        log_debug("/codes DELETE params: %s", serialize(params))
        local code_id = params.args
        local coderes = proj_db:find_one("codes", { id = code_id })
        if not coderes then
            return { code = -1, msg = "code not exist!" }
        end
        local ok, err = proj_db:delete("codes", { id = code_id })
        if not ok then
            return {code = -1, msg = sformat("code delete failed: %s", err)}
        end
        if coderes.is_remote then
            local project = session.data.project
            local args = {
                host = coderes.host,
                dir = sformat("%s/codes/%s", project.path, coderes.name),
            }
            local sok, shres = playbookn("rmdir", args)
            if not sok then
                return { code = -1, msg = sformat("delete code path failed:%s", shres)}
            end
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, codes_doers)

