<template>
<div class="app-container">
    <h3>代码管理</h3>
    <el-alert type="success" :closable="false" title="代码管理负责管理git代码仓库，可以利用其代码打包。需要本机有权限能够拉取到git仓库代码。"/>
    <div class="tool-box">
        <el-button-group>
            <el-button class="filter-item" type="primary" @click="handleCreate">添加</el-button>
            <el-button v-waves :loading="downloadLoading" class="filter-item" @click="handleDownload">导出</el-button>
        </el-button-group>
    </div>
    <el-alert v-if="warning" :title="warning" type="warning"/>
    <el-table v-loading="listLoading" stripe style="width: 100%" :element-loading-text="listLoadingText" :key="tableKey" :data="codes">
        <el-table-column label="名称">
            <template slot-scope="scope">
                <router-link :to="{ path: '/package', query: {id:scope.row.id} }">
                    <el-button type="text"><span >{{ scope.row.name }}</span></el-button>
                </router-link>
            </template>
        </el-table-column>
        <el-table-column label="地址">
            <template slot-scope="scope"><span >{{ scope.row.addr }}</span></template>
        </el-table-column>
        <el-table-column label="类型">
            <template slot-scope="scope"><span >{{ scope.row.type }}</span></template>
        </el-table-column>
        <el-table-column label="打包机">
            <template slot-scope="scope"><span >{{ scope.row.host_ip }}</span></template>
        </el-table-column>
        <el-table-column label="状态">
            <template slot-scope="scope">
                <span v-if="scope.row.code_enable" style="color:green">可用</span>
                <span v-else style="color:red">不可用</span>
            </template>
        </el-table-column>
        <el-table-column label="操作" align="center">
            <template slot-scope="scope">
            <el-button size="mini" @click="handleUpdate(scope.row)">编辑</el-button>
            <el-button size="mini" @click="cloneCode(scope.row)">clone</el-button>
            <el-button size="mini" type="danger" @click="handleDelete(scope.row)">删除</el-button>
            </template>
        </el-table-column>
    </el-table>
    <el-dialog :title="textMap[dialogStatus]" :visible.sync="dialogFormVisible" :close-on-click-modal="false" width="60%">
        <el-form v-loading="formLoadingVisible" ref="dataForm" :rules="rules" :model="form" label-position="left" label-width="100px" style="margin-left:50px;">
            <el-form-item label="名称" prop="name">
                <el-input v-model="form.name" placeholder="hive"/>
            </el-form-item>
            <el-form-item label="地址" prop="addr">
                <el-input v-model="form.addr" placeholder="ssh://git@10.72.17.44:10022/paper_man/server.git"/>
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
            <el-form-item label="打包机" prop="host">
                <HostSelect ref="HostSelect" :form="form" prop="host" pack="true" @change="selectHost"/>
            </el-form-item>
            <el-form-item label="Dockerfile" prop="image">
                <el-select v-model="form.image" placeholder="请选择">
                    <el-option v-for="item in images" :label="item.name" :value="item.id" :key="item.id"/>
                </el-select>
            </el-form-item>
            <el-form-item label="打包脚本" prop="script">
                <ScriptShow ref="ScriptShow" :form="form" @change="handleExample"/>
            </el-form-item>
            <el-form-item>
                <el-button @click="dialogFormVisible = false">取消</el-button>
                <el-button type="primary" @click="dialogStatus==='create'?createData():updateData()">确认</el-button>
            </el-form-item>
        </el-form>
    </el-dialog>
    <el-dialog :visible.sync="jobVisible" title="Clone输出" width="60%">
        <JobShow ref="JobShow" :steps="build_steps" @change="handleProgress"/>
    </el-dialog>
</div>
</template>

