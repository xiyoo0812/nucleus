<template>
<div class="app-container">
    <h3>数据库管理</h3>
    <el-alert :closable="false" type="success" title="负责管理数据库。"/>
    <div class="twt-tool-box">
        <el-button-group>
            <el-button class="filter-item" type="primary" @click="handleCreate">添加</el-button>
            <el-button v-waves :loading="downloadLoading" class="filter-item" @click="handleDownload">导出</el-button>
        </el-button-group>
    </div>
    <el-table stripe v-loading="listLoading" style="width: 100%" :data="this.$store.getters.databases">
        <el-table-column label="名称">
            <template slot-scope="scope"><span >{{ scope.row.name }}</span></template>
        </el-table-column>
        <el-table-column label="IP">
            <template slot-scope="scope"><span >{{ scope.row.ip }}</span></template>
        </el-table-column>
        <el-table-column label="端口">
            <template slot-scope="scope"><span >{{ scope.row.port }}</span></template>
        </el-table-column>
        <el-table-column label="Group">
            <template slot-scope="scope"><span >{{ scope.row.group }}</span></template>
        </el-table-column>
        <el-table-column label="Index">
            <template slot-scope="scope"><span >{{ scope.row.index }}</span></template>
        </el-table-column>
        <el-table-column label="用户名">
            <template slot-scope="scope"><span >{{ scope.row.uname }}</span></template>
        </el-table-column>
        <el-table-column label="类型">
            <template slot-scope="scope"><span >{{ scope.row.type }}</span></template>
        </el-table-column>
        <el-table-column label="操作" align="center">
            <template slot-scope="scope">
                <el-button size="mini" @click="handleUpdate(scope.row)">编辑</el-button>
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
                <el-input v-model="form.name" placeholder="pmman"/>
            </el-form-item>
            <el-form-item label="地址" prop="addr">
                <el-input v-model="form.addr" placeholder="192.168.0.1:27017"/>
            </el-form-item>
            <el-form-item label="账户" prop="uname">
                <el-input v-model="form.uname" placeholder="root"/>
            </el-form-item>
            <el-form-item label="密码" prop="passwd">
                <el-input placeholder="password" v-model="form.passwd"/>
            </el-form-item>
             <el-form-item label="类型" prop="type">
                <el-select v-model="form.type" placeholder="请选择类型">
                    <el-option v-for="item in dbType" :key="item" :label="item" :value="item"/>
                </el-select>
            </el-form-item>
             <el-form-item label="Group" prop="group">
                <el-input v-model="form.group"/>
            </el-form-item>
             <el-form-item label="Index" prop="index">
                <el-input v-model="form.index"/>
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
    name: 'Databases',
    data() {
        return {
            form: {},
            dialogStatus: '',
            listLoading: false,
            downloadLoading: false,
            dialogFormVisible: false,
            dbType: [ "mysql", "mongo" ],
            textMap: { update: '编辑', create: '新建' },
            rules: {
                name: [{ required: true, message: '请填入数据库名', trigger: 'blur' },],
                type: [{ required: true, message: '请选型数据库类型', trigger: 'blur' }],
                group: [{ required: true, message: '请填入数据库集群', trigger: 'blur' },],
                index: [{ required: true, message: '请填入数据库索引', trigger: 'blur' },],
                addr: [
                    { required: true, message: '请填入数据库访问地址', trigger: 'blur' },
                    { type: 'string', pattern: /^.+:.+$/, message: '请填写正确数据库地址，例：192.168.0.1:22' }
                ],
            },
        }
    },
    created() {
        this.resetForm()
        var store = this.$store.getters
        if (store.proj && store.databases.length == 0) {
            this.loadDatabases()
        }
        bus.$on('project', msg => {
            if (store.proj) {
                this.loadDatabases()
            }
        })
    },
    methods: {
        loadDatabases() {
            driver.load("databases").then(res => {
                utils.showNetRes(this, res, () => {
                    res.data.forEach(e => {
                        e.addr = `${e.ip}:${e.port}`
                    })
                    this.$store.dispatch("InitData", ["DATABASE", res.data])
                })
            })
        },
        resetForm() {
            this.form = {
                id: '',
                name: '',
                passwd: '',
                uname: '',
                ip: '',
                port: null,
                type: '',
                addr: '',
                group: null,
                index: null,
            }
        },
        handleCreate() {
            this.resetForm()
            this.dialogStatus = 'create'
            this.dialogFormVisible = true
            this.$nextTick(() => {
                this.$refs['dataForm'].clearValidate()
            })
        },
        parseAddr(addr) {
            var metas = addr.split(':')
            return { ip: metas[0], port: metas[1] }
        },
        getFormParams() {
            var params = Object.assign({}, this.form)
            const addrMetas = this.parseAddr(params.addr)
            params.ip = addrMetas.ip
            params.port = addrMetas.port
            return params
        },
        createData() {
            this.$refs['dataForm'].validate((valid) => {
                if (valid) {
                    var params = this.getFormParams()
                    driver.insert("databases", params).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("AddData", ["DATABASE", res.data, "id"])
                            this.dialogFormVisible = false

                        })
                    })
                }
            })
        },
        handleUpdate(row) {
            this.resetForm()
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
                    driver.update("databases", params).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("UpdateData", ["DATABASE", res.data, "id"])
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
                var dbids = []
                dbids.push(row.id)
                driver.remove("databases", dbids).then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("DelData", ["DATABASE", row.id, "id"])
                    })
                })
            }).catch(() => {})
        },
    }
}
</script>

<style>
p { word-wrap:break-word; }
</style>
