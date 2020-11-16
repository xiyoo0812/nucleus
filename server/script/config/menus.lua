--config/menus.lua

local MENUS = {
    {
        icon = "el-icon-lx-home",
        index = "dashboard",
        title = "主页"
    },
    {
        index = 1,
        icon = "el-icon-lx-service",
        title = "项目",
        subs =  {
            {
                index = "members",
                title = "成员列表",
            },
            {
                index = "applys",
                title = "申请队列",
                admin = 1,
            },
            {
                index = "auths",
                title = "权限设置",
                admin = 1,
            },
            {
                index = "projects",
                title = "所有项目",
            },
            {
                index = "owns",
                title = "我的项目",
            },
        },
    },
    {
        index = 2,
        icon = "el-icon-lx-apps",
        title = "资源",
        subs =  {
            {
                index = "hosts",
                title = "主机"
            },
            {
                index = "authkeys",
                title = "凭证"
            },
            {
                index = "databases",
                title = "数据库"
            },
            {
                index = "codes",
                title = "代码库"
            },
            {
                index = "routers",
                title = "路由表"
            },
            {
                index = "playbooks",
                title = "Playbook"
            },
            {
                index = "images",
                title = "镜像"
            },
            {
                index = "nodes",
                title = "节点"
            },
            {
                index = "environs",
                title = "环境"
            },
        }
    },
    {
        index = 3,
        icon = "el-icon-lx-service",
        title = "运维",
        subs =  {
            {
                index = "plugins",
                title = "插件"
            },
            {
                index = "pipelines",
                title = "流水线"
            },
            {
                index = "products",
                title = "制品库"
            },
            {
                index = "gmcmd",
                title = "GM指令"
            },
            {
                index = "onlog",
                title = "在线日志"
            },
            {
                index = "offlog",
                title = "离线日志"
            }
        }
    },
    {
        index = 4,
        icon = "el-icon-lx-service",
        title = "运营",
        subs =  {
            {
                index = "platform",
                title = "平台配置"
            },
            {
                index = "partition",
                title = "小区配置"
            },
            {
                index = "notice",
                title = "公告"
            },
            {
                index = "marquee",
                title = "跑马灯"
            },
            {
                index = "activecode",
                title = "激活码"
            },
            {
                index = "roster",
                title = "黑白名单"
            },
            {
                index = "emial",
                title = "邮件管理"
            }
        },
    },
    {
        index = 5,
        icon = "el-icon-lx-service",
        title = "监控",
        subs =  {
            {
                index = "host_monitor",
                title = "主机监控"
            },
            {
                index = "node_monitor",
                title = "节点监控"
            },
        },
    },
}

return MENUS
