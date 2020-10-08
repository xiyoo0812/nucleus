<template>
    <div>
        <el-row :gutter="20">
            <el-col :span="8">
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
                    <el-table :data="this.$store.getters.owns" :show-header="false" height="380" style="width: 100%;font-size:14px;">
                        <el-table-column>
                            <template slot-scope="scope">
                                <div class="proj-item">{{scope.row.name}}</div>
                            </template>
                        </el-table-column>
                        <el-table-column>
                            <template slot-scope="scope">
                                <div class="proj-item">{{scope.row.desc}}</div>
                            </template>
                        </el-table-column>
                    </el-table>
                </el-card>
            </el-col>
            <el-col :span="16">
                <el-row :gutter="20" class="mgb20">
                    <el-col :span="6">
                        <el-card shadow="hover" :body-style="{padding: '0px'}">
                            <div class="grid-content grid-con-1">
                                <i class="el-icon-lx-people grid-con-icon"></i>
                                <div class="grid-cont-right">
                                    <div class="grid-num">3</div>
                                    <div><router-link to="/codes" class="grid-name">代码库</router-link></div>
                                </div>
                            </div>
                        </el-card>
                    </el-col>
                    <el-col :span="6">
                        <el-card shadow="hover" :body-style="{padding: '0px'}">
                            <div class="grid-content grid-con-2">
                                <i class="el-icon-lx-notice grid-con-icon"></i>
                                <div class="grid-cont-right">
                                    <div class="grid-num">8</div>
                                    <div><router-link to="/hosts" class="grid-name">主机</router-link></div>
                                </div>
                            </div>
                        </el-card>
                    </el-col>
                    <el-col :span="6">
                        <el-card shadow="hover" :body-style="{padding: '0px'}">
                            <div class="grid-content grid-con-3">
                                <i class="el-icon-lx-goods grid-con-icon"></i>
                                <div class="grid-cont-right">
                                    <div class="grid-num">21</div>
                                    <div><router-link to="/hosts" class="grid-name">流水线</router-link></div>
                                </div>
                            </div>
                        </el-card>
                    </el-col>
                    <el-col :span="6">
                        <el-card shadow="hover" :body-style="{padding: '0px'}">
                            <div class="grid-content grid-con-4">
                                <i class="el-icon-lx-goods grid-con-icon"></i>
                                <div class="grid-cont-right">
                                    <div class="grid-num">50</div>
                                    <div><router-link to="/hosts" class="grid-name">制品库</router-link></div>
                                </div>
                            </div>
                        </el-card>
                    </el-col>
                </el-row>
                <el-card shadow="hover" style="height:680px;">
                    <div slot="header" class="clearfix">
                        <span>操作记录</span>
                        <el-button style="float: right;" size="small" type="primary" @click="handleRefesh()">刷新</el-button>
                    </div>
                    <el-table :data="this.$store.getters.logs" :show-header="false" height="580" style="width: 100%;font-size:14px;">
                        <el-table-column width="120">
                            <template slot-scope="scope"><div class="proj-item">{{scope.row.name}}</div></template>
                        </el-table-column>
                        <el-table-column>
                            <template slot-scope="scope"><div class="proj-item">{{scope.row.log}}</div></template>
                        </el-table-column>
                        <el-table-column width="85">
                            <template slot-scope="scope"><div class="proj-item">{{formatTime(scope.row.time)}}</div></template>
                        </el-table-column>
                    </el-table>
                </el-card>
            </el-col>
        </el-row>
    </div>
</template>

<script>

import bus from '../components/common/bus'
import * as driver from '../api/driver'
import * as utils from '../utils/index'
import { formatTime } from '../utils/index'
export default {
    name: 'dashboard',
    data() {
        return {
        }
    },
    created(){
        this.loadOwns()
        bus.$on('project', msg => {
            var store = this.$store.getters
            if (store.proj) {
                this.loadLogs()
            }
        })
    },
    methods: {
        formatTime,
        loadOwns() {
            driver.load("owns").then(res => {
                utils.showNetRes(this, res, () => {
                    this.$store.dispatch("InitData", ["OWNS", res.data])
                    if (res.proj) {
                        this.$store.dispatch("SetProj", res.proj)
                        bus.$emit('project');
                    }
                    bus.$emit('owns');
                })
            });
        },
        loadLogs() {
            driver.load("logs").then(res => {
                utils.showNetRes(this, res, () => {
                    console.log("loadLogs", res.data)
                    this.$store.dispatch("InitData", ["LOG", res.data])
                })
            });
        },
        handleRefesh(){
            this.loadLogs()
        },
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

    .grid-content {
        display: flex;
        align-items: center;
        height: 100px;
    }

    .grid-cont-right {
        flex: 1;
        text-align: center;
        font-size: 14px;
        color: #999;
    }

    .grid-num {
        font-size: 30px;
        font-weight: bold;
    }

    .grid-name {
        font-size: 16px;
        font-weight: bold;
        color: #222;
    }

    .grid-con-icon {
        font-size: 50px;
        width: 100px;
        height: 100px;
        text-align: center;
        line-height: 100px;
        color: #fff;
    }

    .grid-con-1 .grid-con-icon {
        background: rgb(45, 140, 240);
    }

    .grid-con-1 .grid-num {
        color: rgb(45, 140, 240);
    }

    .grid-con-2 .grid-con-icon {
        background: rgb(100, 213, 114);
    }

    .grid-con-2 .grid-num {
        color: rgb(45, 140, 240);
    }

    .grid-con-3 .grid-con-icon {
        background: rgb(242, 94, 67);
    }

    .grid-con-3 .grid-num {
        color: rgb(242, 94, 67);
    }

    .grid-con-4 .grid-con-icon {
        background: rgb(12, 234, 241);
    }

    .grid-con-4 .grid-num {
        color: rgb(12, 234, 241);
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
