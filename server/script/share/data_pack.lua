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
        remarks    = data.remarks or "",
    }
end

function data_pack.project(data)
    return {
        id          = data.id,
        name        = data.name or "",
        admin       = data.admin or "",
        desc        = data.desc or "",
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
