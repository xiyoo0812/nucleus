<template>
<div class="app-container">
    <el-card>
        <el-alert :closable="false" type="success" title="负责展示当前项目的所有资源。"/>
        <el-button-group style="margin-top:10px; margin-bottom:10px;">
            <el-button icon="plus" type="primary" style="margin-right:10px;" @click="handleNew">新增资源</el-button>
            <el-button type="danger" icon="delete" style="margin-right:10px;" @click="batchDelete">批量删除</el-button>
        </el-button-group>
        <el-table :data="resourceList" border style="width: 100%" :v-loading="listLoading" @selection-change="handleResourceSelect">
            <el-table-column prop="id" type="selection" width="50"></el-table-column>
            <el-table-column prop="path" label="路径"></el-table-column>
            <el-table-column prop="name" label="名称"></el-table-column>
            <el-table-column prop="remarks" label="备注"></el-table-column>
            <el-table-column label="METHOD">
                <template slot-scope="scope">
                    <div slot="reference" class="name-wrapper">{{ scope.row.method.join(",") }}</div>
                </template>
            </el-table-column>
            <el-table-column label="项目">
                <template slot-scope="scope">
                    <div slot="reference" class="name-wrapper">{{ formatProject(scope.row.project) }}</div>
                </template>
            </el-table-column>
            <el-table-column label="操作" width="300">
                <template slot-scope="scope">
                    <el-button size="small" type="info" icon="setting" @click="handleModify(scope.row)">编辑</el-button>
                    <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
                </template>
            </el-table-column>
        </el-table>
        <el-pagination @size-change="handleSizeChange" @current-change="handlePageChange"
            layout="total, sizes, prev, pager, next, jumper"
            :page-size="pagination.pageSize"
            :current-page="pagination.pageNo"
            :page-sizes="[5, 10, 20]"
            :total="pagination.total">
        </el-pagination>
    </el-card>
    <el-dialog :title="textMap[dialogStatus]" :visible.sync="dialogVisible" :close-on-click-modal="false" width="60%">
        <el-card class="box-card">
            <el-form :model="form" :rules="rules" ref="form">
                <el-form-item prop="name" label="名称" label-width="100px">
                    <el-input v-model="form.name" auto-complete="off"></el-input>
                </el-form-item>
                <el-form-item prop="path" label="路径" label-width="100px">
                    <el-input v-model="form.path" auto-complete="off"></el-input>
                </el-form-item>
                <el-form-item prop="project" label="项目" label-width="100px">
                    <el-select v-model="form.project" placeholder="请选择">
                        <el-option v-for="item in projectList" :key="item.id" :label="item.name" :value="item.id"></el-option>
                    </el-select>
                </el-form-item>
                <el-form-item prop="method" label="METHOD" label-width="100px">
                    <el-select v-model="form.method" multiple placeholder="请选择">
                        <el-option v-for="item in methodList" :key="item" :label="item" :value="item"></el-option>
                    </el-select>
                </el-form-item>
                <el-form-item prop="remarks" label="备注" label-width="100px">
                    <el-input v-model="form.remarks" auto-complete="off"></el-input>
                </el-form-item>
                <el-form-item label="" label-width="100px">
                    <el-button type="primary" @click="dialogStatus==='create' ? handleCreate() : handleUpdate()">确认</el-button>
                    <el-button @click="dialogVisible = false">取消</el-button>
                </el-form-item>
            </el-form>
        </el-card>
    </el-dialog>
</div>
</template>
<script>

import * as utils from '../../utils/index'
import * as driver from '../../api/driver'
import bus from '../../components/common/bus'

export default {
    data(){
        return {
            resourceList: [],
            resourceSelect: [],
            dialogVisible:false,
            dialogStatus: "create",
            methodList:["GET", "PUT", "POST", "DELETE"],
            textMap: { update: '编辑', create: '新建' },
            projectList:[ {name: "管理系统", id: 0} ],
            form: {
                id: null,
                path: '',
                name: '',
                remarks: '',
                method: [],
                project: 0,
            },
            pagination: {
                total: 0,
                pageNo: 1,
                pageSize: 10,
                parentId: 0
            },
            rules: {
                name: [{ required: true, message: '请输入资源名', trigger: 'blur' }],
                path: [{ required: true, message: '请输入资源路径', trigger: 'blur' }],
            },
        }
    },
    methods: {
        formatProject(project){
            for (let item of this.projectList) {
                if (item.id == project) {
                    return item.name
                }
            }
            return project
        },
        handleNew(){
            this.dialogStatus = "create";
            this.dialogVisible = true;
            this.form = {
                id: null,
                path: '',
                name: '',
                method: [],
                remarks: '',
                project: 0,
            };
        },
        handleResourceSelect(val){
            this.resourceSelect = []
            for (let item of val) {
                this.resourceSelect.push(item.id)
            }
        },
        handleDelete(row){
            utils.confirm(this, "确定删除?", () => {
                var resources = [row.id];
                driver.resourceDelete(resources).then(res => {
                    if (res.code != 0){
                        utils.showFailed(this, res.msg);
                        return;
                    }
                    utils.showSuccess(this, "删除资源成功");
                    utils.array_remove(this.resourceList, row.id, "id")
                })
            });
        },
        batchDelete(){
            if (this.resourceSelect.length <= 0) {
                utils.showFailed(this, '请选择要删除的资源')
                return;
            }
            utils.confirm(this, "确定删除?", () => {
                driver.resourceDelete(this.resourceSelect).then(res => {
                    if (res.code != 0){
                        utils.showFailed(this, res.msg);
                        return;
                    }
                    for (let id of this.resourceSelect) {
                        utils.array_remove(this.resourceList, id, "id")
                    }
                    utils.showSuccess(this, "删除成功");
                });
            });
        },
        handleCreate() {
            this.dialogVisible = false
            this.$refs.form.validate(valid => {
                if (this.form.method.length <= 0) {
                    utils.showFailed(this, "必须配置一个方法");
                    return;
                }
                this.form.id = utils.newGuid()
                driver.resourceAdd(this.form).then(res => {
                    if (res.code != 0){
                        utils.showFailed(this, res.msg);
                        return;
                    }
                    utils.showSuccess(this, "创建资源成功");
                    this.resourceList.push(res.data)
                })
            })
        },
        handleUpdate() {
            this.dialogVisible = false
            this.$refs.form.validate(valid => {
                if (this.form.method.length <= 0) {
                    utils.showFailed(this, "必须配置一个方法");
                    return;
                }
                driver.resourceUpdate(this.form).then(res => {
                    if (res.code != 0){
                        utils.showFailed(this, res.msg);
                        return;
                    }
                    utils.showSuccess(this, "修改资源成功");
                    utils.array_update(this.resourceList, this.form, "id")
                })
            })
        },
        handleModify(row){
            this.form = row
            this.dialogVisible = true;
            this.dialogStatus = "update";
        },
        handleSizeChange(val) {
            this.pagination.pageSize = val;
            this.loadRole();
        },
        handlePageChange(val) {
            this.pagination.pageNo = val;
            this.loadRole();
        },
        loadResource(){
            driver.getResources().then(res=>{
                if (res.code == 0) {
                    this.resourceList = res.data;
                }
            })
        }
    },
    created(){
        this.loadResource();
    }
}
</script>

