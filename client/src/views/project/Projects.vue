<template>
<div class="app-container">
    <imp-panel>
        <h3>项目列表</h3>
        <h3 class="box-title" slot="header" style="width: 100%;">
            <el-button type="primary" icon="plus" @click="handleNew()">创建项目</el-button>
        </h3>
        <div slot="body">
            <el-table :data="this.$store.getters.projs" border style="width: 100%" :v-loading="listLoading">
                <el-table-column prop="name" label="项目名称" width="120"></el-table-column>
                <el-table-column prop="nick" label="项目编号" width="120"></el-table-column>
                <el-table-column prop="creator" label="项目创建者" width="120"></el-table-column>
                <el-table-column prop="desc" label="项目简介"></el-table-column>
                <el-table-column label="操作" width="300">
                    <template slot-scope="scope">
                        <el-button size="small" type="primary" @click="handleJoin(scope.row)">申请加入</el-button>
                        <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除项目</el-button>
                    </template>
                </el-table-column>
            </el-table>
        </div>
    </imp-panel>
    <el-dialog title="创建项目" :visible.sync="dialogVisible" :close-on-click-modal="false" width="60%">
        <el-card class="box-card">
            <el-form :model="form" :rules="rules" ref="form">
                <el-form-item prop="name" label="项目名称" label-width="100px">
                    <el-input v-model="form.name" auto-complete="off"></el-input>
                </el-form-item>
                <el-form-item prop="nick" label="项目编号" label-width="100px">
                    <el-input v-model="form.nick" auto-complete="off"></el-input>
                </el-form-item>
                <el-form-item prop="desc" label="项目简介" label-width="100px">
                    <el-input v-model="form.desc" auto-complete="off"></el-input>
                </el-form-item>
                <el-form-item label="" label-width="100px">
                    <el-button type="primary" @click="handleCreate()">确认</el-button>
                    <el-button @click="dialogVisible = false">取消</el-button>
                </el-form-item>
            </el-form>
        </el-card>
    </el-dialog>
</div>
</template>
<script>
import panel from "../../components/Panel.vue"
import * as utils from '../../utils/index'
import * as driver from '../../api/driver'
export default {
    components: {
        'imp-panel': panel,
    },
    data(){
        return {
            dialogVisible:false,
            form: {
                nick: '',
                name: '',
                desc: '',
            },
            rules: {
                name: [{ required: true, message: '请输入项目名', trigger: 'blur' }],
                nick: [{ required: true, message: '请输入项目编号', trigger: 'blur' }],
                desc: [{ required: true, message: '请输入项目简介', trigger: 'blur' }],
            },
        }
    },
    methods: {
        handleNew(){
            this.dialogVisible = true;
            this.form = {
                nick: '',
                name: '',
                desc: '',
            };
        },
        handleDelete(row){
            utils.confirm(this, "确定删除?", () => {
                var projlist = []
                projlist.push(row.id)
                driver.remove("projects", projlist).then(res => {
                    utils.showNetRes(this, res, () => {
                        utils.showSuccess(this, "删除成功");
                        this.$store.dispatch("DelData", ["PROJ", row.id, "id"])
                    })
                })
            })
        },
        handleUpdate() {
            this.dialogVisible = false
            this.$refs.form.validate(valid => {
                driver.update("projects", this.form).then(res => {
                    utils.showNetRes(this, res, () => {
                        utils.showSuccess(this, "修改成功");
                        this.$store.dispatch("UpdateData", ["PROJ", this.form, "id"])
                    })
                })
            })
        },
        handleCreate() {
            this.dialogVisible = false
            this.$refs.form.validate(valid => {
                this.form.id = utils.newGuid()
                driver.insert("projects", this.form).then(res => {
                    utils.showNetRes(this, res, () => {
                        utils.showSuccess(this, "创建成功");
                        this.$store.dispatch("AddData", ["PROJ", res.data])
                        this.$store.dispatch("AddData", ["OWNS", res.data])
                        if (this.$store.getters.proj == null) {
                            this.$store.dispatch("SetProj", res.data)
                        }
                    })
                })
            })
        },
        chooseProj(proj) {
            console.log("chooseProj", proj)
            driver.update("owns", proj).then(res => {
                utils.showNetRes(this, res, () => {
                    this.loadLogs();
                })
            })
        },
        loadProj() {
            driver.load("projects").then(res => {
                utils.showNetRes(this, res, () => {
                    this.$store.dispatch("InitData", ["PROJ", res.data])
                })
            });
        },
    },
    created(){
        if (this.$store.getters.projs.length == 0) {
            this.loadProj();
        }
    }
}
</script>
