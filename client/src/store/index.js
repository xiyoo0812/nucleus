import Vue from 'vue'
import Vuex from 'vuex'
import user from './modules/user'
import project from './modules/proj'

Vue.use(Vuex)

const store = new Vuex.Store({
    modules : {
        project,
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
        owns: (state) => state.user.owns,
        codes: (state) => state.project.codes,
        projs: (state) => state.project.projs,
        users: (state) => state.project.users,
    }
})

export default store
