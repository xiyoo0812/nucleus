<template>
<div class="app-container">
    <el-card>
        <el-alert :closable="false" type="success" title="负责管理系统的所有插件。"/>
        <div class="twt-tool-box">
            <el-button-group>
                <el-button class="filter-item" type="primary" @click="handleCreate">添加</el-button>
            </el-button-group>
        </div>
        <el-table stripe v-loading="listLoading" style="width: 100%" :data="$store.getters.plugins">
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
                    <el-button size="mini" @click="handleCopy(scope.row)">复制</el-button>
                    <el-button size="mini" @click="handleUpdate(scope.row)">编辑</el-button>
                    <el-button size="mini" type="danger" @click="handleDelete(scope.row)">删除</el-button>
                </template>
            </el-table-column>
        </el-table>
    </el-card>
    <el-dialog :title="textMap[dialogStatus]" :visible.sync="dialogFormVisible" :close-on-click-modal="false" width="65%">
        <el-form ref="dataForm" :rules="rules" :model="form" label-position="left" label-width="100px">
            <el-form-item label="插件名称" prop="name">
                <el-input v-model="form.name" maxlength="20" placeholder="插件名称"/>
            </el-form-item>
            <el-form-item label="插件描述" prop="desc">
                <el-input v-model="form.desc" maxlength="100" placeholder="插件描述"/>
            </el-form-item>
            <el-form-item label="插件配置脚本" prop="init_book">
                <Selecter v-model="form.init_book" :option="form.init_book" clear="true" :options="this.$store.getters.playbooks"/>
            </el-form-item>
            <el-form-item label="插件运行脚本" prop="run_book">
                <Selecter v-model="form.run_book" :option="form.run_book" clear="true" :options="this.$store.getters.playbooks"/>
            </el-form-item>
            <el-form-item label="插件逻辑代码" prop="script">
                <CodeEditor v-model="form.script" :code="form.script" height="400px" language="text/x-lua"/>
            </el-form-item>
            <el-form-item label="插件参数" prop="args">
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
                    <el-table-column label="自定义参数">
                        <template slot-scope="scope">
                            <span v-if="!scope.row.edit" slot="reference" class="name-wrapper">{{ scope.row.custom }}</span>
                            <span v-if="scope.row.edit" class="cell">
                                <el-input v-model="scope.row.custom" placeholder="输入描述"></el-input>
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
import CodeEditor from '../../components/widget/CodeEditor.vue'

const example = `--plugin脚本
--插件开发使用lua语言
--调用shell或者ansible指令
--local ok, res/err = shell.execute(cmd, timeout?)
--local ok, res/err = ansible.shell(cmd, timeout?)
--local ok, res/err = ansible.playbook(book, args)
--local ok, res/err = ansible.playbookid(bookid, args)
--local proj_db     = nucleus.proj_db

local plugin = {}

--[[
--解析输出参数
local function parse_output_args(str)
  	return {}	
end

--init函数在插件初始化的时候执行
function plugin.init(args, playbook)
  	local sok, sres = ansible.playbookid(playbook, args)
    if not sok then
        return -1, sres
    end
    if sres.output then
  		sres.args = parse_output_args(sres.output.msg)
    	sres.output = nil
    end
    return 0, sres
end
]]

--run函数在插件运行的时候执行
function plugin.run(args, playbook)
    local sok, sres = ansible.playbookid(playbook, args)
    if not sok then
        return -1, sres
    end
    return 0, sres
end

return plugin

`

export default {
    name: 'Plugins',
    components:{
        Selecter,
        CodeEditor
    },
    created() {
        this.resetForm()
        bus.$emit('load_plugins')
        bus.$emit('load_playbooks')
    },
    data() {
        return {
            form: {},
            argEdit: false,
            dialogStatus: '',
            listLoading: false,
            dialogFormVisible: false,
            textMap: { update: '编辑', create: '新建' },
            pluginArgTypes: ["Resource", "Args", "Input", "Shell"],
            rules: {
                name: [{ required: true, message: '请填入插件名字', trigger: 'blur' },],
                desc: [{ required: true, message: '请填入插件描述', trigger: 'blur' },],
                script: [{ required: true, message: '请填入插件脚本', trigger: 'blur' },],
            },
        }
    },
    methods: {
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
            this.form.args.push({ edit: true, custom: "", name: "", type: "", desc: "" })
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
                id: '',
                name: '',
                desc: '',
                run_book: '',
                init_book: '',
                script: example,
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
        handleCopy(row) {
            this.form = Object.assign({}, row) // copy obj
            this.form.name = ""
            this.form.id = null
            this.form.args = []
            this.argEdit = false
            for (var arg of row.args) {
                this.form.args.push({ edit: false, custom: arg.custom, name: arg.name, type: arg.type, desc: arg.desc })
            }
            this.dialogStatus = 'create'
            this.dialogFormVisible = true
            this.$nextTick(() => {
                this.$refs['dataForm'].clearValidate()
            })
        },
        handleUpdate(row) {
            this.form = Object.assign({}, row) // copy obj
            this.form.args = []
            this.argEdit = false
            for (var arg of row.args) {
                this.form.args.push({ edit: false, custom: arg.custom, name: arg.name, type: arg.type, desc: arg.desc })
            }
            this.dialogStatus = 'update'
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
                    fargs.push({type: arg.type, custom: arg.custom, name: arg.name, desc: arg.desc })
                }
            }
            form.args = fargs
            return form
        },
        createData() {
            this.$refs['dataForm'].validate((valid) => {
                if (valid) {
                    this.form.id = utils.newGuid()
                    driver.insert("plugins", this.formatForm()).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("AddData", ["PLUGIN", res.data, "id"])
                            this.dialogFormVisible = false
                        })
                    })
                }
            })
        },
        updateData() {
            this.$refs['dataForm'].validate((valid) => {
                if (valid) {
                    driver.update("plugins", this.formatForm()).then(res => {
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
                var pluginids = []
                pluginids.push(row.id)
                driver.remove("plugins", pluginids).then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("DelData", ["PLUGIN", row.id, "id"])
                    })
                })
            }).catch(() => {})
        },
    }
}
</script>
