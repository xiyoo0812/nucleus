<template>
<div class="app-container">
    <h3>流水线管理</h3>
    <el-alert :closable="false" type="success" title="负责管理项目的所有流水线。"/>
    <div class="twt-tool-box">
        <el-button-group>
            <el-button class="filter-item" type="primary" @click="handleCreate">添加</el-button>
        </el-button-group>
    </div>
    <el-table stripe v-loading="listLoading" style="width: 100%" :data="$store.getters.pipelines">
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
    <el-dialog :title="textMap[dialogStatus]" :visible.sync="dialogFormVisible" :close-on-click-modal="false" width="80%">
        <el-form ref="dataForm" :rules="rules" :model="form" label-position="left" label-width="80px">
            <el-row :gutter="20">
                <el-col :span="10">
                    <el-card shadow="hover" class="mgb20" style="height:520px;">
                        <div class="item-title"> <span >{{ pipelineName }}</span></div>
                        <draggable v-model="doing" @remove="removeHandle" :options="dragOptions">
                        <transition-group tag="div" id="doing" class="item-ul">
                            <div v-for="item in doing" class="drag-list" :key="item.id">
                                {{item.content}}
                            </div>
                        </transition-group>
                    </draggable>
                    </el-card>
                </el-col>
                <el-col :span="14">
                    <el-card shadow="hover" style="height:520px;">
                        <el-form ref="pForm" :rules="rules" :model="pForm" label-position="left" label-width="80px">
                            <el-form-item label="名称" prop="name">
                                <Selecter v-model="pForm.name" :option="pForm.name" :options="$store.getters.plugins" @change="selectPlugin"/>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" @click="addPlugin()">添加插件</el-button>
                                <el-button type="primary" @click="savePlugin()">保存</el-button>
                                <el-button type="primary" @click="resetPlugin()">还原</el-button>
                            </el-form-item>
                            <el-form-item v-for="arg in pForm.args" :label="arg.desc" :prop="args">
                                <el-input v-if="arg.type==='Input'" v-model="arg.value" placeholder="输入参数"/>
                                <CodeEditor v-if="arg.type==='Shell'" v-model="arg.value" :code="arg.value" height="400px" language="text/x-sh"/>
                                <Selecter v-if="arg.type==='Args'" v-model="arg.value" :option="arg.value" :options="pipelineArgs[arg.name]" @change="selectArgs"/>
                                <Selecter v-if="arg.type==='Codes'" v-model="arg.value" :option="arg.value" :options="$store.getters.codes" @change="selectPlugin"/>
                                <Selecter v-if="arg.type==='Hosts'" v-model="arg.value" :option="arg.value" :options="$store.getters.hosts" @change="selectPlugin"/>
                            </el-form-item>
                        </el-form>
                    </el-card>
                </el-col>
            </el-row>
            <el-form-item>
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
import draggable from 'vuedraggable'
import bus from '../../components/common/bus'
import Selecter from '../../components/widget/Selecter.vue'
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
        draggable,
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
        this.pForm.args = [
            {value:"", name:"t1", type:"Input", desc:"t1d"},
            {value:"", name:"t2", type:"Codes", desc:"t2d"},
            {value:"", name:"t3", type:"Hosts", desc:"t3d"},
            {value:"", name:"t4", type:"Args", desc:"t4d"},
            {value:"", name:"t5", type:"Shell", desc:"t5d"},
        ]
    },
    data() {
        return {
            form: {},
            pipelineName: "测试",
            pipelineArgs: { "t4" : ["aaa", "bbb", "ccc"]},
            pForm: {
                name : "",
                args : []
            },
            doing: [
                {
                    id: 1,
                    content: '开发登录注册页面'
                },
                {
                    id: 2,
                    content: '开发头部组件'
                },
                {
                    id: 3,
                    content: '开发表格相关组件'
                },
                {
                    id: 4,
                    content: '开发表单相关组件'
                }
            ],
            dragOptions:{
                animation: 120,
                scroll: true,
                group: 'sortlist',
                ghostClass: 'ghost-style'
            },
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
        savePlugin() {
        },
        resetPlugin(row) {
        },
        resetForm() {
            this.form = {
                id: '',
                name: '',
                desc: '',
                plugins: [
                    {name : "111", id : 1},
                    {name : "222", id : 2},
                ],
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
<style scoped>
    .item-title{
        padding: 8px 8px 8px 12px;
        font-size: 14px;
        line-height: 1.5;
        color: #24292e;
        font-weight: 600;
    }
    .item-ul{
        padding: 0 8px 8px;
        height: 500px;
        overflow-y: scroll;
    }
    .item-ul::-webkit-scrollbar{
        width: 0;
    }
    .drag-list {
        border: 1px #e1e4e8 solid;
        padding: 10px;
        margin: 5px 0 10px;
        list-style: none;
        background-color: #fff;
        border-radius: 6px;
        cursor: pointer;
        -webkit-transition: border .3s ease-in;
        transition: border .3s ease-in;
    }
    .drag-list:hover {
        border: 1px solid #20a0ff;
    }
    .drag-title {
        font-weight: 400;
        line-height: 25px;
        margin: 10px 0;
        font-size: 22px;
        color: #1f2f3d;
    }
    .ghost-style{
        display: block;
        color: transparent;
        border-style: dashed
    }
</style>