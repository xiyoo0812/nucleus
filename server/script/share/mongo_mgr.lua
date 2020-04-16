--mongo_mgr.lua
local mongol        = require("resty.mongol")
local MONGO_CFGS    = require("config.mongo_cfg")

local pcall         = pcall
local tinsert       = table.insert
local log_err       = logger.err
local log_info      = logger.info
local env_number    = environ.number

local SUCCESS       = 0
local MONGO_FAILED  = -1

local MongoMgr = singleton()
function MongoMgr:__init()
    self.mongo_svrs = {}
    self:setup()
end

--初始化
function MongoMgr:setup()
    local cfg_id = env_number("ENV_MONGO_GROUP")
    if MONGO_CFGS[cfg_id] then
        for id, dbconf in pairs(MONGO_CFGS[cfg_id]) do
            self.mongo_svrs[id] = {cfg = dbconf}
        end
    else
        log_err("mongo config %d is nil!!", cfg_id)
    end
end

function MongoMgr:create_db(id, node)
    if not node.conn then
        local conn = mongol:new()
        local ok, err = conn:connect(node.cfg.host, node.cfg.port or 27017)
        if not ok then
            log_err("mongo create db %d->(host:%s) failed: %s", id, node.cfg.host, err)
            return
        end
        node.conn = conn
    end
    if node.conn then
        local db_name = node.cfg.db
        log_info("mongo db %d->(host:%s, db=%s) has ready!", id, node.cfg.host, db_name)
        node.db = node.conn:new_db_handle(db_name)
        return node.db
    end
end

--查找mongo collection
function MongoMgr:find_collection(dbid, coll_name)
    local node = self.mongo_svrs[dbid]
    if node then
        if not node.db then
            self:create_db(dbid, node)
        end
        if node.db then
            return node.db:get_col(coll_name)
        end
    end
end

function MongoMgr:mongo_find(dbid, coll_name, selector, fields, sorts, limit)
    local do_find = function()
        local collection = self:find_collection(dbid, coll_name)
        if collection then
            local result = {}
            local cursor = collection:find(selector, fields)
            if sorts then cursor:sort(table.unpack(sorts)) end
            if limit then cursor:limit(limit) end
            for index, item in cursor:pairs() do
                tinsert(result, item)
            end
            return SUCCESS, result
        end
        return MONGO_FAILED, "mongo db not exist"
    end
    local ok, code, result = pcall(do_find)
    if not ok then
        result = code
        code   = MONGO_FAILED
    end
    return code, result
end

function MongoMgr:mongo_find_one(dbid, coll_name, selector, fields)
    local collection = self:find_collection(dbid, coll_name)
    if collection then
        local result = collection:find_one(selector, fields)
        if result then
            return SUCCESS, result
        else
            return MONGO_FAILED
        end
    end
    return MONGO_FAILED, "mongo db not exist"
end

function MongoMgr:mongo_insert(dbid, coll_name, obj)
    local collection = self:find_collection(dbid, coll_name)
    if collection then
        local res, err = collection:insert(obj, 0, 1)
        if not err then
            return SUCCESS
        else
            return MONGO_FAILED, err
        end
    end
    return MONGO_FAILED, "mongo db not exist"
end

function MongoMgr:mongo_update(dbid, coll_name, obj, selector, upsert, multi)
    local collection = self:find_collection(dbid, coll_name)
    if collection then
        local res, err = collection:update(selector, obj, upsert, multi, 1)
        if not err then
            return SUCCESS
        else
            return MONGO_FAILED, err
        end
    end
    return MONGO_FAILED, "mongo db not exist"
end

function MongoMgr:mongo_delete(dbid, coll_name, selector, single)
    local collection = self:find_collection(dbid, coll_name)
    if collection then
        local res, err = collection:delete(selector, single, 1)
        if not err then
            return SUCCESS
        else
            return MONGO_FAILED, err
        end
    end
    return MONGO_FAILED, "mongo db not exist"
end

nucleus.mongo_mgr = MongoMgr()

return MongoMgr
