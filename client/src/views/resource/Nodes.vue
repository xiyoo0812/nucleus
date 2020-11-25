<template>
<div class="app-container">
    <el-card>
        <el-alert :closable="false" type="success" title="负责管理运行节点。"/>
        <el-button-group style="margin-top:10px; margin-bottom:10px;">
            <el-button type="primary" style="margin-right:10px;" @click="handleCreate">添加</el-button>
        </el-button-group>
        <el-table stripe v-loading="listLoading" style="width: 100%" :data="filterNodes">
            <el-table-column label="名称">
                <template slot-scope="scope"><span >{{ scope.row.name }}</span></template>
            </el-table-column>
            <el-table-column label="索引">
                <template slot-scope="scope"><span >{{ scope.row.index }}</span></template>
            </el-table-column>
            <el-table-column label="创建者">
                <template slot-scope="scope"><span >{{ scope.row.creator }}</span></template>
            </el-table-column>
            <el-table-column label="主机">
                <template slot-scope="scope"><span >{{ scope.row.host }}</span></template>
            </el-table-column>
            <el-table-column label="环境">
                <template slot-scope="scope"><span >{{ scope.row.environ }}</span></template>
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
    </el-card>
    <el-dialog :title="textMap[dialogStatus]" :visible.sync="dialogFormVisible" :close-on-click-modal="false" >
        <el-form ref="dataForm" :rules="rules" :model="form" label-position="left" label-width="80px">
            <el-row :gutter="10">
                <el-col :span="12">
                    <el-form-item label="主机" prop="host">
                        <Selecter v-model="form.host" :option="form.host" clear="true" opid="ip" placeholder="请选择主机" 
                            :options="$store.getters.hosts" @change="rebuildArgs"/>
                    </el-form-item>
                </el-col>
                <el-col :span="12">
                    <el-form-item label="环境" prop="environ">
                        <Selecter v-model="form.environ" :option="form.environ" clear="true" opid="variable" placeholder="请选择环境" 
                            :options="$store.getters.environs" @change="rebuildArgs"/>
                    </el-form-item>
                </el-col>
                <el-col :span="12">
                    <el-form-item label="共享配置" prop="template">
                        <Selecter v-model="form.share" :option="form.share" clear="true" opid="name" placeholder="请选择共享配置" 
                            :options="filterShare" @change="rebuildArgs"/>
                    </el-form-item>
                </el-col>
                <el-col :span="12">
                    <el-form-item label="独享配置" prop="template">
                        <Selecter v-model="form.template" :option="form.template" clear="true" opid="name" placeholder="请选择独享配置" 
                            :options="filterTemplate" @change="rebuildArgs"/>
                    </el-form-item>
                </el-col>
                <el-col :span="12">
                    <el-form-item label="名称" prop="name">
                        <el-input v-model="form.name" placeholder="输入英文名称"/>
                    </el-form-item>
                </el-col>
                <el-col :span="12">
                    <el-form-item label="索引" prop="index">
                        <el-input v-model="form.index" placeholder="输入索引"/>
                    </el-form-item>
                </el-col>
            </el-row>
            <el-form-item label="环境变量" prop="args">
                <el-table :data="form.args" height="400" stripe border style="width: 100%;">
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
                    <el-table-column label="描述">
                        <template slot-scope="scope">
                            <span v-if="!scope.row.edit" slot="reference" class="name-wrapper">{{ scope.row.desc }}</span>
                            <span v-if="scope.row.edit" class="cell">
                                <el-input v-model="scope.row.desc" placeholder="名称"></el-input>
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
import Selecter from '../../components/widget/Selecter.vue'

