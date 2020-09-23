<template>
<div class="app-container">
    <h3>主机管理</h3>
    <el-alert :closable="false" type="success" title="主机管理负责管理通过ssh方式访问的主机，主机可用作部署机和打包机。"/>
    <div class="twt-tool-box">
        <el-button-group>
            <el-button class="filter-item" type="primary" @click="handleCreate">添加</el-button>
            <el-button v-waves :loading="downloadLoading" class="filter-item" @click="handleDownload">导出</el-button>
        </el-button-group>
    </div>
    <el-table stripe v-loading="listLoading" style="width: 100%" :key="tableKey" :data="hosts">
        <el-table-column label="名称">
            <template slot-scope="scope"><span >{{ scope.row.name }}</span></template>
        </el-table-column>
        <el-table-column label="IP">
            <template slot-scope="scope"><span >{{ scope.row.ip }}</span></template>
        </el-table-column>
        <el-table-column label="端口">
            <template slot-scope="scope"><span >{{ scope.row.ssh_port }}</span></template>
        </el-table-column>
        <el-table-column label="是否打包机">
            <template slot-scope="scope"><span >{{ formatBool(scope.row.can_pack) }}</span></template>
        </el-table-column>
        <el-table-column label="操作" align="center">
            <template slot-scope="scope">
                <el-button size="mini" @click="handleUpdate(scope.row)">编辑</el-button>
                <el-button size="mini" @click="handleConnect(scope.row)">连接</el-button>
                <el-button size="mini" type="danger" @click="handleDelete(scope.row)">删除</el-button>
            </template>
        </el-table-column>
    </el-table>
    <div class="pagination-container">
        <el-pagination v-show="total>0" :total="total" layout="total"/>
    </div>
    <el-dialog :title="textMap[dialogStatus]" :visible.sync="dialogFormVisible" :close-on-click-modal="false" >
        <el-form ref="dataForm" :rules="rules" :model="form" label-position="left" label-width="80px">
            <el-form-item label="名称" prop="name">
                <el-input v-model="form.name" placeholder="测试服"/>
            </el-form-item>
            <el-form-item label="地址" prop="addr">
                <el-input v-model="form.addr" placeholder="192.168.0.1:22"/>
            </el-form-item>
            <el-form-item label="密钥" prop="key_id">
                <el-select v-model="form.key_id" placeholder="请选择">
                    <el-option v-for="item in keys" :label="item.title" :value="item.id" :key="item.id"/>
                </el-select>
                <router-link :to="{ path: '/key' }">
                    <el-button @click="dialogFormVisible = false" type="text">> 点我前往密钥管理</el-button>
                </router-link>
            </el-form-item>
            <el-form-item label="是否打包机" prop="can_pack">
                <el-checkbox v-model="form.can_pack"/>
                <span style="color:#E6A23C"> 勾选会作为打包机，推荐系统 ubuntu 16.04</span>
            </el-form-item>
            <el-form-item>
                <el-button @click="dialogFormVisible = false">取消</el-button>
                <el-button type="primary" @click="dialogStatus==='create'?createData():updateData()">确认</el-button>
            </el-form-item>
        </el-form>
    </el-dialog>
</div>
</template>

<script>
import { keyAll } from '../../api/key'
import { formatBool } from '@/utils/index'
import { hostAll, hostNew, hostDelete, hostUpdate } from '../../api/host'
export default {
    name: 'Host',
    data() {
        return {
            tableKey: 0,
            form: {},
            keys: [],
            hosts: [],
            total: null,
            dialogStatus: '',
            listLoading: false,
            downloadLoading: false,
            dialogFormVisible: false,
            textMap: { update: '编辑', create: '新建' },
            rules: {
                name: [{ required: true, message: '请填入主机名字', trigger: 'blur' },],
                key_id: [{ required: true, message: '请选择密钥', trigger: 'change' }],
                addr: [
                    { required: true, message: '请填入主机访问地址', trigger: 'blur' },
                    { type: 'string', pattern: /^.+:.+$/, message: '请填写正确主机地址，例：192.168.0.1:22' }
                ],
                ip: [{ required: true, message: '请填入主机域名或者IP', trigger: 'blur' }],
                ssh_port: [{ required: true, message: '请填入ssh的端口', trigger: 'blur' }],
                user: [{ required: true, message: '请填入通过ssh登录的用户名', trigger: 'blur' }],
                method: [{ required: true, message: '请选择提权方法', trigger: 'change' }]
            },
        }
    },
    mounted() {
        this.resetTemp()
        this.getHosts()
        this.getKeys()
    },
    methods: {
        formatBool,
        getKeys() {
            keyAll().then(res => {
                if (res.code !== 0) {
                    this.showFailed(res.msg)
                    return
                }
                this.keys = (res.data.keys || []).reverse()
            })
        },
        getHosts() {
            hostAll().then(res => {
                if (res.code !== 0) {
                    this.showFailed(res.msg)
                    return
                }
                if (res.data.hosts) {
                    this.hosts = res.data.hosts.reverse()
                    this.hosts.forEach(e => {
                        e.addr = `${e.ip}:${e.ssh_port}`
                    })
                }
                this.total = this.hosts.length
            })
        },
        resetTemp() {
            this.form = {
                id: '',
                name: '',
                new_name: '',
                user: '',
                ip: '',
                ssh_port: '',
                key_id: '',
                can_pack: false
            }
        },
        handleCreate() {
            this.resetTemp()
            this.dialogStatus = 'create'
            this.dialogFormVisible = true
            this.$nextTick(() => {
                this.$refs['dataForm'].clearValidate()
            })
        },
        handleConnect(row) {
            var url = '/console/html/console.html?sid=' + row.id + '&path=/webconsole/connect_host&token='
            window.open(url, '_blank')
        },
        parseAddr(addr) {
            var metas = addr.split(':')
            return { ip: metas[0], port: metas[1] }
        },
        getFormParams() {
            var params = Object.assign({}, this.form)
            const addrMetas = this.parseAddr(params.addr)
            params.ip = addrMetas.ip
            params.ssh_port = addrMetas.port
            return params
        },
        createData() {
            this.$refs['dataForm'].validate((valid) => {
                if (valid) {
                    var params = this.getFormParams()
                    hostNew(params).then(res => {
                        if (res.code !== 0) {
                            this.showFailed(res.msg)
                            return
                        }
                        this.getHosts()
                        this.dialogFormVisible = false
                        this.showSuccess('操作成功')
                    })
                }
            })
        },
        handleUpdate(row) {
            this.resetTemp()
            this.form = Object.assign({}, row) // copy obj
            this.dialogStatus = 'update'
            this.dialogFormVisible = true
            this.$nextTick(() => {
                this.$refs['dataForm'].clearValidate()
            })
        },
        updateData() {
            this.$refs['dataForm'].validate((valid) => {
                if (valid) {
                    var params = this.getFormParams()
                    hostUpdate(params).then(res => {
                        if (res.code !== 0) {
                            this.showFailed(res.msg)
                            return
                        }
                        this.getHosts()
                        this.showSuccess('操作成功')
                        this.dialogFormVisible = false
                    })
                }
            })
        },
        handleDelete(row) {
            this.$confirm('确定要删除此主机，是否继续?', '提示', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'warning'
            }).then(() => {
                this.form = Object.assign({}, row)
                hostDelete(this.form).then(res => {
                    if (res.code !== 0) {
                        this.showFailed(res.msg)
                        return
                    }
                    this.getHosts()
                    this.showSuccess('操作成功')
                })
            }).catch(() => {})
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
