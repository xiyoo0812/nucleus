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
        task: (state) => state.user.task,
        dept: (state) => state.user.user.dept,
        email: (state) => state.user.user.email,
        empCode: (state) => state.user.user.empCode,
        en_name: (state) => state.user.user.en_name,
        token: (state) => state.user.token,
        avatar: (state) => state.user.avatar,
        owns: (state) => state.project.owns,
        logs: (state) => state.project.logs,
        codes: (state) => state.project.codes,
        projs: (state) => state.project.projs,
        users: (state) => state.project.users,
        hosts: (state) => state.project.hosts,
        tasks: (state) => state.project.tasks,
        applys: (state) => state.project.applys,
        images: (state) => state.project.images,
        plugins: (state) => state.project.plugins,
        members: (state) => state.project.members,
        routers: (state) => state.project.routers,
        environs: (state) => state.project.environs,
        products: (state) => state.project.products,
        authkeys: (state) => state.project.authkeys,
        playbooks: (state) => state.project.playbooks,
        pipelines: (state) => state.project.pipelines,
        databases: (state) => state.project.databases,
    }
})

export default store
