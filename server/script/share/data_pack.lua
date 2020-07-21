--data_pack.lua
--提供接口序列号功能

data_pack = {}

function data_pack.user(data)
    return {
        en_name    = data.en_name,
        avatar     = data.avatar,
        name       = data.name or "",
        email      = data.email or "",
        empCode    = data.empCode or "",
        dept       = data.dept or "",
        type       = data.type or 0,
        roles      = data.roles or {},
        remarks    = data.remarks or "",
    }
end

function data_pack.role(data)
    return {
        id          = data.id,
        project     = data.project or 0,
        name        = data.name or "",
        en_name     = data.en_name or "",
        resources   = data.resources or {},
    }
end

function data_pack.resource(data)
    return {
        id          = data.id,
        path        = data.path or "",
        name        = data.name or "",
        method      = data.method or {},
        project     = data.project or 0,
        remarks     = data.remarks or "",
    }
end
