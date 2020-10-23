--ansible.lua
local json      = require "cjson.safe"

local log_info  = logger.info
local jdecode   = json.decode
local sexecute  = shell.execute
local sgsub     = string.gsub
local smatch    = string.match
local sformat   = string.format
local ssplit    = string_ex.split
local admin_db  = nucleus.admin_db

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

local function parse_task_res(segment)
    local out_token = smatch(segment, '=> ({.+})')
    if out_token then
        local out_res = jdecode(out_token)
        log_info("parse_task_res: %s-%s", out_token, logger.serialize(out_res))
        if not out_res.skipped then
            return {
                msg = out_res.msg,
                cmd = out_res.cmd,
                delta = out_res.delta,
                stdout = out_res.stdout,
                stderr = out_res.stderr,
            }
        end
    end
end

local function parse_playbook_res(output)
    local ansible_res = {}
    local segments = ssplit(output, "\n\n")
    for _, segment in ipairs(segments) do
        local task_name = smatch(segment, 'TASK %[(%C+)%]')
        if task_name then
            local task_res = parse_task_res(segment)
            if task_res then
                ansible_res[task_name] = task_res
            end
        end
    end
    return ansible_res
end

local call_shell = function(host, cmd, timeout)
    local ansible_cmd = sformat([[cd /; export LANG=C.UTF-8; ansible %s -m shell -a "%s" -v]], host, cmd)
    local ok, std_out = sexecute(ansible_cmd, timeout)
    local res = parse_shell_res(std_out)
    return ok, res
end

local call_playbook = function(book, args, timeout)
    local fargs = ""
    for key, value in pairs(args or {}) do
        if type(value) ~= "table" then
            fargs = sformat("%s%s=%s ", fargs, key, value)
        end
    end
    local ansible_cmd = sformat([[cd /; export LANG=C.UTF-8; ansible-playbook %s --extra-vars "%s" -v]], book, fargs)
    local ok, std_out = sexecute(ansible_cmd, timeout)
    local res = parse_playbook_res(std_out)
    log_info("parse_playbook_res: %s", logger.serialize(res))
    return ok, res
end


local function call_playbookid(playbook, args, timeout)
    local playbook_rd = admin_db:find_one("playbooks", {id = playbook}, {_id = 0})
    if not playbook_rd then
        return false, "playbook config not exist!"
    end
    local book_name = sformat("/tmp/%s.yaml", playbook)
    local script = sgsub(playbook_rd.script, "$HOST", args.host)
    local real_script = sgsub(script, '"', '\\"')
    local ok, res = sexecute(sformat([[echo "%s" > %s]], real_script, book_name))
    if not ok then
        return false, res
    end
    return call_playbook(book_name, args, timeout)
end

ansible.shell       = call_shell
ansible.playbook    = call_playbook
ansible.playbookid  = call_playbookid
