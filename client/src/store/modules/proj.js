//store/modules/resource.ts
import * as utils from '../../utils/index';

const project = {
    state:  {
        members: [],
        codes: [],
        projs: [],
        logs: [],
    },
    mutations: {
        INIT_LOG: (state, logs) => {
            state.logs = logs
        },
        INIT_MEMBER: (state, members) => {
            state.members = members
        },
        ADD_MEMBER: (state, user) => {
            state.members.push(user)
        },
        DEL_MEMBER: (state, args) => {
            utils.array_remove(state.members, args[0], args[1])
        },
        UPDATE_MEMBER: (state, args) => {
            utils.array_update(state.members, args[0], args[1])
        },
        INIT_PROJ: (state, projs) => {
            state.projs = projs
        },
        ADD_PROJ: (state, proj) => {
            state.projs.push(proj)
        },
        DEL_PROJ: (state, args) => {
            utils.array_remove(state.projs, args[0], args[1])
        },
        UPDATE_PROJ: (state, args) => {
            utils.array_update(state.projs, args[0], args[1])
        },
        INIT_CODE: (state, codes) => {
            state.codes = codes
        },
        ADD_CODE: (state, code) => {
            state.codes.push(code)
        },
        DEL_CODE: (state, args) => {
            utils.array_remove(state.codes, args[0], args[1])
        },
        UPDATE_CODE: (state, args) => {
            utils.array_update(state.codes, args[0], args[1])
        },
    },
    actions: {
        InitData(context, params) {
            context.commit("INIT_" + params[0], params[1])
        },
        AddData(context, params) {
            context.commit("ADD_" + params[0], params[1])
        },
        DelData(context, params) {
            context.commit("DEL_" + params[0], [params[1], params[2]])
        },
        UpdateData(context, params) {
            context.commit("UPDATE_" + params[0], [params[1], params[2]])
        },
    }
}

export default project
