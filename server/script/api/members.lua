-- api/members.lua
local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize
local packmember= data_pack.member

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db

--定义接口
local members_doers = {
    GET = function(req, params, session)
        --获取项目成员列表
        log_debug("/members GET params: %s", serialize(params))
        local res = proj_db:find("members", {})
        local records = {}
        for k, v in pairs(res) do
            tinsert(records, packmember(v))
        end
        return { code = 0, data = records, total = #records }
    end,
    POST = function(req, params, session)
        --修改项目成员
        log_debug("/members POST params: %s", serialize(params))
        local member = params.args
        local record = proj_db:find_one("members", {en_name = member.en_name})
        if not record then
            return {code = -1, msg = "member not exist"}
        end
        local ok, err = proj_db:update("members", member, {en_name = member.en_name})
        if not ok then
            return {code = -1, msg = sformat("db update failed: %s", err)}
        end
        return { code = 0, data = member }
    end,
    DELETE = function(req, params, session)
        --踢出项目成员
        log_debug("/members DELETE params: %s", serialize(params))
        local en_name = params.args
        local ok, err = proj_db:delete("members", {en_name = en_name })
        if not ok then
            return {code = -1, msg = sformat("db delete failed: %s", err)}
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, members_doers)

