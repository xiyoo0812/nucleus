--config/menus.lua

local MENUS = {
    {
        icon = "el-icon-lx-home",
        index = "dashboard",
        title = "系统首页"
    },
    {
        index = 1,
        icon = "el-icon-lx-apps",
        title = "资源管理",
        subs =  {
            {
                index = "hosts",
                title = "主机管理"
            },
            {
                index = "databases",
                title = "数据库管理"
            },
            {
                index = "keys",
                title = "密钥管理"
            },
            {
                index = "codes",
                title = "代码管理"
            },
            {
                index = "nodes",
                title = "节点管理"
            },
            {
                index = "images",
                title = "镜像管理"
            },
        }
    },
    {
        index = 2,
        icon = "el-icon-lx-service",
        title = "运营管理",
        subs =  {
            {
                index = "platform_list",
                title = "账号平台列表"
            },
            {
                index = "partition_list",
                title = "小区列表"
            },
            {
                index = "notice_list",
                title = "公告列表"
            },
            {
                index = "marquee_list",
                title = "跑马灯列表"
            },
            {
                index = "active_code",
                title = "账号激活码管理"
            },
            {
                index = "black_list",
                title = "黑白名单管理"
            },
            {
                index = "mail_mgr",
                title = "邮件管理"
            }
        }
    },
    {
        index = 3,
        icon = "el-icon-lx-service",
        title = "运维管理",
        subs =  {
            {
                index = "package",
                title = "版本打包"
            },
            {
                index = "hotfix",
                title = "热更新"
            },
            {
                index = "mondeploy",
                title = "版本部署"
            },
            {
                index = "deploy",
                title = "Hive管理"
            },
            {
                index = "dsdeploy",
                title = "Ds监控"
            },
            {
                index = "gmcmd",
                title = "GM指令"
            },
            {
                index = "log",
                title = "在线日志"
            }
        }
    },
    {
        index = 4,
        icon = "el-icon-lx-service",
        title = "项目管理",
        subs =  {
            {
                index = "projlist",
                title = "项目管理"
            },
            {
                index = "authlist",
                title = "权限管理"
            },
            {
                index = "userlist",
                title = "用户管理"
            },
        }
    }
}

return MENUS
