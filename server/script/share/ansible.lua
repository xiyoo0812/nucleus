--ansible.lua
local json      = require "cjson.safe"

local jdecode   = json.decode
local sexecute  = shell.execute
local tinsert   = table.insert
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
        if not out_res.skip_reason then
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

local function parse_playbook_res(output, stderr)
    local ansible_res = { stdout = output }
    local segments = ssplit(output, "\n\n")
    for _, segment in ipairs(segments) do
        local task_name = smatch(segment, 'TASK %[(%C+)%]')
        if task_name then
            local task_res = parse_task_res(segment)
            if task_res then
                if task_name == "output" then
                    ansible_res[task_name] = task_res
                else
                    tinsert(ansible_res, task_res)
                end
            end
        end
    end
    return ansible_res
end

local call_shell = function(host, cmd, timeout)
    local ansible_cmd = sformat([[cd /; export LANG=C.UTF-8; ansible %s -m shell -a "%s" -v]], host, cmd)
    local ok, stdout, stderr = sexecute(ansible_cmd, timeout)
    if ok then
        return ok, parse_shell_res(stdout)
    end
    return ok, sformat("stdout: %s\nstderr: %s\n", stdout, stderr)
end

local function call_playbook_file(book_file, args, timeout)
    local fargs = ""
    for key, value in pairs(args or {}) do
        if type(value) ~= "table" then
            fargs = sformat("%s%s=%s ", fargs, key, value)
        end
    end
    local ansible_cmd = sformat([[cd /; export LANG=C.UTF-8; ansible-playbook %s --extra-vars "%s" -v]], book_file, fargs)
    local ok, stdout, stderr = sexecute(ansible_cmd, timeout)
    if ok then
        return ok, parse_playbook_res(stdout, stderr)
    end
    return ok, sformat("stdout: %s\nstderr: %s\n", stdout, stderr)
end

local function call_playbook(playbook, args, timeout)
    local book_file = sformat("/tmp/%s.yaml", playbook.name)
    local hscript = sgsub(playbook.script, "$HOST", args.host)
    local script = sgsub(hscript, "$COMMAND", args.command)
    local real_script = sgsub(script, '"', '\\"')
    local ok, res = sexecute(sformat([[echo "%s" > %s]], real_script, book_file))
    if not ok then
        return false, res
    end
    return call_playbook_file(book_file, args, timeout)
end

local function call_playbook_name(book_name, args, timeout)
    local playbook = admin_db:find_one("playbooks", {name = book_name}, {_id = 0})
    if not playbook then
        return false, "playbook config not exist!"
    end
    return call_playbook(playbook, args, timeout)
end

local function call_playbook_id(book_id, args, timeout)
    local playbook = admin_db:find_one("playbooks", {id = book_id}, {_id = 0})
    if not playbook then
        return false, "playbook config not exist!"
    end
    return call_playbook(playbook, args, timeout)
end

ansible.shell       = call_shell
ansible.playbook    = call_playbook
ansible.playbookid  = call_playbook_id
ansible.playbookf   = call_playbook_file
ansible.playbookn   = call_playbook_name
