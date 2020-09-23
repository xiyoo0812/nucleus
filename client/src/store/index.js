import Vue from 'vue'
import Vuex from 'vuex'
import user from './modules/user'
import resource from './modules/resource'

Vue.use(Vuex)

const store = new Vuex.Store({
    modules : {
        resource,
        user,
    },
    getters : {
        name: (state) => state.user.name,
        proj: (state) => state.user.proj,
        dept: (state) => state.user.user.dept,
        email: (state) => state.user.user.email,
        empCode: (state) => state.user.user.empCode,
        en_name: (state) => state.user.user.en_name,
        token: (state) => state.user.token,
        avatar: (state) => state.user.avatar,
        meprojs: (state) => state.user.meprojs,
        codes: (state) => state.resource.codes,
        projs: (state) => state.resource.projs,
        users: (state) => state.resource.users,
    }
})

export default store
