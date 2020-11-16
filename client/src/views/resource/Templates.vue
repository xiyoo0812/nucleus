<template>
<div class="app-container">
    <h3>配置模板</h3>
    <el-alert :closable="false" type="success" title="负责管理配置模板。"/>
    <div class="twt-tool-box">
        <el-button-group>
            <el-button class="filter-item" type="primary" @click="handleCreate">添加</el-button>
        </el-button-group>
    </div>
    <el-table stripe v-loading="listLoading" style="width: 100%" :data="$store.getters.templates">
        <el-table-column label="名称">
            <template slot-scope="scope"><span >{{ scope.row.name }}</span></template>
        </el-table-column>
        <el-table-column label="描述">
            <template slot-scope="scope"><span >{{ scope.row.desc }}</span></template>
        </el-table-column>
        <el-table-column label="创建者">
            <template slot-scope="scope"><span >{{ scope.row.creator }}</span></template>
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
                <el-input v-model="form.name" placeholder="输入英文名称"/>
            </el-form-item>
            <el-form-item label="描述" prop="desc">
                <el-input v-model="form.desc" placeholder="输入描述"/>
            </el-form-item>
            <el-form-item label="模板参数" prop="args">
                <el-table :data="form.args" height="200" stripe border style="width: 100%;">
                    <el-table-column label="名称">
                        <template slot-scope="scope">
                            <span v-if="!scope.row.edit" slot="reference" class="name-wrapper">{{ scope.row.name }}</span>
                            <span v-if="scope.row.edit" class="cell">
                                <el-input v-model="scope.row.name" placeholder="名称"></el-input>
                            </span>
                        </template>
                    </el-table-column>
                    <el-table-column label="变量名">
                        <template slot-scope="scope">
                            <span v-if="!scope.row.edit" slot="reference" class="name-wrapper">{{ scope.row.variable }}</span>
                            <span v-if="scope.row.edit" class="cell">
                                <el-input v-model="scope.row.variable" placeholder="变量名"></el-input>
                            </span>
                        </template>
                    </el-table-column>
                    <el-table-column label="变量值">
                        <template slot-scope="scope">
                            <span v-if="!scope.row.edit" slot="reference" class="name-wrapper">{{ scope.row.value }}</span>
                            <span v-if="scope.row.edit" class="cell">
                                <el-input v-model="scope.row.value" placeholder="变量值"></el-input>
                            </span>
                        </template>
                    </el-table-column>
                    <el-table-column label="变量类型">
                        <template slot-scope="scope">
                            <span v-if="!scope.row.edit" slot="reference" class="name-wrapper">{{ scope.row.type }}</span>
                            <span v-if="scope.row.edit" class="cell">
                                <el-select v-model="scope.row.type" placeholder="变量类型" clearable filterable>
                                    <el-option v-for="item in variableTypes" :key="item" :label="item" :value="item"/>
                                </el-select>
                            </span>
                        </template>
                    </el-table-column>
                    <el-table-column label="变量描述">
                        <template slot-scope="scope">
                            <span v-if="!scope.row.edit" slot="reference" class="name-wrapper">{{ scope.row.desc }}</span>
                            <span v-if="scope.row.edit" class="cell">
                                <el-input v-model="scope.row.desc" placeholder="输入变量描述"></el-input>
                            </span>
                        </template>
                    </el-table-column>
                    <el-table-column label="操作">
                        <template slot-scope="scope">
                            <el-button v-if="scope.row.edit" size="mini" @click="savePlugArg(scope.row)">保存</el-button>
                            <el-button v-if="!scope.row.edit" size="mini" @click="editPlugArg(scope.row)">编辑</el-button>
                            <el-button v-if="!scope.row.edit" size="mini" type="danger" @click="delPlugArg(scope.row)">删除</el-button>
                        </template>
                    </el-table-column>
                </el-table>
            </el-form-item>
            <el-form-item>
                <el-button v-if="!argEdit" type="primary" @click="addPlugArg()">添加参数</el-button>
                <el-button v-if="!argEdit" type="primary" @click="dialogStatus==='create'?createData():updateData()">确认</el-button>
                <el-button @click="dialogFormVisible = false">取消</el-button>
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
    name: 'Templates',
    data() {
        return {
            form: {},
            argEdit: false,
            dialogStatus: '',
            listLoading: false,
            dialogFormVisible: false,
            variableTypes: [ "string", "number" ],
            textMap: { update: '编辑', create: '新建' },
            rules: {
                args: [{ required: true, message: '请填入模板参数', trigger: 'blur' },],
                name: [{ required: true, message: '请填入名称', trigger: 'blur' },],
                desc: [{ required: true, message: '请填入描述', trigger: 'blur' },],
            },
        }
    },
    created() {
        this.resetForm()
        var store = this.$store.getters
        if (store.proj) {
            bus.$emit('load_templates')
        }
        bus.$on('project', msg => {
            if (store.proj) {
                bus.$emit('load_templates', true)
            }
        })
    },
    methods: {
        savePlugArg(row) {
            if(row.name.length == 0 || row.type.length == 0 || row.desc.length == 0 || row.value.length == 0 || row.variable.length == 0) {
                utils.showFailed(this, "参数不能为空")
                return
            }
            if (utils.array_count(this.form.args, row.name, "name") > 1) {
                utils.showFailed(this, "已经存在同名参数")
                return
            }
            if (utils.array_count(this.form.args, row.variable, "variable") > 1) {
                utils.showFailed(this, "已经存在同名变量")
                return
            }
            row.edit = null
            this.argEdit = false
        },
        addPlugArg() {
            this.argEdit = true
            this.form.args.push({ edit: true, variable: "", name: "", type: "", value : "", desc: "" })
        },
        editPlugArg(row) {
            if (!this.argEdit) {
                row.edit = true
                this.argEdit = true
            }
        },
        delPlugArg(row) {
            utils.array_remove(this.form.args, row.name, "name")
        },
        resetForm() {
            this.argEdit = false
            this.form = {
                name: '',
                desc: '',
                args: [],
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
        formatForm() {
            var fargs = []
            var form = Object.assign({}, this.form) // copy obj
            for (var arg of form.args) {
                if (arg.type.length > 0 && arg.name.length > 0 && arg.desc.length > 0) {
                    fargs.push({type: arg.type, value: arg.value, variable: arg.variable, name: arg.name, desc: arg.desc })
                }
            }
            form.args = fargs
            return form
        },
        createData() {
            this.$refs['dataForm'].validate((valid) => {
                if (valid) {
                    this.form.id = utils.newGuid()
                    driver.insert("templates", this.formatForm()).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("AddData", ["TEMPLATE", res.data, "id"])
                            this.dialogFormVisible = false
                        })
                    })
                }
            })
        },
        handleUpdate(row) {
            this.form = Object.assign({}, row) // copy obj
            this.dialogStatus = 'update'
            this.argEdit = false
            this.dialogFormVisible = true
            this.$nextTick(() => {
                this.$refs['dataForm'].clearValidate()
            })
        },
        updateData() {
            this.$refs['dataForm'].validate((valid) => {
                if (valid) {
                    driver.update("templates", this.formatForm()).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("UpdateData", ["TEMPLATE", res.data, "id"])
                            this.dialogFormVisible = false
                        })
                    })
                }
            })
        },
        handleDelete(row) {
            this.$confirm('确定要删除此模板，是否继续?', '提示', {
                confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
            }).then(() => {
                var dbids = []
                dbids.push(row.id)
                driver.remove("templates", dbids).then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("DelData", ["TEMPLATE", row.id, "id"])
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
