<template>
<div class="app-container">
    <h3>节点管理</h3>
    <el-alert :closable="false" title="管理当前节点列表" type="success"/>
    <div class="twt-tool-box">
        <el-button-group>
            <el-button class="filter-item" type="primary" @click="handleCreate">添加</el-button>
            <el-button v-waves :loading="downloadLoading" class="filter-item" @click="handleDownload">导出</el-button>
        </el-button-group>
    </div>
    <el-row style="padding-left:15px;padding-top:30px" class="tool-box">
        <el-form ref="searchForm" :inline="true" :model="search" class="demo-form-inline">
            <el-form-item label="主机" prop="host_id">
                <HostSelect ref="HostSelect" :form="search" prop="host_id" @change="filterNodes"/>
            </el-form-item>
            <el-form-item label="服务器组" prop="group">
                <GroupSelect ref="groupSelect" :form="search" prop="group" @change="filterNodes"/>
            </el-form-item>
        </el-form>
    </el-row>
    <el-row>
        <el-table :data="filters" :row-key="getRowKeys" stripe border style="width: 100%">
            <el-table-column label="主机">
                <template slot-scope="scope">
                    <span style="margin-left: 10px">{{ scope.row.host_ip }}</span>
                </template>
            </el-table-column>
            <el-table-column label="服务器组">
                <template slot-scope="scope">
                    <div slot="reference" class="name-wrapper">{{ scope.row.group }}</div>
                </template>
            </el-table-column>
            <el-table-column label="索引">
                <template slot-scope="scope">
                    <div slot="reference" class="name-wrapper">{{ scope.row.index }}</div>
                </template>
            </el-table-column>
            <el-table-column :width="300" label="启动脚本">
                <template slot-scope="scope">
                    <div slot="reference" class="name-wrapper">{{ scope.row.script }}</div>
                </template>
            </el-table-column>
            <el-table-column label="操作">
                <template slot-scope="scope">
                    <el-button size="mini" @click="handleUpdate(scope.row)">编辑</el-button>
                    <el-button size="mini" type="danger" @click="handleDelete(scope.row)">删除</el-button>
                </template>
            </el-table-column>
        </el-table>
    <el-row/>
    <el-dialog :title="textMap[dialogStatus]" :visible.sync="dialogFormVisible" :close-on-click-modal="false" width="60%">
        <el-form v-loading="formLoadingVisible" ref="dataForm" :rules="rules" :model="form" label-position="left" label-width="100px" style="margin-left:50px;">
            <el-tabs value="base" type="border-card" style="height: 450px;">
                <el-tab-pane label="基础配置" name="base">
                    <el-form-item label="主机" prop="host_id">
                        <HostSelect ref="HostSelect" :form="form" prop="host_id" @change="selectHost"/>
                    </el-form-item>
                    <el-form-item label="服务器组" prop="group">
                        <GroupSelect ref="groupSelect" :form="form" prop="group" @change="selectGroup"/>
                    </el-form-item>
                    <el-form-item label="索引" prop="index">
                        <el-input v-model="form.index" placeholder="Index" />
                    </el-form-item>
                    <el-form-item label="启动参数" prop="script">
                        <el-input v-model="form.script" placeholder="script" />
                    </el-form-item>
                </el-tab-pane>
                <el-tab-pane label="环境变量" name="envs">
                    <el-form :inline="true" ref="envForm" :rules="rules2" :model="env" label-position="left" label-width="100px">
                        <el-form-item label="环境变量" prop="key">
                            <el-select v-model="env.key" placeholder="请选择环境变量" clearable filterable @change="selectEnv">
                                <el-option v-for="item in envList" :key="item.name" :label="item.name" :value="item.name"/>
                            </el-select>
                        </el-form-item>
                        <el-form-item label="变量值" prop="value">
                            <el-input v-model="env.value" placeholder="请输入环境变量" />
                        </el-form-item>
                        <el-button type="primary" @click="addEnv()">添加</el-button>
                    </el-form>
                    <el-table :data="envs" height="320" stripe border style="width: 100%;">
                        <el-table-column label="名称">
                            <template slot-scope="scope">
                                <span style="margin-left: 10px">{{ scope.row.key }}</span>
                            </template>
                        </el-table-column>
                        <el-table-column label="值">
                            <template slot-scope="scope">
                                <span v-if="!scope.row.edit" slot="reference" class="name-wrapper">{{ scope.row.value }}</span>
                                <span v-if="scope.row.edit" class="cell"><el-input v-model="scope.row.value"></el-input></span>
                            </template>
                        </el-table-column>
                        <el-table-column label="描述">
                            <template slot-scope="scope">
                                <div slot="reference" class="name-wrapper">{{ scope.row.desc }}</div>
                            </template>
                        </el-table-column>
                        <el-table-column label="操作">
                            <template slot-scope="scope">
                                <el-button v-if="scope.row.edit" size="mini" @click="scope.row.edit=false">保存</el-button>
                                <el-button v-if="!scope.row.edit" size="mini" @click="scope.row.edit=true">编辑</el-button>
                                <el-button size="mini" type="danger" @click="deleteEnv(scope.row)">删除</el-button>
                            </template>
                        </el-table-column>
                    </el-table>
                </el-tab-pane>
                <el-tab-pane label="端口映射" name="ports">
                    <el-form :inline="true" ref="envForm" :model="port" label-position="left" label-width="120px">
                        <el-form-item label="容器端口" prop="left">
                            <el-input v-model="port.left" placeholder="请输入容器端口" />
                        </el-form-item>
                        <el-form-item label="宿主端口" prop="right">
                            <el-input v-model="port.right" placeholder="请输入宿主端口" />
                        </el-form-item>
                        <el-button type="primary" @click="addPorts()">添加</el-button>
                    </el-form>
                    <el-table :data="ports" height="320" stripe border style="width: 100%;">
                        <el-table-column label="Docker">
                            <template slot-scope="scope">
                                <span v-if="!scope.row.edit" slot="reference" class="name-wrapper">{{ scope.row.docker }}</span>
                                <span v-if="scope.row.edit" class="cell"><el-input v-model="scope.row.docker"></el-input></span>
                            </template>
                        </el-table-column>
                        <el-table-column label="Host">
                            <template slot-scope="scope">
                                <span v-if="!scope.row.edit" slot="reference" class="name-wrapper">{{ scope.row.host }}</span>
                                <span v-if="scope.row.edit" class="cell"><el-input v-model="scope.row.host"></el-input></span>
                            </template>
                        </el-table-column>
                        <el-table-column label="操作">
                            <template slot-scope="scope">
                                <el-button v-if="scope.row.edit" size="mini" @click="scope.row.edit=false">保存</el-button>
                                <el-button v-if="!scope.row.edit" size="mini" @click="scope.row.edit=true">编辑</el-button>
                            </template>
                        </el-table-column>
                    </el-table>
                </el-tab-pane>
                <el-tab-pane label="磁盘映射" name="volume">
                    <el-form :inline="true" ref="envForm" :model="volume" label-position="left" label-width="120px">
                        <el-form-item label="容器目录" prop="left">
                            <el-input v-model="volume.left" placeholder="请输入容器目录" />
                        </el-form-item>
                        <el-form-item label="主机目录" prop="right">
                            <el-input v-model="volume.right" placeholder="请输入主机目录" />
                        </el-form-item>
                        <el-button type="primary" @click="addVolume()">添加</el-button>
                    </el-form>
                    <el-table :data="volumes" height="320" stripe border style="width: 100%;">
                        <el-table-column label="Docker">
                            <template slot-scope="scope">
                                <span v-if="!scope.row.edit" slot="reference" class="name-wrapper">{{ scope.row.docker }}</span>
                                <span v-if="scope.row.edit" class="cell"><el-input v-model="scope.row.docker"></el-input></span>
                            </template>
                        </el-table-column>
                        <el-table-column label="Host">
                            <template slot-scope="scope">
                                <span v-if="!scope.row.edit" slot="reference" class="name-wrapper">{{ scope.row.host }}</span>
                                <span v-if="scope.row.edit" class="cell"><el-input v-model="scope.row.host"></el-input></span>
                            </template>
                        </el-table-column>
                        <el-table-column label="操作">
                            <template slot-scope="scope">
                                <el-button v-if="scope.row.edit" size="mini" @click="scope.row.edit=false">保存</el-button>
                                <el-button v-if="!scope.row.edit" size="mini" @click="scope.row.edit=true">编辑</el-button>
                            </template>
                        </el-table-column>
                    </el-table>
                </el-tab-pane>
            </el-tabs>
            <el-form-item>
                <el-button @click="dialogFormVisible = false">取消</el-button>
                <el-button type="primary" @click="dialogStatus==='create'?createData():updateData()">确认</el-button>
            </el-form-item>
        </el-form>
    </el-dialog>
    </el-row>
