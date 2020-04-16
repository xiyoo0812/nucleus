--environ.lua
local pairs       = pairs
local tonumber    = tonumber
local ogetenv     = os.getenv
local tunpack     = table.unpack
local sformat     = string.format
local ssplit      = string_ex.split

local ENV = {
    -- mongo group
    ENV_MONGO_GROUP         = "1",
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
    ngix.log(ngix.DEBUG, "---------------------environ value dump-------------------")
    for key, _ in pairs(ENV) do
        ngix.log(ngix.DEBUG, sformat("%s ----> %s", key, environ.get(key)))
    end
    ngix.log(ngix.DEBUG, "----------------------------------------------------------")
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
