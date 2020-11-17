<template>
<div class="app-container">
    <el-card>
        <el-alert :closable="false" type="success" title="负责管理游戏环境。"/>
        <el-button-group style="margin-top:10px; margin-bottom:10px;">
            <el-button class="filter-item" type="primary" style="margin-right:10px;" @click="handleCreate">添加</el-button>
            <el-button class="filter-item" type="primary" style="margin-right:10px;" @click="handleDownload">导出</el-button>
        </el-button-group>
        <el-table stripe v-loading="listLoading" style="width: 100%" :data="$store.getters.environs">
            <el-table-column label="名称">
                <template slot-scope="scope"><span >{{ scope.row.name }}</span></template>
            </el-table-column>
            <el-table-column label="变量名">
                <template slot-scope="scope"><span >{{ scope.row.variable }}</span></template>
            </el-table-column>
            <el-table-column label="创建者">
                <template slot-scope="scope"><span >{{ scope.row.creator }}</span></template>
            </el-table-column>
            <el-table-column label="描述">
                <template slot-scope="scope"><span >{{ scope.row.desc }}</span></template>
            </el-table-column>
            <el-table-column label="操作">
                <template slot-scope="scope">
                    <el-button size="mini" @click="handleUpdate(scope.row)">编辑</el-button>
                    <el-button size="mini" type="danger" @click="handleDelete(scope.row)">删除</el-button>
                </template>
            </el-table-column>
        </el-table>
        <div class="pagination-container">
            <el-pagination v-show="total>0" :total="total" layout="total"/>
        </div>
    </el-card>
    <el-dialog :title="textMap[dialogStatus]" :visible.sync="dialogFormVisible" :close-on-click-modal="false" >
        <el-form ref="dataForm" :rules="rules" :model="form" label-position="left" label-width="80px">
            <el-form-item label="名称" prop="name">
                <el-input v-model="form.name" placeholder="输入名称"/>
            </el-form-item>
            <el-form-item label="变量名" prop="variable">
                <el-input v-model="form.variable" placeholder="输入变量名"/>
            </el-form-item>
            <el-form-item label="描述" prop="desc">
                <el-input v-model="form.desc" placeholder="输入描述"/>
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

import * as utils from '../../utils/index'
import * as driver from '../../api/driver'
import bus from '../../components/common/bus'

export default {
    name: 'Environs',
    data() {
        return {
            form: {},
            dialogStatus: '',
            listLoading: false,
            dialogFormVisible: false,
            textMap: { update: '编辑', create: '新建' },
            rules: {
                name: [{ required: true, message: '请填入名称', trigger: 'blur' },],
                variable: [{ required: true, message: '请填入变量名', trigger: 'blur' },],
                desc: [{ required: true, message: '请填入描述', trigger: 'blur' },],
            },
        }
    },
    created() {
        this.resetForm()
        var store = this.$store.getters
        if (store.proj) {
            bus.$emit('load_environs')
        }
        bus.$on('project', msg => {
            if (store.proj) {
                bus.$emit('load_environs', true)
            }
        })
    },
    methods: {
        resetForm() {
            this.form = {
                name: '',
                variable: '',
                desc: '',
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
                    driver.insert("environs", this.form).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("AddData", ["ENVIRON", res.data, "id"])
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
                    driver.update("environs", this.form).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("UpdateData", ["ENVIRON", res.data, "id"])
                            this.dialogFormVisible = false
                        })
                    })
                }
            })
        },
        handleDelete(row) {
            this.$confirm('确定要删除此环境，是否继续?', '提示', {
                confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
            }).then(() => {
                var dbids = []
                dbids.push(row.id)
                driver.remove("environs", dbids).then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("DelData", ["ENVIRON", row.id, "id"])
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