<script>
import JobShow from '@/components/widget/JobShow'
import ScriptShow from '@/components/widget/ScriptShow'
import HostSelect from '@/components/widget/HostSelect'
import { imageAll } from '../../api/image'
import { codeAll, codeNew, codeDelete, codeUpdate, codeClone } from '../../api/code'
export default {
    name: 'Code',
    components: {
        JobShow,
        ScriptShow,
        HostSelect
    },
    data() {
        var self = this
        return {
            tableKey: 0,
            form: {},
            codes: [],
            images: [],
            dialogStatus: '',
            listLoadingText: '',
            jobVisible: false,
            listLoading: false,
            dialogFormVisible: false,
            build_steps:[ "准备",  "克隆", "完成"],
            textMap: { update: '编辑', create: '新建' },
            codeTypes: [{ name: 'git', value: 'git' }, { name: 'svn', value: 'svn' }],
            rules: {
                name: [{ required: true, message: '请填入仓库名字', trigger: 'blur' },],
                addr: [{ required: true, message: '请填入仓库git/svn地址', trigger: 'blur' },],
                type :[{ required: true, message: '请选择代码类型', trigger: 'blur' },],
                host :[{ required: true, message: '请选择打包机', trigger: 'blur' },],
                image :[{ required: true, message: '请选择打包机', trigger: 'blur' },]
            },
            warning: '',
            downloadLoading: false,
            formLoadingVisible: false,
        }
    },
    mounted() {
        this.resetForm()
        this.getImages()
        this.getCodes()
    },
    methods: {
        getImages() {
            imageAll().then(res => {
                if (res.code !== 0) {
                    this.showFailed(res.msg)
                    return
                }
                this.images = res.data.images.reverse()
            })
        },
        getCodes() {
            codeAll().then(res => {
                if (res.code !== 0) {
                    this.showFailed(res.msg)
                    return
                }
                this.codes = res.data.codes.reverse()
            })
        },
        resetForm() {
            this.form = {
                id: '',
                name: '',
                addr: '',
                type: '',
                script: '',
                host: '',
                host_ip: '',
                image: '',
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
                if (!valid) {
                    eturn
                }
                this.openListLoading('正在创建代码库...')
                codeNew(this.form).then(res => {
                    this.listLoading = false
                    if (res.code !== 0) {
                        this.showFailed(res.msg)
                        return
                    }
                    var code = res.data.code
                    this.showSuccess('创建代码库成功')
                    this.cloneCode(code)
                    this.dialogFormVisible = false
                })
            })
        },
        selectHost(id, host) {
            this.form.host_ip = host.ip
        },
        cloneCode(code) {
            if(code.is_remote)
            {
                this.openListLoading('正在clone仓库中，请稍后...')
                codeClone({ id: code.id }).then((res) => {
                    if (res.code !== 0) {
                        this.showFailed(res.msg)
                        return
                    }
                    this.showJobLog(res.data.job)
                }).catch(() => {})
            }
        },
        showJobLog(job){
            this.jobVisible = true
            this.$nextTick(() => {
                this.$refs.JobShow.showJobLog(job)
            })
        },
        handleProgress(complete) {
            if (complete) {
                this.getCodes()
            } else {
                this.jobVisible = true
            }
        },
        handleUpdate(row) {
            this.form = Object.assign({}, row) // copy obj
            this.dialogStatus = 'update'
            this.dialogFormVisible = true
            this.$nextTick(() => {
                this.$refs['dataForm'].clearValidate()
            })
        },
        openFormLoading() {
            this.formLoadingVisible = true
        },
        closeFormLoading() {
            this.formLoadingVisible = false
        },
        updateData() {
            this.$refs['dataForm'].validate((valid) => {
                if (!valid) {
                    return
                }
                this.openFormLoading('正在更新中...')
                const tempData = Object.assign({}, this.form)
                codeUpdate(tempData).then(res => {
                    this.closeFormLoading()
                    if (res.code !== 0) {
                        this.showFailed(res.msg)
                        return
                    }
                    this.getCodes()
                    this.dialogFormVisible = false
                    this.showSuccess('更新成功')
                })
            })
        },
        handleDelete(row) {
            this.$confirm('确定要删除此代码仓库，是否继续?', '提示', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'warning'
            }).then(() => {
                this.form = Object.assign({}, row)
                codeDelete(this.form).then(res => {
                    if (res.code !== 0) {
                        this.showFailed(res.msg)
                        return
                    }
                    this.getCodes()
                    this.showSuccess()
                })
            }).catch(() => {})
        },
        openListLoading(text) {
            this.listLoadingText = text
            this.listLoading = true
        },
        handleExample() {
            if (this.form.image == ""){
                this.showFailed("请先选择Dockerfile")
                return
            }
            //示例代码写到script_show组件
            this.$nextTick(() => {
                var image = this.images.filter(e => { return e.id == this.form.image})[0]
                if(image.name == "hive") {
                    this.$refs.ScriptShow.showExample(1)
                } else if(image.name == "ds") {
                    this.$refs.ScriptShow.showExample(2)
                } else {
                    this.$refs.ScriptShow.showExample(3)
                }
            })
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
