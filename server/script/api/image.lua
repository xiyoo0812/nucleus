-- api/image.lua
local json = require "cjson.safe"
json.encode_sparse_array(true)

local jdecode   = json.decode
local tinsert   = table.insert
local sformat   = string.format
local log_debug = logger.debug
local serialize = logger.serialize
local packimage = data_pack.image

local apidoer   = utility.apidoer
local mongod    = nucleus.mongod

--定义接口
local image_doers = {
    GET = function(req, args)
        log_debug("/image GET params: %s", serialize(args))
        local res = mongod:find("images", {})
        local records = {}
        for k, v in pairs(res) do
            tinsert(records, packimage(v))
        end
        return { image = 0, data = records, total = #records }
    end,
    POST = function(req, args)
        log_debug("/image POST params: %s", serialize(args))
        local image = jdecode(args.image)
        local record = mongod:find_one("images", {name = image.name})
        if not record then
            return {image = -1, msg = "image not exist"}
        end
        local ok, err = mongod:update("images", image, { name = image.name })
        if not ok then
            return {image = -1, msg = sformat("db update failed: %s", err)}
        end
        return { image = 0, data = image }
    end,
    PUT = function(req, args)
        log_debug("/image PUT params: %s", serialize(args))
        local image = jdecode(args.image)
        local res = mongod:find_one("images", { name = image.name })
        if res then
            return { image = -1, msg = "name aready exist!" }
        end
        local ok, err = mongod:insert("images", { image })
        if not ok then
            return { image = -1, msg = sformat("db insert failed:%s", err)}
        end
        return { image = 0, data = image }
    end,
    DELETE = function(req, args)
        log_debug("/image DELETE params: %s", serialize(args))
        local images = args.images
        if type(images) == "string" then
            local ok, err = mongod:delete("images", { name = images })
            if not ok then
                return {image = -1, msg = sformat("db delete failed: %s", err)}
            end
        else
            for _, cname in pairs(images) do
                local ok, err = mongod:delete("images", { name = cname })
                if not ok then
                    return {image = -1, msg = sformat("db delete failed: %s", err)}
                end
            end
        end
        return { image = 0 }
    end,
}

--执行
apidoer(ngx.req, image_doers)

