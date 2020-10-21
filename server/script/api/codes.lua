-- api/codes.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local tinsert   = table.insert
local ssub      = string.sub
local sfind     = string.find
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize
local sexecute  = shell.execute
local aplaybook = ansible.playbook

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db
local admin_db  = nucleus.admin_db

local function format_addr(code)
    local pbegin, pend = sfind(code.addr, "http://")
    if pbegin and pend then
        local sbengin = ssub(code.addr, 1, pend)
        local send = ssub(code.addr, pend + 1)
        return sformat("%soauth2:%s@%s", sbengin, code.authkey, send)
    end
    return code.addr
end

local function create_playbook(session, code)
    local playbook_rd = admin_db:find_one("playbooks", {id = code.playbook}, {_id = 0})
    if playbook_rd then
        local script = string.gsub(playbook_rd.script, "$HOST", code.host)
        return sexecute(sformat([[echo "%s" > /tmp/%s.yaml]], script, code.id))
    end
    return false
end

local function code_clone_code(session, code)
    local project = session.data.project
    local args = {
        name = code.name,
        path = project.path,
        addr = format_addr(code)
    }
    local sok, sres = create_playbook(session, code)
    if not sok then
        return sok, sres
    end
    return aplaybook(sformat("/tmp/%s.yaml", code.id), args)
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
        local ok, err = proj_db:insert("codes", { code })
        if not ok then
            return { code = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { code = 0, data = code }
    end,
    DELETE = function(req, params, session)
        log_debug("/codes DELETE params: %s", serialize(params))
        local code_id = params.args
        local ok, err = proj_db:delete("codes", { id = code_id })
        if not ok then
            return {code = -1, msg = sformat("db delete failed: %s", err)}
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, codes_doers)

