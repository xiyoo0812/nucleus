<template>
    <div>
        <el-row :gutter="20">
            <el-col :span="10">
                <el-card shadow="hover" class="mgb20" style="height:300px;">
                    <div class="user-info">
                        <img :src="this.$store.getters.avatar" class="user-avator" alt="">
                        <div class="user-info-cont">
                            <div class="user-info-name">{{this.$store.getters.name}}</div>
                            <div class="user-info-name">{{this.$store.getters.en_name}}</div>
                        </div>
                    </div>
                    <div class="user-info-list">工号：{{this.$store.getters.empCode}} </div>
                    <div class="user-info-list">邮箱：{{this.$store.getters.email}} </div>
                    <div class="user-info-list">部门：{{this.$store.getters.dept}} </div>
                </el-card>
                <el-card shadow="hover" style="height:480px;">
                    <div slot="header" class="clearfix">
                        <span>我的项目</span>
                    </div>
                    <el-table :data="this.$store.getters.meprojs" :show-header="false" height="380" style="width: 100%;font-size:14px;">
                        <el-table-column> 
                            <template slot-scope="scope">
                                <div class="proj-title">{{scope.row.name}}</div>
                                <div class="proj-item">{{scope.row.desc}}</div>
                            </template>
                        </el-table-column>
                        <el-table-column width="80">
                            <template slot-scope="scope">
                                <el-button size="small" type="primary" @click="handleView(scope.row)">查看</el-button>
                            </template>
                        </el-table-column>
                    </el-table>
                </el-card>
            </el-col>
            <el-col :span="14">
                <el-card shadow="hover" style="height:800px;">
                    <div slot="header" class="clearfix">
                        <span>所有项目</span>
                    </div>
                    <el-table :data="this.$store.getters.projs" :show-header="false" height="700" style="width: 100%;font-size:14px;">
                        <el-table-column>
                            <template slot-scope="scope">
                                <div class="proj-title">{{scope.row.name}}</div>
                                <div class="proj-item">{{scope.row.desc}}</div>
                            </template>
                        </el-table-column>
                        <el-table-column width="80">
                            <template slot-scope="scope">
                                <el-button size="small" type="primary" @click="handleJoin(scope.row)">加入</el-button>
                            </template>
                        </el-table-column>
                    </el-table>
                </el-card>
            </el-col>
        </el-row>
    </div>
</template>

<script>
import * as driver from '../api/driver'
import * as utils from '../utils/index';
export default {
    name: 'dashboard',
    data() {
        return {
        }
    },
    created(){
        this.loadProj();
    },
    methods: {
        loadProj() {
            driver.load("project").then(res => {
                utils.showNetRes(this, res, () => {
                    this.$store.dispatch("InitResource", ["PROJ", res.data])
                })
            });
        },
        handleView(row){
        },
        handleJoin(row){
        },
        handleSelect(row){
        }
    }
}
</script>

<style scoped>
    .el-row {
        margin-bottom: 20px;
    }

    .user-info {
        display: flex;
        align-items: center;
        padding-bottom: 20px;
        border-bottom: 2px solid #ccc;
        margin-bottom: 20px;
    }

    .user-avator {
        width: 100px;
        height: 100px;
        border-radius: 50%;
    }

    .user-info-cont {
        padding-left: 50px;
        flex: 1;
        font-size: 14px;
        color: #999;
    }

    .user-info-cont div:first-child {
        font-size: 30px;
        color: #222;
    }

    .user-info-list {
        font-size: 14px;
        color: #999;
        line-height: 30px;
    }

    .user-info-list span {
        margin-left: 70px;
    }

    .mgb20 {
        margin-bottom: 20px;
    }

    .proj-title {
        font-size: 20px;
    }

    .proj-item {
        font-size: 14px;
    }

</style>
