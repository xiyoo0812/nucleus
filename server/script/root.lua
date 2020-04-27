--root.lua

--公共模块在这里声明
--注意这里是整个系统的初始化

--定义全局命名空间
nucleus = {}

--common
require ("common.base")
--share
require ("share.environ")
require ("share.mongod")
require ("share.utility")

--初始化环境变量
environ.init("config.nucleus")
