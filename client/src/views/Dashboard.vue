<template>
    <div>
        <el-row :gutter="10">
            <el-col :span="10">
                <el-card shadow="hover" class="mgb20" style="height:260px;">
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
                <el-card shadow="hover" style="height:620px;">
                    <div slot="header" class="clearfix">
                        <span>操作记录</span>
                        <el-button style="float: right;" size="small" type="primary" @click="refeshLog()">刷新</el-button>
                    </div>
                    <el-table :data="$store.getters.logs" :show-header="false" height="580" style="width: 100%;font-size:13px;">
                        <el-table-column width="120">
                            <template slot-scope="scope"><div>{{scope.row.name}}</div></template>
                        </el-table-column>
                        <el-table-column>
                            <template slot-scope="scope"><div>{{scope.row.log}}</div></template>
                        </el-table-column>
                        <el-table-column width="140">
                            <template slot-scope="scope"><div>{{formatTime(scope.row.time)}}</div></template>
                        </el-table-column>
                    </el-table>
                </el-card>
            </el-col>
            <el-col :span="14">
                <el-row :gutter="10" class="mgb20">
                    <el-col :span="6">
                        <el-card shadow="hover" :body-style="{padding: '0px'}">
                            <div class="grid-content grid-con-1">
                                <i class="el-icon-lx-people grid-con-icon"></i>
                                <div class="grid-cont-right">
                                    <div class="grid-num">{{codeSize}}</div>
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
                                    <div class="grid-num">{{hostSize}}</div>
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
                                    <div class="grid-num">{{pipelineSize}}</div>
                                    <div><router-link to="/pipelines" class="grid-name">流水线</router-link></div>
                                </div>
                            </div>
                        </el-card>
                    </el-col>
                    <el-col :span="6">
                        <el-card shadow="hover" :body-style="{padding: '0px'}">
                            <div class="grid-content grid-con-4">
                                <i class="el-icon-lx-goods grid-con-icon"></i>
                                <div class="grid-cont-right">
                                    <div class="grid-num">{{productSize}}</div>
                                    <div><router-link to="/products" class="grid-name">制品库</router-link></div>
                                </div>
                            </div>
                        </el-card>
                    </el-col>
                </el-row>
                <el-card shadow="hover" style="height:780px;">
                    <div slot="header" class="clearfix">
                        <span>任务记录</span>
                        <el-button style="float: right;" size="small" type="primary" @click="refeshTask()">刷新</el-button>
                    </div>
                    <el-table :data="$store.getters.tasks" :show-header="false" height="520px" style="width: 100%;font-size:13px;">
                        <el-table-column>
                            <template slot-scope="scope"><span >{{ scope.row.creator }}</span></template>
                        </el-table-column>
                        <el-table-column>
                            <template slot-scope="scope"><span >{{ scope.row.name }}</span></template>
                        </el-table-column>
                        <el-table-column>
                            <template slot-scope="scope"><span >{{ formatTime(scope.row.time) }}</span></template>
                        </el-table-column>
                        <el-table-column>
                            <template slot-scope="scope">
                                <el-tag v-loading="scope.row.status=='process'" size="medium" :type="scope.row.status">{{ scope.row.status }}</el-tag>
                            </template>
                        </el-table-column>
                        <el-table-column width="80">
                            <template slot-scope="scope">
                                <el-button size="mini" @click="handleTask(scope.row)">详情</el-button>
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
import * as utils from '../utils/index'
import bus from '../components/common/bus'

export default {
    name: 'dashboard',
    data() {
        return {
        }
    },
    created(){
        bus.$on('project', msg => {
            var store = this.$store.getters
            if (store.proj) {
                bus.$emit('load_logs')
                bus.$emit('load_codes')
                bus.$emit('load_tasks')
                bus.$emit('load_hosts')
                bus.$emit('load_products')
                bus.$emit('load_pipelines')
            }
        })
    },
    computed: {
        codeSize : function() {
            return this.$store.getters.codes.length
        },
        hostSize : function() {
            return this.$store.getters.hosts.length
        },
        pipelineSize : function() {
            return this.$store.getters.pipelines.length
        },
        productSize : function() {
            return this.$store.getters.products.length
        },
    },
    methods: {
        formatTime(val) {
            return utils.formatTime(val)
        },
        handleTask(row) {
            this.$store.dispatch("SetTask", row)
            this.$router.push({ path: "/task" })
        },
        refeshTask(){
            bus.$emit('load_tasks', true)
        },
        refeshLog(){
            bus.$emit('load_logs', true)
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
        color: rgb(100, 213, 114);
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
        margin-bottom: 10px;
    }
</style>
