<template>
    <el-select v-model="option" :placeholder="holder" :clearable="clear" :filterable="filter" @change="handleSelect">
        <el-option v-for="item in options" :key="item[opid]" :label="item[oplabel]" :value="item[opid]"/>
    </el-select>
</template>

<script>
export default {
    name: 'Selecter',
    props: {
        option: null,
        options: {
            type: Array,
            default: () => {}
        },
        opid: {
            type: String,
            default: "id"
        },
        oplabel: {
            type: String,
            default: "name"
        },
        holder: {
            type: String,
            default: "请选择"
        },
        clear: {
            type: Boolean,
            default: false
        },
        filter: {
            type: Boolean,
            default: true
        },
    },
    methods: {
        handleSelect(op_sel) {
            this.$emit("input", op_sel)
            var item = this.options.filter(e => { return e[this.opid] === op_sel })[0]
            this.$emit('change', op_sel, item)
        },
    }
}
</script>
