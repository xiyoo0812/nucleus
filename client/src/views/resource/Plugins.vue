<template>
<div class="app-container">
    <h3>插件管理</h3>
    <el-alert :closable="false" type="success" title="负责管理系统的所有插件。"/>
    <div class="twt-tool-box">
        <el-button-group>
            <el-button class="filter-item" type="primary" @click="handleCreate">添加</el-button>
        </el-button-group>
    </div>
    <el-table stripe v-loading="listLoading" style="width: 100%" :data="this.$store.getters.plugins">
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
    <el-dialog :title="textMap[dialogStatus]" :visible.sync="dialogFormVisible" :close-on-click-modal="false" >
        <el-form ref="dataForm" :rules="rules" :model="form" label-position="left" label-width="80px">
            <el-form-item label="名称" prop="name">
                <el-input v-model="form.name" placeholder="插件名称"/>
            </el-form-item>
            <el-form-item label="描述" prop="desc">
                <el-input v-model="form.desc" placeholder="插件描述"/>
            </el-form-item>
            <el-tab-pane label="参数定义" name="args">
                <el-form :inline="true" ref="argForm" :rules="rules2" :model="argform" label-position="left" label-width="100px">
                    <el-form-item label="参数类型" prop="type">
                        <el-select v-model="argform.type" placeholder="请选择参数类型" clearable filterable @change="selectPlugType">
                            <el-option v-for="item in pluginArgTypes" :key="item" :label="item" :value="item"/>
                        </el-select>
                    </el-form-item>
                    <el-form-item label="参数名" prop="value">
                        <el-input v-model="argform.name" placeholder="请输入参数名" />
                    </el-form-item>
                    <el-form-item label="参数描述" prop="value">
                        <el-input v-model="argform.desc" placeholder="请输入参数名" />
                    </el-form-item>
                    <el-button type="primary" @click="addPlugArg()">添加</el-button>
                </el-form>
                <el-table :data="args" height="320" stripe border style="width: 100%;">
                    <el-table-column label="名称">
                        <template slot-scope="scope">
                            <span style="margin-left: 10px">{{ scope.row.name }}</span>
                        </template>
                    </el-table-column>
                    <el-table-column label="类型">
                        <template slot-scope="scope">
                            <span style="margin-left: 10px">{{ scope.row.type }}</span>
                        </template>
                    </el-table-column>
                    <el-table-column label="描述">
                        <template slot-scope="scope">
                            <span style="margin-left: 10px">{{ scope.row.desc }}</span>
                        </template>
                    </el-table-column>
                    <el-table-column label="操作">
                        <template slot-scope="scope">
                            <el-button v-if="scope.row.edit" size="mini" @click="scope.row.edit=false">保存</el-button>
                            <el-button v-if="!scope.row.edit" size="mini" @click="scope.row.edit=true">编辑</el-button>
                            <el-button size="mini" type="danger" @click="deletePlugArg(scope.row)">删除</el-button>
                        </template>
                    </el-table-column>
                </el-table>
            </el-tab-pane>
            <el-form-item label="脚本" prop="desc">
                <el-input v-model="form.script" placeholder="插件脚本"/>
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
    name: 'Plugins',
    data() {
        return {
            form: {},
            argform: {},
            dialogStatus: '',
            listLoading: false,
            dialogFormVisible: false,
            textMap: { update: '编辑', create: '新建' },
            pluginArgTypes: ["Codes", "Hosts", "Args", "Input", "Auto"],
            rules: {
                name: [{ required: true, message: '请填入插件名字', trigger: 'blur' },],
                desc: [{ required: true, message: '请填入插件描述', trigger: 'blur' },],
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
        loadHosts() {
            driver.load("plugins").then(res => {
                utils.showNetRes(this, res, () => {
                    this.$store.dispatch("InitData", ["PLUGIN", res.data])
                })
            })
        },
        resetForm() {
            this.form = {
                id: '',
                name: '',
                desc: '',
                args: '',
                script: '',
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
                    driver.insert("plugins", this.form).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("AddData", ["PLUGIN", res.data, "id"])
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
                    driver.update("plugins", this.form).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("UpdateData", ["PLUGIN", res.data, "id"])
                            this.dialogFormVisible = false
                        })
                    })
                }
            })
        },
        handleDelete(row) {
            this.$confirm('确定要删除此插件，是否继续?', '提示', {
                confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
            }).then(() => {
                var hostids = []
                hostids.push(row.id)
                driver.remove("plugins", hostids).then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("DelData", ["PLUGIN", row.id, "id"])
                    })
                })
            }).catch(() => {})
        },
    }
}
</script>
