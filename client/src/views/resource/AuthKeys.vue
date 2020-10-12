<template>
<div class="app-container">
    <h3>密钥管理</h3>
    <el-alert :closable="false" type="success" title="密钥管理负责管理通过ssh方式访问主机，请将对应的公钥放入要访问主机的.ssh/authorized_keys。"/>
    <div class="tool-box">
        <el-button class="filter-item" type="primary" @click="handleCreate">添加</el-button>
    </div>
    <el-table stripe v-loading="listLoading" style="width: 100%" :data="this.$store.getters.authkeys">
        <el-table-column label="名称">
            <template slot-scope="scope"><span >{{ scope.row.name }}</span></template>
        </el-table-column>
        <el-table-column label="描述">
            <template slot-scope="scope"><span >{{ scope.row.desc }}</span></template>
        </el-table-column>
        <el-table-column label="类型">
            <template slot-scope="scope"><span>{{ scope.row.type }}</span></template>
        </el-table-column>
        <el-table-column label="创建时间">
            <template slot-scope="scope"><span>{{ parseTime(scope.row.time) }}</span></template>
        </el-table-column>
        <el-table-column label="操作">
            <template slot-scope="scope">
                <el-button size="mini" type="Info" v-if="scope.row.type==='SSHKey'" 
                    @click="handleCopy(scope.row.sshkey_pub, $event)">拷贝公钥
                </el-button>
                <el-button size="mini" @click="handleUpdate(scope.row)">编辑</el-button>
                <el-button size="mini" type="danger" @click="handleDelete(scope.row)">删除</el-button>
            </template>
        </el-table-column>
    </el-table>
    <el-dialog :title="textMap[dialogStatus]" :visible.sync="dialogFormVisible" :close-on-click-modal="false" width="60%">
        <el-form ref="dataForm" :rules="rules" :model="form" label-width="100px">
            <el-form-item label="名称" prop="name">
                <el-input v-model="form.name" placeholder="名称"/>
            </el-form-item>
            <el-form-item label="描述" prop="desc">
                <el-input v-model="form.desc" placeholder="请简单描述凭证"/>
            </el-form-item>
            <el-form-item label="类型" prop="type">
                <el-select v-model="form.type" :disabled="dialogStatus==='update'" placeholder="请选择类型">
                    <el-option v-for="item in keyType" :key="item" :label="item" :value="item"/>
                </el-select>
            </el-form-item>
            <el-form-item label="账户" prop="user" v-if="form.type==='Password'">
                <el-input v-model="form.user" placeholder="root"/>
            </el-form-item>
            <el-form-item label="密码" prop="passwd" v-if="form.type==='Password'">
                <el-input v-model="form.passwd" placeholder=""/>
            </el-form-item>
            <el-form-item label="Token" prop="token" v-if="form.type==='AccessToken'">
                <el-input v-model="form.token" placeholder=""/>
            </el-form-item>
            <el-form-item label="私钥" prop="sshkey" v-if="form.type==='SSHKey'">
                <el-input v-model="form.sshkey" :disabled="dialogStatus==='update'" placeholder="请填写私钥文件名称。如果不填会自动生成一对公私钥。"/>
            </el-form-item>
        </el-form>
        <div slot="footer" class="dialog-footer">
            <el-button @click="dialogFormVisible = false">取消</el-button>
            <el-button type="primary" @click="dialogStatus==='create'?createData($event):updateData($event)">确认</el-button>
        </div>
    </el-dialog>
</div>
</template>

<script>
import clipboard from '@/utils/clipboard'
import bus from '../../components/common/bus'
import * as utils from '../../utils/index'
import * as driver from '../../api/driver'
export default {
    name: 'AuthKeys',
    data() {
        return {
            form: {},
            listLoading: false,
            dialogFormVisible: false,
            dialogStatus: '',
            keyType: [ "Password", "SSHKey", "AccessToken" ],
            textMap: { update: '编辑', create: '新建' },
            rules: {
                name: [{ required: true, message: '请输入名字', trigger: 'blur' },],
                desc: [{ required: true, message: '请输入描述', trigger: 'blur' },],
                type: [{ required: true, message: '请选择凭据类型', trigger: 'blur' },],
                user: [{ required: true, message: '请输入账户名字', trigger: 'blur' },],
                token: [{ required: true, message: '请输入access token', trigger: 'blur' },],
                passwd: [{ required: true, message: '请输入password', trigger: 'blur' },],
            },
        }
    },
    created() {
        this.resetForm()
        var store = this.$store.getters
        if (store.proj) {
            this.loadAuthkeys()
        }
        bus.$on('project', msg => {
            if (store.proj) {
                this.loadAuthkeys()
            }
        })
    },
    methods: {
        loadAuthkeys() {
            driver.load("authkeys").then(res => {
                utils.showNetRes(this, res, () => {
                    this.$store.dispatch("InitData", ["AUTHKEY", res.data])
                })
            })
        },
        parseTime(tm){
            return utils.parseTime(tm)
        },
        resetForm() {
            this.form = {
                id: '',
                type: '',
                user: '',
                name: '',
                desc: '',
                token: '',
                passwd: '',
                sshkey: '',
                time: '',
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
        createData($event) {
            this.$refs['dataForm'].validate((valid) => {
                if (valid) {
                    this.form.id = utils.newGuid()
                    driver.insert("authkeys", this.form).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("AddData", ["AUTHKEY", res.data, "id"])
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
                    driver.update("authkeys", this.form).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("UpdateData", ["AUTHKEY", res.data, "id"])
                            this.dialogFormVisible = false
                        })
                    })
                }
            })
        },
        handleDelete(row) {
            this.$confirm('确定要删除此账户，是否继续?', '提示', {
                confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
            }).then(() => {
                var keyids = []
                keyids.push(row.id)
                driver.remove("authkeys", keyids).then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("DelData", ["AUTHKEY", row.id, "id"])
                    })
                })
            }).catch(() => {})
        },
        handleCopy(text, $event) {
            clipboard(text, $event)
        },
    }
}
</script>
<style>
</style>
