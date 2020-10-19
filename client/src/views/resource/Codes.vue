<template>
<div class="app-container">
    <h3>代码管理</h3>
    <el-alert type="success" :closable="false" title="代码管理负责管理git代码仓库，可以利用其代码打包。需要本机有权限能够拉取到git仓库代码。"/>
    <div class="tool-box">
        <el-button-group>
            <el-button class="filter-item" type="primary" @click="handleCreate">添加</el-button>
        </el-button-group>
    </div>
    <el-table v-loading="listLoading" stripe style="width: 100%" :element-loading-text="listLoadingText" :data="$store.getters.codes">
        <el-table-column label="名称">
            <template slot-scope="scope">
                <router-link :to="{ path: '/package', query: {id:scope.row.id} }">
                    <el-button type="text"><span >{{ scope.row.name }}</span></el-button>
                </router-link>
            </template>
        </el-table-column>
        <el-table-column label="类型">
            <template slot-scope="scope"><span >{{ scope.row.type }}</span></template>
        </el-table-column>
        <el-table-column label="地址">
            <template slot-scope="scope"><span >{{ scope.row.addr }}</span></template>
        </el-table-column>
        <el-table-column label="操作" align="center">
            <template slot-scope="scope">
            <el-button size="mini" @click="handleUpdate(scope.row)">编辑</el-button>
            <el-button size="mini" type="danger" @click="handleDelete(scope.row)">删除</el-button>
            </template>
        </el-table-column>
    </el-table>
    <el-dialog :title="textMap[dialogStatus]" :visible.sync="dialogFormVisible" :close-on-click-modal="false" width="60%">
        <el-form ref="dataForm" :rules="rules" :model="form" label-position="left" label-width="100px" style="margin-left:50px;">
            <el-form-item label="名称" prop="name">
                <el-input v-model="form.name" placeholder="hive"/>
            </el-form-item>
            <el-form-item label="地址" prop="addr">
                <el-input v-model="form.addr" placeholder="ssh://git@10.72.17.44:10022/paper_man/server.git"/>
            </el-form-item>
            <el-form-item label="凭证" prop="authkey">
                <el-select v-model="form.authkey" placeholder="请选择凭证">
                    <el-option v-for="item in this.$store.getters.authkeys" :label="item.name" :value="item.id" :key="item.id"/>
                </el-select>
                <router-link :to="{ path: '/authkeys' }">
                    <el-button @click="dialogFormVisible = false" type="text">> 点我前往凭证管理</el-button>
                </router-link>
            </el-form-item>
            <el-form-item label="是否远程仓库" prop="is_remote">
                <el-checkbox v-model="form.is_remote"/>
                <span style="color:#E6A23C"> 勾选表示地址为远程git/svn仓库 </span>
            </el-form-item>
            <el-form-item label="类型" prop="type">
                <el-select v-model="form.type">
                    <el-option v-for="item in codeTypes" :key="item.value" :label="item.name" :value="item.value"/>
                </el-select>
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
    name: 'Codes',
    data() {
        return {
            form: {},
            dialogStatus: '',
            listLoading: false,
            dialogFormVisible: false,
            textMap: { update: '编辑', create: '新建' },
            codeTypes: [{ name: 'git', value: 'git' }, { name: 'svn', value: 'svn' }],
            rules: {
                name: [{ required: true, message: '请填入仓库名字', trigger: 'blur' },],
                addr: [{ required: true, message: '请填入仓库git/svn地址', trigger: 'blur' },],
                type :[{ required: true, message: '请选择代码类型', trigger: 'blur' },],
                authkey: [{ required: true, message: '请选择凭证', trigger: 'change' }],
            },
        }
    },
    created() {
        this.resetForm()
        var store = this.$store.getters
        if (store.proj) {
            this.loadCodes()
        }
        bus.$on('project', msg => {
            if (store.proj) {
                this.loadCodes()
            }
        })
    },
    methods: {
        loadCodes() {
            driver.load("codes").then(res => {
                utils.showNetRes(this, res, () => {
                    this.$store.dispatch("InitData", ["CODE", res.data])
                })
            })
        },
        resetForm() {
            this.form = {
                id: '',
                name: '',
                addr: '',
                type: '',
                authkey: '',
                is_remote: true,
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
        createData() {
            this.$refs['dataForm'].validate((valid) => {
                if (valid) {
                    this.form.id = utils.newGuid()
                    driver.insert("codes", this.form).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("AddData", ["CODE", res.data, "id"])
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
                    driver.update("codes", this.form).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("UpdateData", ["CODE", res.data, "id"])
                            this.dialogFormVisible = false
                        })
                    })
                }
            })
        },
        handleDelete(row) {
            this.$confirm('确定要删除此代码仓库，是否继续?', '提示', {
                confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
            }).then(() => {
                var codeids = []
                codeids.push(row.id)
                driver.remove("codes", codeids).then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("DelData", ["CODE", row.id, "id"])
                    })
                })
            }).catch(() => {})
        },
    }
}
</script>
