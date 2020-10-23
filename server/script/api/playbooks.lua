-- api/playbooks.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local admin_db  = nucleus.admin_db

--定义接口
local playbooks_doers = {
    GET = function(req, params, session)
        log_debug("/playbooks GET params: %s", serialize(params))
        local res = admin_db:find("playbooks", {}, {_id = 0})
        local records = {}
        for k, playbook in pairs(res) do
            tinsert(records, playbook)
        end
        return { code = 0, data = records, total = #records }
    end,
    POST = function(req, params, session)
        log_debug("/playbooks POST params: %s", serialize(params))
        local playbook = params.args
        local res = admin_db:find_one("playbooks", { name = playbook.name })
        if res and res.id ~= playbook.id then
            return { code = -1, msg = "playbook name aready exist!" }
        end
        local record = admin_db:find_one("playbooks", {id = playbook.id})
        if not record then
            return {code = -1, msg = "playbook not exist"}
        end
        playbook.creator = session.data.user.name
        local ok, err = admin_db:update("playbooks", playbook, { id = playbook.id })
        if not ok then
            return {code = -1, msg = sformat("playbook update failed: %s", err)}
        end
        return { code = 0, data = playbook }
    end,
    PUT = function(req, params, session)
        log_debug("/playbooks PUT params: %s", serialize(params))
        local playbook = params.args
        local res = admin_db:find_one("playbooks", { name = playbook.name })
        if res then
            return { code = -1, msg = "playbook name aready exist!" }
        end
        playbook.creator = session.data.user.name
        local ok, err = admin_db:insert("playbooks", { playbook })
        if not ok then
            return { code = -1, msg = sformat("playbook insert failed:%s", err)}
        end
        return { code = 0, data = playbook }
    end,
    DELETE = function(req, params, session)
        log_debug("/playbooks DELETE params: %s", serialize(params))
        local playbook_id = params.args
        local ok, err = admin_db:delete("playbooks", { id = playbook_id })
        if not ok then
            return {code = -1, msg = sformat("db delete failed: %s", err)}
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, playbooks_doers)

