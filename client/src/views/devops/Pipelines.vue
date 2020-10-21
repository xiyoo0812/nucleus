<template>
<div class="app-container">
    <h3>流水线管理</h3>
    <el-alert :closable="false" type="success" title="负责管理项目的所有流水线。"/>
    <el-row :gutter="20">
        <el-col :span="12">
            <el-card shadow="hover" class="mgb20" style="height:600px;">
                <div class="twt-tool-box">
                    <el-button-group>
                        <el-button class="filter-item" type="primary" @click="handleCreate">添加流水线</el-button>
                    </el-button-group>
                </div>
                <el-table stripe v-loading="listLoading" style="width: 100%" highlight-current-row @current-change="handleCurrent" :data="$store.getters.pipelines">
                    <el-table-column width="150" label="名称">
                        <template slot-scope="scope"><span >{{ scope.row.name }}</span></template>
                    </el-table-column>
                    <el-table-column label="描述">
                        <template slot-scope="scope"><span >{{ scope.row.desc }}</span></template>
                    </el-table-column>
                    <el-table-column width="80" label="创建者">
                        <template slot-scope="scope"><span >{{ scope.row.creator }}</span></template>
                    </el-table-column>
                    <el-table-column width="250" label="操作" align="center">
                        <template slot-scope="scope">
                            <el-button size="mini" @click="handleRun(scope.row)">执行</el-button>
                            <el-button size="mini" @click="handleUpdate(scope.row)">编辑</el-button>
                            <el-button size="mini" type="danger" @click="handleDelete(scope.row)">删除</el-button>
                        </template>
                    </el-table-column>
                </el-table>
            </el-card>
        </el-col>
        <el-col :span="12">
            <el-card shadow="hover" class="mgb20" style="height:600px;">
                <div class="twt-tool-box">
                    <el-button-group>
                        <el-button class="filter-item" type="primary" @click="handleCreatePlugin">添加插件</el-button>
                    </el-button-group>
                </div>
                <el-table stripe v-loading="listLoading" style="width: 100%" :data="pipeline.plugins">
                    <el-table-column label="名称">
                        <template slot-scope="scope"><span >{{ scope.row.name }}</span></template>
                    </el-table-column>
                    <el-table-column label="描述">
                        <template slot-scope="scope"><span >{{ scope.row.desc }}</span></template>
                    </el-table-column>
                    <el-table-column label="操作">
                        <template slot-scope="scope">
                            <el-button size="mini" @click="handleEdit(scope.row)">编辑</el-button>
                            <el-button size="mini" type="danger" @click="handleRemove(scope.row)">删除</el-button>
                        </template>
                    </el-table-column>
                </el-table>
            </el-card>
        </el-col>
    </el-row>
    <el-dialog :title="textMap[dialogStatus]" :visible.sync="dialogFormVisible" :close-on-click-modal="false" width="50%">
        <el-form ref="dataForm" :rules="rules" :model="form" label-position="left" label-width="80px">
            <el-form-item label="名称" prop="name">
                <el-input v-model="form.name" maxlength="20" placeholder="流水线名称"/>
            </el-form-item>
            <el-form-item label="描述" prop="desc">
                <el-input v-model="form.desc" maxlength="100" placeholder="流水线描述"/>
            </el-form-item>
            <el-form-item>
                <el-button type="primary" @click="dialogStatus==='create'?createData():updateData()">确认</el-button>
                <el-button @click="dialogFormVisible = false">取消</el-button>
            </el-form-item>
        </el-form>
    </el-dialog>
    <el-dialog :title="textMap[dialogStatus]" :visible.sync="dialogPluginVisible" :close-on-click-modal="false" width="50%">
        <el-form ref="pluginForm" :rules="rules" :model="pform" label-position="left" label-width="80px">
            <el-form-item label="名称" prop="name">
                <Selecter v-model="pform.id" :option="pform.id" :options="$store.getters.plugins" @change="selectPlugin"/>
            </el-form-item>
            <template v-for="arg in pform.args">
                <el-form-item v-if="arg.type==='Input'" :label="arg.desc" :prop="args">
                    <el-input v-model="arg.value" placeholder="输入参数"/>
                </el-form-item>
                <el-form-item v-if="arg.type==='Shell'" :label="arg.desc" :prop="args">
                    <CodeEditor v-model="arg.value" :code="arg.value" height="350px" language="text/x-sh"/>
                </el-form-item>
                <el-form-item v-if="arg.type==='Args'" :label="arg.desc" :prop="args">
                    <Selecter v-model="arg.value" :option="arg.value" :options="pipeline.args[arg.custom]" @change="selectArgs($event, arg)"/>
                </el-form-item>
                <el-form-item v-if="arg.type==='Resource'" :label="arg.desc" :prop="args">
                    <Selecter v-model="arg.value" :option="arg.value" :options="$store.getters[arg.custom]" @change="selectArgs($event, arg)"/>
                </el-form-item>
            </template>
            <el-form-item>
                <el-button type="primary" @click="dialogStatus==='create'?createData():updateData()">确认</el-button>
                <el-button @click="dialogPluginVisible = false">取消</el-button>
            </el-form-item>
        </el-form>
    </el-dialog>
    <el-dialog title="执行" :visible.sync="dialogRunVisible" :close-on-click-modal="false" width="65%">
        
    </el-dialog>
