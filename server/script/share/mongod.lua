--mongo_mgr.lua
local mongol    = require("resty.mongol")

local tunpack   = table.unpack
local tinsert   = table.insert
local log_err   = logger.err
local env_db    = environ.db
local env_get   = environ.get

local mongod = singleton()
function mongod:__init()
    self:setup()
end

--初始化
function mongod:setup()
    local db, host, port = env_db("ENV_MONGO_ADDR")
    if not db or not host then
        log_err("ENV_MONGO_ADDR config %s is vaild!!", env_get("ENV_MONGO_ADDR"))
        return
    end
    self.host = host
    self.port = port
    self.db = db
end

function mongod:get_coll(coll_name)
    if not self.host then
        return
    end
    local conn = mongol:new()
    local ok, err = conn:connect(self.host, self.port or 27017)
    if not ok then
        log_err("mongodb (host:%s) connect failed: %s", self.host, err)
        return
    end
    local db = conn:new_db_handle(self.db)
    if db then
        return db:get_col(coll_name)
    end
end

function mongod:find(coll_name, selector, fields, sorts, limit)
    local coll = self:get_coll(coll_name)
    if coll then
        local result = {}
        local cursor = coll:find(selector, fields)
        if sorts then cursor:sort(tunpack(sorts)) end
        if limit then cursor:limit(limit) end
        for index, item in cursor:pairs() do
            tinsert(result, item)
        end
        return result
    end
end

function mongod:find_one(coll_name, selector, fields)
    local coll = self:get_coll(coll_name)
    if coll then
        return coll:find_one(selector, fields)
    end
end

function mongod:insert(coll_name, obj)
    local coll = self:get_coll(coll_name)
    if coll then
        local _, err = coll:insert(obj, 0, 1)
        return (err == nil)
    end
    return false
end

function mongod:update(coll_name, obj, selector, upsert, multi)
    local coll = self:get_coll(coll_name)
    if coll then
        local _, err = coll:update(selector, obj, upsert, multi, 1)
        return (err == nil)
    end
    return false
end

function mongod:delete(coll_name, selector, single)
    local coll = self:get_coll(coll_name)
    if coll then
        local _, err = coll:delete(selector, single, 1)
        return (err == nil)
    end
    return false
end

nucleus.mongod = mongod()

return mongod
