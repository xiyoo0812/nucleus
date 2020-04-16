--logger.lua
--logger功能支持
local pairs         = pairs
local tostring      = tostring
local ngx_log       = ngx.log
local sformat       = string.format
local tinsert       = table.insert
local tconcat       = table.concat
local tarray        = table_ex.is_array

logger = {}

local LOG_LEVEL_OFF     = 100   -- 关闭所有消息输出
local LOG_LEVEL_DEBUG   = 1     -- 用于调试消息的输出
local LOG_LEVEL_INFO    = 2     -- 用于跟踪程序运行进度
local LOG_LEVEL_WARN    = 3     -- 程序运行时发生异常
local LOG_LEVEL_ERROR   = 4     -- 程序运行时发生可预料的错误,此时通过错误处理,可以让程序恢复正常运行

local log_lvl           = LOG_LEVEL_DEBUG

function logger.level(level)
    log_lvl = level
end

function logger.off(level)
    log_lvl = LOG_LEVEL_OFF
end

function logger.debug(fmt, ...)
    if log_lvl <= LOG_LEVEL_DEBUG then
        ngx_log(ngx.DEBUG, sformat(fmt, ...))
    end
end

function logger.info(fmt, ...)
    if log_lvl <= LOG_LEVEL_INFO then
        ngx_log(ngx.INFO, sformat(fmt, ...))
    end
end

function logger.warn(fmt, ...)
    if log_lvl <= LOG_LEVEL_WARN then
        ngx_log(ngx.WARN, sformat(fmt, ...))
    end
end

function logger.err(fmt, ...)
    if log_lvl <= LOG_LEVEL_ERROR then
        ngx_log(ngx.ERR, sformat(fmt, ...))
    end
end

function logger.serialize(tab)
    if log_lvl > LOG_LEVEL_DEBUG then
        return tab
    end
    local mark = {}
    local assign = {}
    local function table2str(t, parent)
        local ret = {}
        mark[t] = parent
        local function array2str()
            for i, v in pairs(t) do
                local k = tostring(i)
                local dotkey = parent .. "[" .. k .. "]"
                local tpe = type(v)
                if tpe == "table" then
                    if mark[v] then
                        tinsert(assign, dotkey .. "=" .. mark[v])
                    else
                        tinsert(ret, table2str(v, dotkey))
                    end
                elseif tpe == "string" then
                    tinsert(ret, sformat("%q", v))
                elseif tpe == "number" then
                    if v == math.huge then
                        tinsert(ret, "math.huge")
                    elseif v == -math.huge then
                        tinsert(ret, "-math.huge")
                    else
                        tinsert(ret, tostring(v))
                    end
                else
                    tinsert(ret, tostring(v))
                end
            end
        end
        local function map2str()
            for f, v in pairs(t) do
                local k = type(f) == "number" and "[" .. f .. "]" or f
                local dotkey = parent .. (type(f) == "number" and k or "." .. k)
                local tpe = type(v)
                if tpe == "table" then
                    if mark[v] then
                        tinsert(assign, dotkey .. "=" .. mark[v])
                    else
                        tinsert(ret, sformat("%s=%s", k, table2str(v, dotkey)))
                    end
                elseif tpe == "string" then
                    tinsert(ret, sformat("%s=%q", k, v))
                elseif tpe == "number" then
                    if v == math.huge then
                        tinsert(ret, sformat("%s=%s", k, "math.huge"))
                    elseif v == -math.huge then
                        tinsert(ret, sformat("%s=%s", k, "-math.huge"))
                    else
                        tinsert(ret, sformat("%s=%s", k, tostring(v)))
                    end
                else
                    tinsert(ret, sformat("%s=%s", k, tostring(v)))
                end
            end
        end

        if tarray(t) then
            array2str()
        else
            map2str()
        end
        return "{" .. tconcat(ret,",") .. "}"
    end
    if type(tab) == "table" then
        return sformat("%s%s",  table2str(tab,"_"), tconcat(assign," "))
    else
        return tostring(tab)
    end
end

return logger
