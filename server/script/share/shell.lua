--shell.lua
local lshell    = require "resty.shell"

local shrun     = lshell.run
local log_err   = logger.err
--local log_debug = logger.debug

local MAX_SIZE  = 10 * 1024 * 1024

shell = {}
local execute_shell = function(cmd, timeout, max_size, stdin)
    --ok, stdout, stderr, reason, status = shell.run(cmd, stdin?, timeout?, max_size?)
    local ok, stdout, stderr, reason, status = shrun(cmd, stdin, timeout, MAX_SIZE)
    if not ok then
        log_err("run [%s] failed: status: %s, out:%s, err:%s, reason=%s", cmd, status, stdout, stderr, reason)
        if reason == "exit" then
            return false, stdout, stderr
        end
        return false, stdout, reason
    end
    --log_debug("run [%s] result: status: %s, out:%s, err:%s, reason=%s", cmd, status, stdout, stderr, reason)
    return true, stdout, stderr
end

shell.execute   = execute_shell
