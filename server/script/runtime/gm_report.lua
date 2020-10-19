-- api/gm_report.lua
local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local proj_db   = nucleus.proj_db
local admin_db  = nucleus.admin_db

--定义接口
local gm_report_doers = {
    GET = function(req, params, session)
        --获取项目申请列表
        log_debug("/gm_report GET params: %s", serialize(params))
        local records = {}
        local res = proj_db:find("gm_reports", {}, {_id = 0})
        for k, mem in pairs(res) do
            tinsert(records, mem)
        end
        return { code = 0, data = records, total = #records }
    end,
    POST = function(req, params, session)
        --批准申请
        log_debug("/gm_report POST params: %s", serialize(params))
        local gm_report = params.args
        local record = proj_db:find_one("gm_reports", {en_name = gm_report.en_name})
        if not record then
            return {code = -1, msg = "gm_report not exist"}
        end
        local ok, err = proj_db:delete("gm_reports", {en_name = gm_report.en_name })
        if not ok then
            return {code = -1, msg = sformat("db update failed: %s", err)}
        end
        if gm_report.sure then
            local project = session.data.project
            local ok1, err1 = admin_db:insert("member_projs", { {en_name = gm_report.en_name, proj_id = project.id } })
            if not ok1 then
                return { code = -1, msg = sformat("member_projs insert failed:%s", err1)}
            end
            local ok2, err2 = proj_db:insert("members", { gm_report })
            if not ok2 then
                return { code = -1, msg = sformat("members insert failed:%s", err2)}
            end
        end
        return { code = 0, data = gm_report }
    end,
}

--执行
apidoer(ngx.req, gm_report_doers)