</div>
</template>

<script>
import HostSelect from '@/components/widget/HostSelect'
import GroupSelect from '@/components/widget/GroupSelect'
import { formatTime } from '../../utils/index'
import { nodeAll, nodeNew, nodeDelete, nodeUpdate } from '../../api/node'
export default {
    name: 'Node',
    components: {
        HostSelect,
        GroupSelect
    },
    data() {
        return {
            textMap: {
                update: '编辑',
                create: '新建'
            },
            envList: [
                { name: "ENV_GAME_APP_ID",         desc: "APPID",            value: "1"},
                { name: "ENV_GAME_AREA_ID",        desc: "大区ID",           value: "1"},
                { name: "ENV_HOST_ADDR_IP",        desc: "本机ip",           value: "127.0.0.1"},
                { name: "ENV_DIR_LISTEN_ADDR",     desc: "dir 监听地址",     value: "0.0.0.0:20013"},
                { name: "ENV_PLATC_LISTEN_ADDR",   desc: "platform 监听地址", value: "0.0.0.0:8888"},
                { name: "ENV_PLATC_CLIENT_ADDR",   desc: "platform 监听地址", value: "127.0.0.1:8888", igport: true},
                { name: "ENV_PLATS_LISTEN_ADDR",   desc: "platform 监听地址", value: "0.0.0.0:8889"},
                { name: "ENV_PLATS_CLIENT_ADDR",   desc: "platform 监听地址", value: "127.0.0.1:8889", igport: true},
                { name: "ENV_LOBBY_LISTEN_ADDR",   desc: "lobby 监听地址",   value: "0.0.0.0:20015"},
                { name: "ENV_LOBBY_CLIENT_ADDR",   desc: "lobby 发送地址",   value: "127.0.0.1:20015", igport: true},
                { name: "ENV_ROUTER_LISTEN_ADDR",  desc: "router 监听地址",  value: "0.0.0.0:9001"},
                { name: "ENV_MONITOR_HTTP_ADDR",   desc: "monitor http地址", value: "0.0.0.0:9101"},
                { name: "ENV_MONITOR_LISTEN_ADDR", desc: "monitor 监听地址", value: "0.0.0.0:9201"},
                { name: "ENV_MONITOR_ADDR",        desc: "monitor 地址",     value: "127.0.0.1:9201", igport: true},
                { name: "ENV_DSA_LISTEN_ADDR",     desc: "dsa 监听地址",     value: "0.0.0.0:9301"},
                { name: "ENV_DS_OUT_PORT_RANGE",   desc: "ds 绑定端口范围",  value: "7000:8000"},
                { name: "ENV_MONGO_GROUP",         desc: "mongo group",      value: "1"},
                { name: "ENV_MYSQL_GROUP",         desc: "mysql group",      value: "1"},
                { name: "ENV_ROUTER_GROUP",        desc: "router group",     value: "1"},
                { name: "ENV_PARTITION_ID",        desc: "小区 ID",          value: "1"},
                { name: "ENV_DATA_COUNT",          desc: "DATA COUNT",       value: "1"},
                { name: "ENV_DATA_HASH",           desc: "DATA HASH",        value: "1"},
                { name: "ENV_MAX_CONNECTION",      desc: "最大连接数",       value: "4096"},
                { name: "ENV_DAEMON_STATE",        desc: "daemon",           value: "0"},
                { name: "ENV_STATIS_STATE",        desc: "统计开关",         value: "0"},
                { name: "ENV_FEISHU_STATE",        desc: "飞书开关",         value: "1"},
                { name: "ENV_LOGGER_LEVEL",        desc: "日志等级",         value: "1"},
                { name: "ENV_WEB_ADMIN_ADDR",      desc: "WEB监听地址",     value: "0.0.0.0:8080"},
                { name: "ENV_LOGGER_PATH",         desc: "日志路径",         value: "/home/pm/hive/logs"},
                { name: "ENV_COREDUMP_PATH",       desc: "coredump路径",     value: "/home/pm/hive/core"},
                { name: "ENV_WEBADMIN_HOST",       desc: "后台管理系统地址",  value: "10.72.17.44:8080", igport: true},
            ],
            defaultEnv: [
                "ENV_HOST_ADDR_IP",
                "ENV_LOGGER_LEVEL",
                "ENV_GAME_APP_ID",
                "ENV_GAME_AREA_ID",
                "ENV_MONITOR_ADDR",
                "ENV_ROUTER_GROUP",
            ],
            volumesEnv: [
                "ENV_LOGGER_PATH",
                "ENV_COREDUMP_PATH",
            ],
            groupList: [
                {name :"router",   script : "lua/router.lua", envs : ["ENV_ROUTER_LISTEN_ADDR"]},
                {name :"lobby",    script : "lua/lobby.lua", envs : ["ENV_LOBBY_CLIENT_ADDR", "ENV_LOBBY_LISTEN_ADDR", "ENV_PLATC_CLIENT_ADDR", "ENV_PLATS_CLIENT_ADDR"]},
                {name :"dbagent",  script : "lua/dbagent.lua", envs : ["ENV_MONGO_GROUP"]},
                {name :"dirsvr",   script : "lua/dirsvr.lua", envs : ["ENV_DIR_LISTEN_ADDR"]},
                {name :"matchsvr", script : "lua/matchsvr.lua", envs : []},
                {name :"indexsvr", script : "lua/indexsvr.lua", envs : []},
                {name :"roomsvr",  script : "lua/roomsvr.lua", envs : []},
                {name :"logagent", script : "lua/logagent.lua", envs : []},
                {name :"teamsvr",  script : "lua/teamsvr.lua", envs : []},
                {name :"dscenter", script : "lua/dscentersvr.lua", envs : []},
                {name :"dsagent",  script : "lua/dsagentsvr.lua", envs : ["ENV_DSA_LISTEN_ADDR",]},
                {name :"monitor",  script : "lua/monitor.lua", envs : ["ENV_WEBADMIN_HOST", "ENV_MONITOR_HTTP_ADDR", "ENV_MONITOR_LISTEN_ADDR"]},
                {name :"datasvr",  script : "lua/datasvr.lua", envs : ["ENV_MONGO_GROUP", "ENV_DATA_COUNT", "ENV_DATA_HASH"]},
                {name :"dssvr",    script : "", envs : []},
                {name :"collectsvr", script : "lua/collectsvr.lua", envs : ["ENV_MONGO_GROUP"]},
                {name :"teamsvr", script : "lua/teamsvr.lua", envs : []},
                {name :"gateway", script : "lua/gateway.lua", envs : ["ENV_PLATC_LISTEN_ADDR", "ENV_PLATS_LISTEN_ADDR"]},
                {name :"platform", script : "lua/platform.lua", envs : []},
            ],
            search: {
                group: '',
                host_id: '',
            },
            env: {},
            form: {},
            port: {},
            volume: {},
            envs: [],
            ports: [],
            nodes: [],
            volumes: [],
            filters: [],
            dialogStatus: '',
            dialogFormVisible: false,
            rules: {
                host_id: [{ required: true, message: '请选择主机', trigger: 'blur' },],
                group :[{ required: true, message: '请选择服务器组', trigger: 'blur' },],
                index :[{ required: true, message: '请输入索引', trigger: 'blur' },],
                script :[{ required: true, message: '请编辑启动脚本', trigger: 'blur' },],
            },
            rules2: {
                key :[{ required: true, message: '请选择环境变量', trigger: 'blur' },],
                value :[{ required: true, message: '请输入环境变量', trigger: 'blur' },],
            },
        }
    },
    mounted() {
        this.getNodes()
    },
    methods: {
        formatTime,
        getNodes() {
            nodeAll().then(res => {
                if (res.code !== 0) {
                    this.showFailed(res.msg)
                    return
                }
                this.nodes = res.data.nodes.reverse()
            })
        },
        filterNodes() {
            this.filters = this.nodes
            this.filters = this.filters.filter(node => {
                if (this.search.host_id != "" && node.host_id != this.search.host_id){
                    return false
                }
                if (this.search.group != "" && node.group != this.search.group){
                    return false
                }
                return true
            })
        },
        resetPort() {
            this.port  = {
                left: '',
                right: '',
            }
        },
        resetVolume() {
            this.volume  = {
                left: '',
                right: '',
            }
        },
        resetEnv() {
            this.env = {
                key: '',
                value: ''
            }
        },
        resetForm() {
            this.envs = [],
            this.ports = [],
            this.volumes= [],
            this.resetEnv()
            this.resetPort()
            this.resetVolume()
            this.form = {
                host_id: '',
                host_ip: '',
                group: '',
                index: null,
                status: null,
                script: '',
                envs: [],
                ports: [],
                volumes: [],
            }
        },
        deleteEnv(row) {
            for (var i in this.envs) {
                var item = this.envs[i]
                if (item.key == row.key){
                    this.envs.splice(i, 1)
                    return
                }
            }
        },
        addEnv() {
            this.$refs['envForm'].validate((valid) => {
                if (valid) {
                    if (this.form.host_id == "" || this.form.group == ""){
                        this.showFailed("请先选择主机和服务器组")
                        this.resetEnv()
                        return
                    }
                    for (var item of this.envs) {
                        if (item.key == this.env.key){
                            this.showFailed("该环境变量已经添加过了")
                            this.resetEnv()
                            return
                        }
                    }
                    this.pushEnv(this.env)
                }
            })
        },
        pushEnv(item) {
            var newItem = Object.assign({}, item)
            if (this.form.host_ip != "") {
                newItem.value = newItem.value.replace("127.0.0.1", this.form.host_ip)
            }
            this.envs.push(newItem)
            this.resetEnv()
            var tpl = this.findEnv(item.key)
            var portpos = newItem.value.indexOf(":")
            if (portpos <= 0 || tpl.igport){
                return
            }
            var port = newItem.value.slice(portpos + 1)
            if (!this.findPort(port)) {
                this.ports.push({host: (parseInt(port) - 1 + this.form.index), docker: port, edit: false })
            }
        },
        findPort(port) {
            for (var item of this.ports) {
                if (item.docker == port) {
                    return true
                }
            }
            return false
        },
        findEnv(name) {
            for (var item of this.envList) {
                if (item.name == name) {
                    return item
                }
            }
        },
        selectEnv(name) {
            var item = this.findEnv(name)
            this.env = { key: name, value: item.value, desc: item.desc, edit: false}
        },
        selectHost(id, host) {
            this.form.host_ip = host.ip
            for (var item of this.envs) {
                item.value = item.value.replace("127.0.0.1", host.ip)
            }
        },
        findIndex(group) {
            var max = 1
            for (var node of this.nodes) {
                if (node.group == group && node.index >= max) {
                    max = node.index + 1
                }
            }
            return max
        },
        selectGroup(name) {
            for (var item of this.groupList) {
                if (item.name == name) {
                    this.form.script = item.script
                    this.form.index = this.findIndex(name)
                    this.buildEnv(item.envs)
                    break
                }
            }
        },
        buildEnv(envs) {
            this.envs = []
            this.ports = []
            this.volumes = []
            for (var name of this.defaultEnv) {
                this.selectEnv(name)
                this.pushEnv(this.env)
            }
            for (var name of this.volumesEnv) {
                this.selectEnv(name)
                this.pushEnv(this.env)
                var item = this.findEnv(name)
                this.volumes.push({host: item.value, docker: item.value, edit: false })
            }
            for (var name of envs) {
                this.selectEnv(name)
                this.pushEnv(this.env)
            }
        },
        handleCreate() {
            this.resetForm()
            this.dialogStatus = 'create'
            this.dialogFormVisible = true
            this.$nextTick(() => {
                this.$refs['envForm'].clearValidate()
                this.$refs['dataForm'].clearValidate()
            })
        },
        formatParams(){
            this.form.envs = []
            this.form.ports = []
            this.form.volumes = []
            for (var item of this.envs) {
                this.form.envs.push(`${item.key}: ${item.value}`)
            }
            for (var item of this.ports) {
                this.form.ports.push(`${item.host}:${item.docker}`)
            }
            for (var item of this.volumes) {
                this.form.volumes.push(`${item.host}:${item.docker}`)
            }
            this.envs = []
            this.ports = []
            this.volumes = []
        },
        createData() {
            this.$refs['dataForm'].validate((valid) => {
                if (valid) {
                    this.formatParams()
                    nodeNew(this.form).then(res => {
                        if (res.code !== 0) {
                            this.resetForm()
                            this.showFailed(res.msg)
                            return
                        }
                        this.getNodes()
                        this.dialogFormVisible = false
                        this.showSuccess('操作成功')
                    })
                }
            })
        },
        handleUpdate(row) {
            this.resetForm()
            this.form = Object.assign({}, row) // copy obj
            for (var item of this.form.envs) {
                var pos = item.indexOf(":")
                var key = item.slice(0, pos)
                var env = this.findEnv(key)
                if (env) {
                    this.envs.push({edit: false, key: key, value: item.slice(pos + 1), desc: env.desc})
                }
            }
            for (var item of this.form.ports) {
                var kvs = item.split(":")
                this.ports.push({host: kvs[0], docker: kvs[1], edit:false})
            }
            for (var item of this.form.volumes) {
                var kvs = item.split(":")
                this.volumes.push({host: kvs[0], docker: kvs[1], edit:false})
            }
            this.dialogStatus = 'update'
            this.dialogFormVisible = true
            this.$nextTick(() => {
                this.$refs['dataForm'].clearValidate()
            })
        },
        updateData() {
            this.$refs['dataForm'].validate((valid) => {
                if (valid) {
                    this.formatParams()
                    nodeUpdate(this.form).then(res => {
                        if (res.code !== 0) {
                            this.showFailed(res.msg)
                            return
                        }
                        this.getNodes()
                        this.showSuccess('操作成功')
                        this.dialogFormVisible = false
                    })
                }
            })
        },
        getRowKeys(row) {
            return row.name
        },
        handleDelete(row) {
            this.$confirm('确定要删除此节点，是否继续?', '提示', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'warning'
            }).then(() => {
                nodeDelete({id : row.id }).then(res => {
                    if (res.code !== 0) {
                        this.showFailed(res.msg)
                        return
                    }
                    this.getNodes()
                    this.showSuccess()
                })
            }).catch(() => {})
        },
        addPorts(){
            if (this.port.left == '') {
                this.showFailed("宿主端口不能为空")
                return
            }
            if (this.port.right == '') {
                this.showFailed("宿主端口不能为空")
                return
            }

            this.ports.push({docker: this.port.left, host: this.port.right, edit:false})
            this.resetPort()
        },
        addVolume() {
            if (this.volume.left == '') {
                this.showFailed("容器目录不能为空")
                return
            }
            if (this.volume.right == '') {
                this.showFailed("宿主目录不能为空")
                return
            }

            this.volumes.push({ docker: this.volume.left,host: this.volume.right,  edit: false  })

            this.resetVolume()
        },
        showSuccess(msg) {
            this.$notify({title: '成功', message: msg, type: 'success', duration: 2000 })
        },
        showFailed(msg) {
            this.$notify({title: '失败', message: msg, type: 'fail', duration: 2000 })
        }
    }
}
</script>
