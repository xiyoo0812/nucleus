--root.lua

--公共模块在这里声明
--注意这里是整个系统的初始化

--定义全局命名空间
nucleus = {}

--common
require ("common.base")

--初始化环境变量
require ("share.environ")
environ.init("config.nucleus")

--share
require ("share.shell")
require ("share.mongod")
require ("share.ansible")
require ("share.utility")

