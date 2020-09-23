<template>
<div class="app-container">
    <h3>密钥管理</h3>
    <el-alert :closable="false" type="success" title="密钥管理负责管理通过ssh方式访问主机，请将对应的公钥放入要访问主机的.ssh/authorized_keys。"/>
    <div class="tool-box">
        <el-button-group>
            <el-button class="filter-item" type="primary" @click="handleCreate">添加</el-button>
            <el-button v-waves :loading="downloadLoading" class="filter-item" @click="handleDownload">导出</el-button>
        </el-button-group>
    </div>
    <el-table stripe v-loading="listLoading" style="width: 100%" :key="tableKey" :data="keys">
        <el-table-column label="别名">
            <template slot-scope="scope"><span >{{ scope.row.title }}</span></template>
        </el-table-column>
        <el-table-column label="账户">
            <template slot-scope="scope"><span >{{ scope.row.user }}</span></template>
        </el-table-column>
        <el-table-column label="使用主机数">
            <template slot-scope="scope"><span >{{ scope.row.host_count }}</span></template>
        </el-table-column>
        <el-table-column label="更新时间">
            <template slot-scope="scope"><span>{{ parseTime(scope.row.updated_at) }}</span></template>
        </el-table-column>
        <el-table-column label="操作">
            <template slot-scope="scope">
                <el-button size="mini" type="Info" @click="handleCopy(scope.row.key_public,$event)">拷贝公钥</el-button>
                <el-button size="mini" @click="handleUpdate(scope.row)">编辑</el-button>
                <el-button size="mini" type="danger" @click="handleDelete(scope.row)">删除</el-button>
            </template>
        </el-table-column>
    </el-table>
    <el-dialog :title="textMap[dialogStatus]" :visible.sync="dialogFormVisible" :close-on-click-modal="false" width="60%">
        <el-form ref="dataForm" :rules="rules" :model="form" label-width="50px">
            <el-form-item label="别名" prop="title">
                <el-input v-model="form.title" placeholder="wheel"/>
            </el-form-item>
            <el-form-item label="账户" prop="user">
                <el-input v-model="form.user" placeholder="wheel"/>
            </el-form-item>
            <el-form-item label="私钥" prop="key">
                <el-input v-model="form.key" rows="20" type="textarea" placeholder="请填写私钥或者密码，如果不填会生成一对公私钥。"/>
            </el-form-item>
        </el-form>
        <div slot="footer" class="dialog-footer">
            <el-button @click="dialogFormVisible = false">取消</el-button>
            <el-button type="primary" @click="dialogStatus==='create'?createData($event):updateData($event)">确认</el-button>
        </div>
    </el-dialog>
    <el-dialog :visible.sync="dialogDeleteVisible">
        <el-form ref="dataForm" :model="form" label-position="left" label-width="70px" style="width: 400px; margin-left:50px;">
            <span>other hosts are using</span>
        </el-form>
        <div slot="footer" class="dialog-footer">
            <el-button @click="dialogDeleteVisible = false">确认</el-button>
        </div>
    </el-dialog>
    <el-dialog title="公钥" width="50%" :visible.sync="copyPublicKeyDialogVisible">
        <h3>请拷贝公钥，并将它放入要访问主机的.ssh/authorized_keys。</h3>
        <p style="word-break:break-all">{{ newPublicKeyContent }}</p>
        <span slot="footer" class="dialog-footer">
            <el-button type="primary" @click="handleCopy(newPublicKeyContent, $event)">拷贝</el-button>
        </span>
    </el-dialog>
</div>
</template>

<script>
import clipboard from '@/utils/clipboard'
import { parseTime } from '@/utils/index'
import { keyAll, keyNew, keyDelete, keyUpdate } from '../../api/key'
export default {
    name: 'Key',
    data() {
        return {
            tableKey: 0,
            keys: [],
            form: {},
            listLoading: false,
            dialogFormVisible: false,
            dialogStatus: '',
            textMap: { update: '编辑', create: '新建' },
            rules: {
                title: [{ required: true, message: '请输入账户别名', trigger: 'blur' },],
                user: [{ required: true, message: '请输入账户名字', trigger: 'blur' },]
            },
            downloadLoading: false,
            dialogDeleteVisible: false,
            copyPublicKeyDialogVisible: false,
            newPublicKeyContent: ''
        }
    },
    mounted() {
        this.resetForm()
        this.getKeys()
    },
    methods: {
        parseTime,
        getKeys() {
            keyAll().then(res => {
                if (res.code !== 0) {
                    this.showFailed(res.msg)
                    return
                }
                this.keys = (res.data.keys || []).reverse()
            })
        },
        resetForm() {
            this.form = {
                id: '',
                key: '',
                user: '',
                title: '',
                key_public: '',
                created_time: '',
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
                if (!valid) {
                    return
                }
                keyNew(this.form).then(res => {
                    if (res.code !== 0) {
                        this.showFailed(res.msg)
                        return
                    }
                    this.dialogFormVisible = false
                    this.getKeys()
                    this.showSuccess("操作成功")
                    this.noticeCopyPublicKey(res.data.key.key_public, $event)
                })
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
                if (!valid) {
                    return
                }
                keyUpdate(this.form).then(res => {
                    if (res.code !== 0) {
                        this.showFailed(res.msg)
                        return
                    }
                    this.dialogFormVisible = false
                    this.getKeys()
                    this.showSuccess("操作成功")
                })
            })
        },
        handleDelete(row) {
            this.$confirm('确定要删除此账户，是否继续?', '提示', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'warning'
            }).then(() => {
                this.form = Object.assign({}, row)
                keyDelete({ id: this.form.id }).then(res => {
                    if (res.code === 0) {
                        const index = this.keys.indexOf(row)
                        this.keys.splice(index, 1)
                        this.showSuccess("删除成功")
                        this.refreshCacheData()
                    } else {
                        this.showFailed(res.msg)
                    }
                })
            }).catch(() => {})
        },        
        handleCopy(text, $event) {
            this.copyPublicKeyDialogVisible = false
            clipboard(text, $event)
        },
        noticeCopyPublicKey(key, $event) {
            this.copyPublicKeyDialogVisible = true
            this.newPublicKeyContent = key
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
<style>
</style>
