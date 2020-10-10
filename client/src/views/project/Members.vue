<template>
<div class="app-container">
    <imp-panel>
        <div slot="body">
            <el-table :data="this.$store.getters.members" border style="width: 100%" :v-loading="memberLoading">
                <el-table-column prop="id" width="50"></el-table-column>
                <el-table-column label="头像" width="96">
                    <template slot-scope="scope"><img :src='scope.row.avatar'></template>
                </el-table-column>
                <el-table-column prop="empCode" label="ID" width="100"> </el-table-column>
                <el-table-column prop="en_name" label="用户名"> </el-table-column>
                <el-table-column prop="name" label="名称" width="100"> </el-table-column>
                <el-table-column prop="email" label="邮箱"> </el-table-column>
                <el-table-column prop="dept" label="部门" width="350"> </el-table-column>
                <el-table-column label="操作" width="250">
                <template slot-scope="scope">
                    <el-button size="small" type="info" icon="setting" @click="handleConfig(scope.row)">配置权限</el-button>
                    <el-button size="small" type="danger" @click="handleDelete(scope.row)">踢出项目</el-button>
                </template>
                </el-table-column>
            </el-table>
        </div>
    </imp-panel>
    <el-dialog title="配置权限" :visible.sync="dialogConfigVisible" :close-on-click-modal="false" width="60%">
        <imp-panel>
        </imp-panel>
        <span slot="footer" class="dialog-footer">
            <el-button @click="dialogConfigVisible = false">取 消</el-button>
            <el-button type="primary" @click="handleConfigSure">确 定</el-button>
        </span>
    </el-dialog>
</div>
</template>

<script>
import bus from '../../components/common/bus'
import panel from "../../components/Panel.vue"
import * as utils from '../../utils/index'
import * as driver from '../../api/driver'

export default {
    components: {
        'imp-panel': panel
    },
    data(){
        return {
            currentRow: {},
            memberLoading: false,
            dialogConfigVisible: false,
        }
    },
    methods: {
        handleConfig(row) {
            /*
            this.currentRow = row;
            this.dialogConfigVisible = true;
            if (this.roleList.length <= 0) {
                role_api.getRoles().then(res => {
                    if (res.code != 0) {
                        utils.showFailed(this, res.msg)
                        return
                    }
                    this.roleList = res.data
                })
            }
            this.$nextTick(() => {
                this.$refs.role.setCheckedKeys(row.roles);
            });*/
        },
        handleConfigSure(){
            /*
            var member_roles = {
                en_name : this.currentRow.en_name,
                roles : this.$refs.role.getCheckedKeys(),
            }
            driver.update(member_roles).then(res => {
                if (res.code != 0) {
                    utils.showFailed(this, res.msg)
                    return
                }
                utils.showSuccess(this, "配置角色成功")
                this.dialogConfigVisible = false;
                for (let member of this.memberList) {
                    if (member.en_name == member_roles.en_name) {
                        member = res.data
                        break
                    }
                }
            })*/
        },
        handleDelete(row){
            if (this.$store.getters.name == row.name) {
                utils.showFailed(this, "不能踢出自己")
                return
            }
            var memberlist = []
            memberlist.push(row.en_name)
            driver.remove("members", memberlist).then(res => {
                utils.showNetRes(this, res, () => {
                    this.$store.dispatch("DelData", ["MEMBER", row.en_name, "en_name"])
                })
            });
        },
        loadMembers() {
            driver.load("members").then(res => {
                utils.showNetRes(this, res, () => {
                    this.$store.dispatch("InitData", ["MEMBER", res.data])
                })
            });
        }
    },
    created(){
        var store = this.$store.getters
        if (store.proj) {
            this.loadMembers()
        }
        bus.$on('project', msg => {
            if (store.proj) {
                this.loadMembers()
            }
        })
    }
}
</script>
<style>
.el-pagination {
    float: right;
    margin-top: 15px;
}
</style>
