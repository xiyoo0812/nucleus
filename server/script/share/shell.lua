--shell.lua
local lshell    = require "resty.shell"

local log_err   = logger.err
local sformat   = string.format
local sexecute  = lshell.execute

local lsargs    = { socket = "unix:/tmp/shell.sock" }

shell = {}
local call_shell = function(cmd)
    local status, out, err = sexecute(cmd, lsargs)
    if status ~= 0 then
        log_err("execute [%s] shell failed: status: %s, out:%s, err:%s", cmd, status, out, err)
        return false, err
    end
    return true, out
end

local call_ansible = function(host, cmd)
    local ansible_cmd = sformat([[ansible %s -m shell -a "%s"]], host, cmd)
    return call_shell(ansible_cmd)
end

shell.call      = call_shell
shell.ansible   = call_ansible
