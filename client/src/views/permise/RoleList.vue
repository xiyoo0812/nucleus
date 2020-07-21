<template>
<div class="app-container">
    <imp-panel>
        <h3 class="box-title" slot="header" style="width: 100%;">
            <el-button type="primary" icon="plus" @click="handleNew()">新增角色</el-button>
            <el-button type="danger" icon="delete" @click="batchDelete">批量删除</el-button>
        </h3>
        <div slot="body">
            <el-table :data="roleList" border style="width: 100%" :v-loading="listLoading" @selection-change="handleRoleSelect">
                <el-table-column prop="id" type="selection" width="50"></el-table-column>
                <el-table-column prop="en_name" label="英文名"></el-table-column>
                <el-table-column prop="name" label="名称"></el-table-column>
                <el-table-column label="项目">
                    <template slot-scope="scope">
                        <div slot="reference" class="name-wrapper">{{ formatProject(scope.row.project) }}</div>
                    </template>
                </el-table-column>
                <el-table-column label="操作" width="300">
                    <template slot-scope="scope">
                        <el-button size="small" type="info" icon="setting" @click="handleModify(scope.row)">修改</el-button>
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
        </div>
    </imp-panel>
    <el-dialog :title="textMap[dialogStatus]" :visible.sync="dialogVisible" :close-on-click-modal="false" width="60%">
        <el-card class="box-card">
            <el-form :model="form" :rules="rules" ref="form">
                <el-form-item prop="name" label="名称" label-width="100px">
                    <el-input v-model="form.name" auto-complete="off"></el-input>
                </el-form-item>
                <el-form-item prop="en_name" label="英文" label-width="100px">
                    <el-input v-model="form.en_name" auto-complete="off"></el-input>
                </el-form-item>
                <el-form-item prop="project" label="项目" label-width="100px">
                    <el-select v-model="form.project" placeholder="请选择">
                        <el-option v-for="item in projectList" :key="item.id" :label="item.name" :value="item.id"></el-option>
                    </el-select>
                </el-form-item>
                <el-form-item label="配置资源" label-width="100px">
                    <imp-panel>
                        <el-scrollbar tag="div" class='is-empty' wrap-class="el-select-dropdown__wrap" view-class="el-select-dropdown__list">
                            <el-tree ref="resource" :v-loading="resourceLoading" show-checkbox check-on-click-node node-key="id"
                                :data="resourceList" :props="defaultProps">
                            </el-tree>
                        </el-scrollbar>
                    </imp-panel>
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
import panel from "../../components/Panel.vue"
import * as utils from '../../utils/index';
import * as role_api from '../../api/role';
import * as resource_api from '../../api/resource';
import { getToken } from '../../utils/auth';
export default {
    components: {
        'imp-panel': panel,
    },
    data(){
        return {
            defaultProps: {
                children: 'children',
                label: 'name',
                id: "id",
            },
            roleList: [],
            roleSelect: [],
            resourceList: [],
            dialogVisible:false,
            dialogStatus: "create",
            textMap: { update: '编辑', create: '新建' },
            projectList:[ {name: "管理系统", id: 0} ],
            form: {
                id: null,
                name: '',
                en_name: '',
                project: 0,
                resources: [],
            },
            pagination: {
                total: 0,
                pageNo: 1,
                pageSize: 10,
                parentId: 0
            },
            rules: {
                name: [{ required: true, message: '请输入角色名', trigger: 'blur' }],
                en_name: [{ required: true, message: '请输入英文名', trigger: 'blur' }],
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
        handleRoleSelect(val){
            this.roleSelect = []
            for (let item of val) {
                this.roleSelect.push(item.id)
            }
        },
        handleNew(){
            this.dialogStatus = "create";
            this.dialogVisible = true;
            this.form = {
                id: null,
                name: '',
                en_name: '',
                project: 0,
                resources: [],
            };
        },
        batchDelete(){
            if (this.roleSelect.length <= 0) {
                utils.showFailed(this, '请选择要删除的角色')
                return;
            }
            utils.confirm(this, "确定删除?", () => {
                role_api.roleDelete(this.roleSelect).then(res => {
                    if (res.code != 0){
                        utils.showFailed(this, res.msg);
                        return;
                    }
                    for (let id of this.roleSelect) {
                        utils.array_remove(this.roleList, id, "id")
                    }
                    utils.showSuccess(this, "删除成功");
                });
            });
        },
        handleDelete(row){
            utils.confirm(this, "确定删除?", () => {
                var roles = [row.id];
                role_api.roleDelete(roles).then(res => {
                    if (res.code != 0){
                        utils.showFailed(this, res.msg);
                        return;
                    }
                    utils.showSuccess(this, "删除成功");
                    utils.array_remove(this.roleList, row.id, "id")
                });
            });
        },
        handleUpdate() {
            this.dialogVisible = false
            this.$refs.form.validate(valid => {
                this.form.resources = this.$refs.resource.getCheckedKeys();
                role_api.roleUpdate(this.form).then(res => {
                    if (res.code != 0){
                        utils.showFailed(this, res.msg);
                        return;
                    }
                    utils.showSuccess(this, "修改成功");
                    utils.array_update(this.roleList, this.form, "id")
                })
            })
        },
        handleCreate() {
            this.dialogVisible = false
            this.$refs.form.validate(valid => {
                this.form.id = utils.newGuid()
                this.form.resources = this.$refs.resource.getCheckedKeys(false);
                role_api.roleAdd(this.form).then(res => {
                    if (res.code != 0){
                        utils.showFailed(this, res.msg);
                        return;
                    }
                    utils.showSuccess(this, "创建成功");
                    this.roleList.push(res.data)
                })
            })
        },
        handleModify(row){
            this.form = row
            this.dialogVisible = true;
            this.dialogStatus = "update";
            if (this.resourceList.length == 0){
                this.dialogLoading = true;
                resource_api.getResources().then(res => {
                    this.dialogLoading = false;
                    if (res.code == 0) {
                        this.resourceList = [];
                        for (let item of res.data) {
                            var res_name = item.name + "(" + item.path + ")";
                            var res_node = {id: item.id, name: res_name, children: []}
                            for (let method of item.method) {
                                var method_id = item.id + ":" + method
                                var method_name = item.name + "(" + item.path + ":" + method + ")";
                                res_node.children.push({id: method_id, name: method_name})
                            }
                            this.resourceList.push(res_node);
                        }
                    }
                })
            }
            this.$nextTick(() => {
                this.$refs.resource.setCheckedKeys(row.resources);
            });
        },
        handleSizeChange(val) {
            this.pagination.pageSize = val;
            this.loadRole();
        },
        handlePageChange(val) {
            this.pagination.pageNo = val;
            this.loadRole();
        },
        loadRole() {
            role_api.getRoles().then(res => {
                if (res.code == 0) {
                    this.roleList = res.data;
                }
            })
        },
    },
    created(){
        this.loadRole();
    }
}
</script>