export default {
    name: 'Nodes',
    components:{
        Selecter,
    },
    data() {
        return {
            form: {},
            host: "",
            environ: "",
            argEdit: false,
            dialogStatus: '',
            listLoading: false,
            dialogFormVisible: false,
            variableTypes: [ "string", "number" ],
            textMap: { update: '编辑', create: '新建' },
            rules: {
                name: [{ required: true, message: '请填入名称', trigger: 'blur' },],
                host: [{ required: true, message: '请选择主机', trigger: 'blur' },],
                index: [{ required: true, message: '请填入索引', trigger: 'blur' },],
                args: [{ required: true, message: '请填入环境变量', trigger: 'blur' },],
                environ: [{ required: true, message: '请选择环境', trigger: 'blur' },],
                share: [{ required: true, message: '请选择共享配置', trigger: 'blur' },],
                template: [{ required: true, message: '请选择独享配置', trigger: 'blur' },],
            },
        }
    },
    created() {
        this.resetForm()
        var store = this.$store.getters
        if (store.proj) {
            bus.$emit('load_nodes')
            bus.$emit('load_environs')
            bus.$emit('load_templates')
        }
        bus.$on('project', msg => {
            if (store.proj) {
                bus.$emit('load_nodes', true)
                bus.$emit('load_environs', true)
                bus.$emit('load_templates', true)
            }
        })
    },
    computed: {
        filterNodes() {
            return this.$store.getters.nodes.filter(node => {
                if (this.host != "" && node.host != this.host){
                    return false
                }
                if (this.environ != "" && node.environ != this.environ){
                    return false
                }
                return true
            })
        },
        filterShare() {
            return this.$store.getters.templates.filter(template => {
                return !template.name.indexOf("share")
            })
        },
        filterTemplate() {
            return this.$store.getters.templates.filter(template => {
                return template.name.indexOf("share")
            })
        }
    },
    methods: {
        formatEnviron(row) {
            var environ = utils.array_find(this.$store.getters.environs, row.environ, "id")
            if (environ) {
                return environ.name
            }
            return row.environ
        },
        savePlugArg(row) {
            if(row.value == "" || row.variable == "") {
                utils.showFailed(this, "参数不能为空")
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
            this.form.args.push({ edit: true, variable: "", desc: "", value : "" })
        },
        editPlugArg(row) {
            if (!this.argEdit) {
                row.edit = true
                this.argEdit = true
            }
        },
        delPlugArg(row) {
            utils.array_remove(this.form.args, row.variable, "variable")
        },
        rebuildArgs(){
            this.form.args = []
            if (this.form.host){
                this.form.args.push({ variable: "QUANTA_HOST_IP", desc: "主机IP", value : this.form.host })
            }
            if (this.form.environ){
                this.form.args.push({ variable: "QUANTA_HOST_IP", desc: "部署环境", value : this.form.environ })
            }
            if (this.form.share){
                var share = utils.array_find(this.$store.getters.templates, this.form.share, "name")
                if (share) {
                    for (let item of share.args) {
                        this.form.args.push(item)
                    }
                }
            }
            if (this.form.template){
                var template = utils.array_find(this.$store.getters.templates, this.form.template, "name")
                if (template) {
                    for (let item of template.args) {
                        this.form.args.push(item)
                    }
                }
            }
        },
        resetForm() {
            this.argEdit = false
            this.form = {
                index: 1,
                name: '',
                desc: '',
                host: null,
                share: null,
                environ: null,
                template: null,
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
                if (arg.value != "" && arg.variable != "") {
                    fargs.push({desc: arg.desc, value: arg.value, variable: arg.variable })
                }
            }
            form.args = fargs
            return form
        },
        createData() {
            this.$refs['dataForm'].validate((valid) => {
                if (valid) {
                    this.form.id = utils.newGuid()
                    driver.insert("nodes", this.formatForm()).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("AddData", ["NODE", res.data, "id"])
                            this.dialogFormVisible = false
                        })
                    })
                }
            })
        },
        handleUpdate(row) {
            this.form = Object.assign({}, row) // copy obj
            this.form.args = []
            this.argEdit = false
            for (var arg of row.args) {
                this.form.args.push({edit: false, desc: arg.desc, value: arg.value, variable: arg.variable })
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
                    driver.update("nodes", this.formatForm()).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("UpdateData", ["NODE", res.data, "id"])
                            this.dialogFormVisible = false
                        })
                    })
                }
            })
        },
        handleDelete(row) {
            this.$confirm('确定要删除此节点，是否继续?', '提示', {
                confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
            }).then(() => {
                var dbids = []
                dbids.push(row.id)
                driver.remove("nodes", dbids).then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("DelData", ["NODE", row.id, "id"])
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
