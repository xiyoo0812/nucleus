<template>
<div class="app-container">
    <h3>流水线管理</h3>
    <el-alert :closable="false" type="success" title="负责管理项目的所有流水线。"/>
    <div class="twt-tool-box">
        <el-button-group>
            <el-button class="filter-item" type="primary" @click="handleCreate">添加</el-button>
        </el-button-group>
    </div>
    <el-table stripe v-loading="listLoading" style="width: 100%" :data="this.$store.getters.pipelines">
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
                <el-button size="mini" @click="handleRun(scope.row)">执行</el-button>
                <el-button size="mini" @click="handleUpdate(scope.row)">编辑</el-button>
                <el-button size="mini" type="danger" @click="handleDelete(scope.row)">删除</el-button>
            </template>
        </el-table-column>
    </el-table>
    <el-dialog :title="textMap[dialogStatus]" :visible.sync="dialogFormVisible" :close-on-click-modal="false" width="65%">
        <el-form ref="dataForm" :rules="rules" :model="form" label-position="left" label-width="80px">
            <el-form-item label="名称" prop="name">
                <el-input v-model="form.name" maxlength="20" placeholder="插件名称"/>
            </el-form-item>
            <el-form-item label="描述" prop="desc">
                <el-input v-model="form.desc" maxlength="100" placeholder="插件描述"/>
            </el-form-item>
            <el-form-item label="脚本" prop="script">
                <CodeEditor v-model="form.script" :code="form.script" height="400px" language="text/x-lua"/>
            </el-form-item>
            <el-form-item label="参数" prop="args">
                <el-table :data="form.args" height="200" stripe border style="width: 100%;">
                    <el-table-column label="名称">
                        <template slot-scope="scope">
                            <span v-if="!scope.row.edit" slot="reference" class="name-wrapper">{{ scope.row.name }}</span>
                            <span v-if="scope.row.edit" class="cell">
                                <el-input v-model="scope.row.name" placeholder="参数名称"></el-input>
                            </span>
                        </template>
                    </el-table-column>
                    <el-table-column label="类型">
                        <template slot-scope="scope">
                            <span v-if="!scope.row.edit" slot="reference" class="name-wrapper">{{ scope.row.type }}</span>
                            <span v-if="scope.row.edit" class="cell">
                                <el-select v-model="scope.row.type" placeholder="参数类型" clearable filterable>
                                    <el-option v-for="item in pluginArgTypes" :key="item" :label="item" :value="item"/>
                                </el-select>
                            </span>
                        </template>
                    </el-table-column>
                    <el-table-column label="描述">
                        <template slot-scope="scope">
                            <span v-if="!scope.row.edit" slot="reference" class="name-wrapper">{{ scope.row.desc }}</span>
                            <span v-if="scope.row.edit" class="cell">
                                <el-input v-model="scope.row.desc" placeholder="输入描述"></el-input>
                            </span>
                        </template>
                    </el-table-column>
                    <el-table-column label="操作">
                        <template slot-scope="scope">
                            <el-button v-if="scope.row.edit" size="mini" @click="savePlugArg(scope.row)">保存</el-button>
                            <el-button v-if="!scope.row.edit" size="mini" @click="scope.row.edit=true;argEdit=true">编辑</el-button>
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
    <el-dialog title="执行" :visible.sync="dialogRunVisible" :close-on-click-modal="false" width="65%">
        
    </el-dialog>
</div>
</template>

<script>
import * as utils from '../../utils/index'
import * as driver from '../../api/driver'
import bus from '../../components/common/bus'
import CodeEditor from '../../components/widget/CodeEditor.vue'

const example = `--plugin脚本
--插件开发使用lua语言

--init函数在插件初始化的时候执行
local plugin = {}
function plugin.init()
end

--run函数在插件运行的时候执行
function plugin.run()
end

return plugin
`

export default {
    name: 'Pipelines',
    components:{
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
    },
    data() {
        return {
            form: {},
            argEdit: false,
            dialogStatus: '',
            listLoading: false,
            dialogRunVisible: false,
            dialogFormVisible: false,
            textMap: { update: '编辑', create: '新建' },
            pluginArgTypes: ["Codes", "Hosts", "Args", "Input", "Auto"],
            rules: {
                name: [{ required: true, message: '请填入插件名字', trigger: 'blur' },],
                desc: [{ required: true, message: '请填入插件描述', trigger: 'blur' },],
                args: [{ required: true, message: '请填入插件参数', trigger: 'blur' },],
                script: [{ required: true, message: '请填入插件脚本', trigger: 'blur' },],
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
        savePlugArg(row) {
            if(row.name.length == 0 || row.type.length == 0 || row.desc.length == 0) {
                utils.showFailed(this, "参数不能为空")
                return
            }
            if (utils.array_count(this.form.args, row.name, "name") > 1) {
                utils.showFailed(this, "已经存在同名参数")
                return
            }
            row.edit = null
            this.argEdit = false
        },
        addPlugArg() {
            this.argEdit = true
            this.form.args.push({ edit: true, name: "", type: "", desc: "", })
        },
        delPlugArg(row) {
            utils.array_remove(this.form.args, row.name, "name")
        },
        resetForm() {
            this.argEdit = false
            this.form = {
                id: '',
                name: '',
                desc: '',
                args: [],
                script: example,
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
                fargs.push({type: arg.type, name: arg.name, desc: arg.desc })
            }
            form.args = fargs
            return form
        },
        createData() {
            this.$refs['dataForm'].validate((valid) => {
                if (valid) {
                    this.form.id = utils.newGuid()
                    driver.insert("pipelines", this.formatForm()).then(res => {
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
                    driver.update("pipelines", this.formatForm()).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("UpdateData", ["PIPELINE", res.data, "id"])
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
                driver.remove("pipelines", hostids).then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("DelData", ["PIPELINE", row.id, "id"])
                    })
                })
            }).catch(() => {})
        },
    }
}
</script>
