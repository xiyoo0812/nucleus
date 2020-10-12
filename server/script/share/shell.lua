--shell.lua
local lshell    = require "resty.shell"

local log_err   = logger.err
local log_debug = logger.debug
local sformat   = string.format
local shrun     = lshell.run

shell = {}
local call_shell = function(cmd, stdin, timeout, max_size)
    --ok, stdout, stderr, reason, status = shell.run(cmd, stdin?, timeout?, max_size?)
    local ok, stdout, stderr, reason, status = shrun(cmd, stdin, timeout, max_size)
    if not ok then
        log_err("run [%s] failed: status: %s, out:%s, err:%s, reason=%s", cmd, status, stdout, stderr, reason)
        if reason == "exit" then
            return false, stderr
        end
        return false, reason
    end
    log_debug("run [%s] result: status: %s, out:%s, err:%s, reason=%s", cmd, status, stdout, stderr, reason)
    return true, stdout
end

local call_ansible = function(host, cmd)
    local ansible_cmd = sformat([[ansible %s -m shell -a "%s"]], host, cmd)
    return call_shell(ansible_cmd)
end

shell.call      = call_shell
shell.ansible   = call_ansible
