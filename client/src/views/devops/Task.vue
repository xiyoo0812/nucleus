<template>
<div class="app-container">
    <el-card>
        <el-alert :closable="false" type="success" title="任务执行日志显示"/>
        <div slot="header" class="clearfix">
            <el-steps :active="step">
                <el-step v-for="item in $store.getters.task.steps" :status="item.status" :title="item.name"></el-step>
            </el-steps>
        </div>
        <CodeEditor :code="$store.getters.task.output" readOnly="true" scrollAble="true" height="600px"/>
    </el-card>
</div>
</template>

<script>
import * as utils from '../../utils/index'
import * as driver from '../../api/driver'
import bus from '../../components/common/bus'
import CodeEditor from '../../components/widget/CodeEditor.vue'

export default {
    name: 'Task',
    components:{
        CodeEditor
    },
    created() {
        this.loadProcess(this.$store.getters.task)
    },
    beforeDestroy() {
        clearTimeout(this.interval)
    },
    data() {
        return {
            step: 0,
            interval: null,
        }
    },
    methods: {
        loadProcess(task){
            if (task) {
                if(task.status == "process") {
                    this.interval = setTimeout(() => {
                        this.loadTask(task.id)
                    }, 1000)
                } else {
                    bus.$emit('product')
                }
            }
        },
        loadTask(taskId){
            driver.find("tasks", taskId).then(res => {
                utils.showNetRes(this, res, () => {
                    var task = res.data[0]
                    this.$store.dispatch("SetTask", task)
                    for (let idx in task.steps) {
                        if(task.steps[idx].status != "wait") {
                            this.step = idx
                        }
                    }
                    this.loadProcess(task)
                })
            })
        }
    }
}
</script>
