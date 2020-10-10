<template>
<div class="app-container">
    <h3>主机管理</h3>
    <el-alert :closable="false" type="success" title="主机管理负责管理通过ssh方式访问的主机，主机可用作部署机和打包机。"/>
    <div class="twt-tool-box">
        <el-button-group>
            <el-button class="filter-item" type="primary" @click="handleCreate">添加</el-button>
        </el-button-group>
    </div>
    <el-table stripe v-loading="listLoading" style="width: 100%" :data="this.$store.getters.hosts">
        <el-table-column label="名称">
            <template slot-scope="scope"><span >{{ scope.row.name }}</span></template>
        </el-table-column>
        <el-table-column label="IP">
            <template slot-scope="scope"><span >{{ scope.row.ip }}</span></template>
        </el-table-column>
        <el-table-column label="端口">
            <template slot-scope="scope"><span >{{ scope.row.port }}</span></template>
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
    <el-dialog :title="textMap[dialogStatus]" :visible.sync="dialogFormVisible" :close-on-click-modal="false" >
        <el-form ref="dataForm" :rules="rules" :model="form" label-position="left" label-width="80px">
            <el-form-item label="名称" prop="name">
                <el-input v-model="form.name" placeholder="测试服"/>
            </el-form-item>
            <el-form-item label="地址" prop="addr">
                <el-input v-model="form.addr" placeholder="192.168.0.1:22"/>
            </el-form-item>
            <el-form-item label="/凭证" prop="authkey">
                <el-select v-model="form.authkey" placeholder="请选择凭证">
                    <el-option v-for="item in this.$store.getters.authkeys" :label="item.name" :value="item.id" :key="item.id"/>
                </el-select>
                <router-link :to="{ path: '/authkeys' }">
                    <el-button @click="dialogFormVisible = false" type="text">> 点我前往凭证管理</el-button>
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

import bus from '../../components/common/bus'
import * as utils from '../../utils/index'
import * as driver from '../../api/driver'

export default {
    name: 'Hosts',
    data() {
        return {
            form: {},
            dialogStatus: '',
            listLoading: false,
            dialogFormVisible: false,
            textMap: { update: '编辑', create: '新建' },
            rules: {
                name: [{ required: true, message: '请填入主机名字', trigger: 'blur' },],
                authkey: [{ required: true, message: '请选择凭证', trigger: 'change' }],
                addr: [
                    { required: true, message: '请填入主机访问地址', trigger: 'blur' },
                    { type: 'string', pattern: /^.+:.+$/, message: '请填写正确主机地址，例：192.168.0.1:22' }
                ],
                ip: [{ required: true, message: '请填入主机域名或者IP', trigger: 'blur' }],
                port: [{ required: true, message: '请填入ssh的端口', trigger: 'blur' }],
            },
        }
    },
    created() {
        this.resetForm()
        var store = this.$store.getters
        if (store.proj) {
            this.loadHosts()
        }
        bus.$on('project', msg => {
            if (store.proj) {
                this.loadHosts()
            }
        })
    },
    methods: {
        formatBool(val) {
            return utils.formatBool(val)
        },
        loadHosts() {
            driver.load("hosts").then(res => {
                utils.showNetRes(this, res, () => {
                    this.$store.dispatch("InitData", ["HOST", res.data])
                })
            })
        },
        resetTemp() {
            this.form = {
                id: '',
                name: '',
                ip: '',
                port: '',
                authkey: '',
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
        
        buildForm() {
            var form = Object.assign({}, this.form)
            var metas = form.addr.split(':')
            form.ip = metas[0]
            form.port = metas[1]
            return form
        },
        createData() {
            this.$refs['dataForm'].validate((valid) => {
                if (valid) {
                    var form = this.buildForm()
                    form.id = utils.newGuid()
                    driver.insert("hosts", form).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("AddData", ["HOST", res.data, "id"])
                            this.dialogFormVisible = false
                        })
                    })
                }
            })
        },
        handleUpdate(row) {
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
                    var form = this.buildForm()
                    driver.update("hosts", form).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("UpdateData", ["HOST", res.data, "id"])
                            this.dialogFormVisible = false
                        })
                    })
                }
            })
        },
        handleDelete(row) {
            this.$confirm('确定要删除此主机，是否继续?', '提示', {
                confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
            }).then(() => {
                var hostids = []
                hostids.push(row.id)
                driver.remove("hosts", hostids).then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("DelData", ["HOST", row.id, "id"])
                    })
                })
            }).catch(() => {})
        },
    }
}
</script>
