--ansible.lua
local json      = require "cjson.safe"

local ssub      = string.sub
local smatch    = string.match
local sformat   = string.format
local ssplit    = string_ex.split
local sexecute  = shell.execute
local jdecode   = json.decode

ansible = {}

local function parse_ansible_res(output)
    local cur_task
    local ansible_res = {}
    local lines = ssplit(output, "\n")
    for _, line in ipairs(lines) do
        if cur_task then
            local out_token = smatch(line, '=> {.+}')
            if out_token then
                local out_res = jdecode(ssub(out_token, 3))
                if not out_res.skipped then
                    ansible_res[cur_task] = {
                        cmd = out_res.cmd,
                        delta = out_res.delta,
                        stdout = out_res.stdout,
                        stderr = out_res.stderr,
                    }
                end
                cur_task = nil
            end
        else
            local task_token = smatch(line, 'TASK %[.+%]')
            if task_token then
                cur_task = ssub(task_token, 7, #task_token - 1)
            end
        end
    end
    return ansible_res
end

local call_shell = function(host, cmd, timeout)
    local ansible_cmd = sformat([[cd /; ansible %s -m shell -a "%s" -v]], host, cmd)
    local ok, std_out = sexecute(ansible_cmd, timeout)
    local res = parse_ansible_res(std_out)
    return ok, res
end

local call_playbook = function(book, args, timeout)
    local fargs = ""
    for key, value in pairs(args or {}) do
        fargs = sformat("%s%s=%s ", fargs, key, value)
    end
    local ansible_cmd = sformat([[cd /; ansible-playbook %s --extra-vars "%s" -v]], book, fargs)
    local ok, std_out = sexecute(ansible_cmd, timeout)
    local res = parse_ansible_res(std_out)
    return ok, res
end

ansible.shell       = call_shell
ansible.playbook    = call_playbook
