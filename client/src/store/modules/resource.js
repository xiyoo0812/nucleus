//store/modules/resource.ts
import * as utils from '../../utils/index';

const resource = {
    state:  {
        users: [],
        codes: [],
        projs: [],
    },
    mutations: {
        INIT_USER: (state, users) => {
            state.users = users
        },
        ADD_USER: (state, user) => {
            state.users.push(user)
        },
        DEL_USER: (state, user_id, key) => {
            utils.array_remove(state.users, user_id, key)
        },
        UPDATE_USER: (state, user, key) => {
            utils.array_update(state.users, user, key)
        },
        INIT_PROJ: (state, projs) => {
            state.projs = projs
        },
        ADD_PROJ: (state, proj) => {
            state.projs.push(proj)
        },
        DEL_PROJ: (state, proj_id, key) => {
            utils.array_remove(state.projs, proj_id, key)
            console.log("DEL_PROJ", state.projs.length);
        },
        UPDATE_PROJ: (state, proj, key) => {
            utils.array_update(state.projs, proj, key)
        },
        INIT_CODE: (state, codes) => {
            state.codes = codes
        },
        ADD_CODE: (state, code) => {
            state.codes.push(code)
        },
        DEL_CODE: (state, code_id, key) => {
            utils.array_remove(state.codes, code_id, key)
        },
        UPDATE_CODE: (state, code, key) => {
            utils.array_update(state.codes, code, key)
        },
    },
    actions: {
        InitResource(context, params) {
            context.commit("INIT_" + params[0], params[1])
        },
        AddResource(context, params) {
            context.commit("ADD_" + params[0], params[1])
        },
        DelResource(context, params) {
            context.commit("DEL_" + params[0], params[1], params[2])
        },
        UpdateResource(context, params) {
            context.commit("UPDATE_" + params[0], params[1], params[2])
        },
    }
}

export default resource
