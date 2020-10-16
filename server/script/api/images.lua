-- api/images.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize

local apidoer   = utility.apidoer
local admin_db  = nucleus.admin_db

--定义接口
local images_doers = {
    GET = function(req, params, session)
        log_debug("/images GET params: %s", serialize(params))
        local res = admin_db:find("images", {}, {_id = 0})
        local records = {}
        for k, image in pairs(res) do
            tinsert(records, image)
        end
        return { code = 0, data = records, total = #records }
    end,
    POST = function(req, params, session)
        log_debug("/images POST params: %s", serialize(params))
        local image = params.args
        local res = admin_db:find_one("images", { name = image.name })
        if res and res.id ~= image.id then
            return { code = -1, msg = "image name aready exist!" }
        end
        local record = admin_db:find_one("images", {id = image.id})
        if not record then
            return {code = -1, msg = "image not exist"}
        end
        image.creator = session.data.user.name
        local ok, err = admin_db:update("images", image, { id = image.id })
        if not ok then
            return {code = -1, msg = sformat("db update failed: %s", err)}
        end
        return { code = 0, data = image }
    end,
    PUT = function(req, params, session)
        log_debug("/images PUT params: %s", serialize(params))
        local image = params.args
        local res = admin_db:find_one("images", { name = image.name })
        if res then
            return { code = -1, msg = "image name aready exist!" }
        end
        image.creator = session.data.user.name
        local ok, err = admin_db:insert("images", { image })
        if not ok then
            return { code = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { code = 0, data = image }
    end,
    DELETE = function(req, params, session)
        log_debug("/images DELETE params: %s", serialize(params))
        local image_id = params.args
        local ok, err = admin_db:delete("images", { id = image_id })
        if not ok then
            return {code = -1, msg = sformat("db delete failed: %s", err)}
        end
        return { code = 0 }
    end,
}

--执行
apidoer(ngx.req, images_doers)

