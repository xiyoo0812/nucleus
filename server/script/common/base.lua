--base.lua

require("common.math")
require("common.table")
require("common.string")
require("common.logger")
require("common.class")
require("common.interface")
require("common.property")

--创建全局监听器
local Listener = require("common.listener")
nucleus.listener = Listener()
