-- api/node_status.lua
local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db
local admin_db  = nucleus.admin_db

--定义接口
local node_status_doers = {
    GET = function(req, params, session)
        --获取项目申请列表
        log_debug("/node_status GET params: %s", serialize(params))
        local records = {}
        local res = proj_db:find("node_statuss", {}, {_id = 0})
        for k, mem in pairs(res) do
            tinsert(records, mem)
        end
        return { code = 0, data = records, total = #records }
    end,
    POST = function(req, params, session)
        --批准申请
        log_debug("/node_status POST params: %s", serialize(params))
        local node_status = params.args
        local record = proj_db:find_one("node_statuss", {en_name = node_status.en_name})
        if not record then
            return {code = -1, msg = "node_status not exist"}
        end
        local ok, err = proj_db:delete("node_statuss", {en_name = node_status.en_name })
        if not ok then
            return {code = -1, msg = sformat("db update failed: %s", err)}
        end
        if node_status.sure then
            local project = session.data.project
            local ok1, err1 = admin_db:insert("member_projs", { {en_name = node_status.en_name, proj_id = project.id } })
            if not ok1 then
                return { code = -1, msg = sformat("member_projs insert failed:%s", err1)}
            end
            local ok2, err2 = proj_db:insert("members", { node_status })
            if not ok2 then
                return { code = -1, msg = sformat("members insert failed:%s", err2)}
            end
        end
        return { code = 0, data = node_status }
    end,
}

--执行
apidoer(ngx.req, node_status_doers)

