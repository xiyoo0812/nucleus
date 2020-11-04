--shell.lua
local lshell    = require "resty.shell"

local shrun     = lshell.run
local log_err   = logger.err
--local log_debug = logger.debug

shell = {}
local execute_shell = function(cmd, timeout, max_size, stdin)
    --ok, stdout, stderr, reason, status = shell.run(cmd, stdin?, timeout?, max_size?)
    local ok, stdout, stderr, reason, status = shrun(cmd, stdin, timeout, max_size)
    if not ok then
        log_err("run [%s] failed: status: %s, out:%s, err:%s, reason=%s", cmd, status, stdout, stderr, reason)
        if reason == "exit" then
            return false, stderr
        end
        return false, reason
    end
    --log_debug("run [%s] result: status: %s, out:%s, err:%s, reason=%s", cmd, status, stdout, stderr, reason)
    return true, stdout
end

shell.execute   = execute_shell
