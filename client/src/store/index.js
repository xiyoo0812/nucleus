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
        token: (state) => state.user.token,
        avatar: (state) => state.user.avatar,
        name: (state) => state.user.name,
        codes: (state) => state.resource.codes,
        projs: (state) => state.resource.projs,
        users: (state) => state.resource.users,
    }
})

export default store
