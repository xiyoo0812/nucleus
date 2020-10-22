<template>
    <el-select v-model="option" :placeholder="holder" :clearable="clear" :filterable="filter" @change="handleSelect">
        <el-option v-for="item in options" :key="getKey(item)" :label="getLabel(item)" :value="getKey(item)"/>
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
        getKey(item) {
            if (typeof(item) === "string") {
                return item
            }
            return item[this.opid]
        },
        getLabel(item) {
            if (typeof(item) === "string") {
                return item
            }
            return item[this.oplabel]
        },
        setOptions(opts){
            this.options = opts
        },
        handleSelect(op_sel) {
            this.$emit("input", op_sel)
            var item = this.options.filter(e => { return e[this.opid] === op_sel })[0]
            this.$emit('change', op_sel, item)
        },
    }
}
</script>
