--environ.lua
local pairs         = pairs
local tonumber      = tonumber
local ogetenv       = os.getenv
local log_debug     = logger.debug
local tunpack       = table.unpack
local ssplit        = string_ex.split

local ENV = {
    -- mongo group
    ENV_MONGO_ADDR         = "pm_admin@10.72.17.44",
}

environ = {}

--custom_env: --env=env/router
function environ.init(env_file)
    if env_file then
        local custom_env = require(env_file)
        for key, value in pairs(custom_env or {}) do
            ENV[key] = value
        end
    end
    log_debug("---------------------environ value dump-------------------")
    for key, _ in pairs(ENV) do
        log_debug("%s ----> %s", key, environ.get(key))
    end
    log_debug("----------------------------------------------------------")
end

function environ.get(key)
    return ogetenv(key) or ENV[key]
end

function environ.number(key)
    return tonumber(ogetenv(key) or ENV[key] or 0)
end

function environ.status(key)
    return (tonumber(ogetenv(key) or ENV[key] or 0) > 0)
end

function environ.addr(key)
    local addr = ogetenv(key) or ENV[key]
    if addr then
        return tunpack(ssplit(addr, ":"))
    end
end

function environ.table(key, str)
    return ssplit(ogetenv(key) or ENV[key] or "", str or ",")
end

function environ.db(key)
    local db_host, port = environ.addr(key)
    if db_host then
        local db, host = tunpack(ssplit(db_host, "@"))
        return db, host, port
    end
end