</div>
</template>

<script>
import * as utils from '../../utils/index'
import * as driver from '../../api/driver'
import bus from '../../components/common/bus'
import Selecter from '../../components/widget/Selecter.vue'
import CodeEditor from '../../components/widget/CodeEditor.vue'

export default {
    name: 'Pipelines',
    components:{
        Selecter,
        CodeEditor
    },
    created() {
        this.resetForm()
        var store = this.$store.getters
        if (store.proj) {
            this.loadPipelines()
        }
        bus.$on('project', msg => {
            if (store.proj) {
                this.loadPipelines()
            }
        })
        bus.$on('project', msg => {
            if (store.proj) {
                this.loadPipelines()
            }
        })
    },
    data() {
        return {
            form: {},
            pform: {},
            pipeline : {
                plugins: [],
                args: {},
            },
            dialogStatus: '',
            listLoading: false,
            pluginLoading: false,
            dialogRunVisible: false,
            dialogFormVisible: false,
            dialogPluginVisible: false,
            textMap: { update: '编辑', create: '新建' },
            rules: {
                name: [{ required: true, message: '请填入流水线名字', trigger: 'blur' },],
                desc: [{ required: true, message: '请填入流水线描述', trigger: 'blur' },],
            },
        }
    },
    methods: {
        loadPipelines() {
            driver.load("pipelines").then(res => {
                utils.showNetRes(this, res, () => {
                    this.$store.dispatch("InitData", ["PIPELINE", res.data])
                })
            })
        },
        resetForm() {
            this.form = {
                id: '',
                name: '',
                desc: '',
                plugins: [],
                args: [],
            }
        },
        resetPForm() {
            this.pform = {
                id: '',
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
        handleCurrent(val) {
            this.pipeline = val
        },
        handleCreatePlugin() {
            this.resetPForm()
            this.dialogStatus = 'create'
            this.dialogPluginVisible = true
            this.$nextTick(() => {
                this.$refs['pluginForm'].clearValidate()
            })
        },
        selectPlugin(id, item) {
            this.pform.args = []
            this.pform.name = item.name
            this.pform.desc = item.desc
            this.pform.script = item.script
            for (var arg of item.args) {
                this.pform.args.push({ custom: arg.custom, name: arg.name, type: arg.type, desc: arg.desc })
            }
        },
        selectArgs(id, arg) {

        },
        createData() {
            this.$refs['dataForm'].validate((valid) => {
                if (valid) {
                    this.form.id = utils.newGuid()
                    driver.insert("pipelines", this.form).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("AddData", ["PIPELINE", res.data, "id"])
                            this.dialogFormVisible = false
                        })
                    })
                }
            })
        },
        handleRun(row) {
            
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
                    driver.update("pipelines", this.form).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("UpdateData", ["PIPELINE", res.data, "id"])
                            this.dialogFormVisible = false
                        })
                    })
                }
            })
        },
        handleDelete(row) {
            this.$confirm('确定要删除此流水线，是否继续?', '提示', {
                confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
            }).then(() => {
                var pipelineids = []
                pipelineids.push(row.id)
                driver.remove("pipelines", pipelineids).then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("DelData", ["PIPELINE", row.id, "id"])
                    })
                })
            }).catch(() => {})
        },
    }
}
</script>