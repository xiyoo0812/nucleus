--ansible.lua
local json      = require "cjson.safe"

local smatch    = string.match
local sformat   = string.format
local ssplit    = string_ex.split
local sexecute  = shell.execute
local jdecode   = json.decode

ansible = {}

local function parse_shell_res(output)
    local shell_res = {}
    local rc_token = smatch(output, 'rc=(%d+)')
    if rc_token then
        shell_res.code = tonumber(rc_token)
    end
    shell_res.stdout = smatch(output, '>>(.+)')
    return shell_res
end

local function parse_task_res(line)
    local out_token = smatch(line, '=> ({.+})')
    if out_token then
        local out_res = jdecode(out_token)
        if not out_res.skipped then
            return {
                cmd = out_res.cmd,
                delta = out_res.delta,
                stdout = out_res.stdout,
                stderr = out_res.stderr,
            }
        end
    end
end

local function parse_playbook_res(output)
    local cur_task
    local ansible_res = {}
    local lines = ssplit(output, "\n")
    for _, line in ipairs(lines) do
        if cur_task then
            local task_res = parse_task_res(line)
            if task_res then
                ansible_res[cur_task] = task_res
                cur_task = nil
            end
        else
            local task = smatch(line, 'TASK %[(.+)%]')
            if task then
                cur_task = task
            end
        end
    end
    return ansible_res
end

local call_shell = function(host, cmd, timeout)
    local ansible_cmd = sformat([[cd /; ansible %s -m shell -a "%s" -v]], host, cmd)
    local ok, std_out = sexecute(ansible_cmd, timeout)
    local res = parse_shell_res(std_out)
    return ok, res
end

local call_playbook = function(book, args, timeout)
    local fargs = ""
    for key, value in pairs(args or {}) do
        fargs = sformat("%s%s=%s ", fargs, key, value)
    end
    local ansible_cmd = sformat([[cd /; ansible-playbook %s --extra-vars "%s" -v]], book, fargs)
    local ok, std_out = sexecute(ansible_cmd, timeout)
    local res = parse_playbook_res(std_out)
    return ok, res
end

ansible.shell       = call_shell
ansible.playbook    = call_playbook
