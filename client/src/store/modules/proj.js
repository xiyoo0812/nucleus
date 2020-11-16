//store/modules/resource.ts
import * as utils from '../../utils/index';

const project = {
    state:  {
        databases: [],
        pipelines: [],
        playbooks: [],
        templates: [],
        authkeys: [],
        products: [],
        environs: [],
        members: [],
        routers: [],
        plugins: [],
        applys: [],
        images: [],
        codes: [],
        tasks: [],
        projs: [],
        hosts: [],
        logs: [],
        owns: [],
    },
    mutations: {
        INIT_LOG: (state, logs) => {
            state.logs = logs
        },
        INIT_OWNS: (state, owns) => {
            state.owns = owns
        },
        ADD_OWNS: (state, proj) => {
            state.owns.push(proj)
        },
        DEL_OWNS: (state, args) => {
            utils.array_remove(state.owns, args[0], args[1])
        },
        INIT_HOST: (state, hosts) => {
            state.hosts = hosts
        },
        ADD_HOST: (state, host) => {
            state.hosts.push(host)
        },
        DEL_HOST: (state, args) => {
            utils.array_remove(state.hosts, args[0], args[1])
        },
        UPDATE_HOST: (state, args) => {
            utils.array_update(state.hosts, args[0], args[1])
        },
        INIT_TASK: (state, tasks) => {
            state.tasks = tasks
        },
        ADD_TASK: (state, task) => {
            state.tasks.push(task)
        },
        DEL_TASK: (state, args) => {
            utils.array_remove(state.tasks, args[0], args[1])
        },
        UPDATE_TASK: (state, args) => {
            utils.array_update(state.tasks, args[0], args[1])
        },
        INIT_APPLY: (state, applys) => {
            state.applys = applys
        },
        DEL_APPLY: (state, args) => {
            utils.array_remove(state.applys, args[0], args[1])
        },
        INIT_ENVIRON: (state, environs) => {
            state.environs = environs
        },
        ADD_ENVIRON: (state, environ) => {
            state.environs.push(environ)
        },
        DEL_ENVIRON: (state, args) => {
            utils.array_remove(state.environs, args[0], args[1])
        },
        UPDATE_ENVIRON: (state, args) => {
            utils.array_update(state.environs, args[0], args[1])
        },
        INIT_TEMPLATE: (state, templates) => {
            state.templates = templates
        },
        ADD_TEMPLATE: (state, template) => {
            state.templates.push(template)
        },
        DEL_TEMPLATE: (state, args) => {
            utils.array_remove(state.templates, args[0], args[1])
        },
        UPDATE_TEMPLATE: (state, args) => {
            utils.array_update(state.templates, args[0], args[1])
        },
        INIT_ROUTER: (state, routers) => {
            state.routers = routers
        },
        ADD_ROUTER: (state, router) => {
            state.routers.push(router)
        },
        DEL_ROUTER: (state, args) => {
            utils.array_remove(state.routers, args[0], args[1])
        },
        UPDATE_ROUTER: (state, args) => {
            utils.array_update(state.routers, args[0], args[1])
        },
        INIT_MEMBER: (state, members) => {
            state.members = members
        },
        ADD_MEMBER: (state, member) => {
            state.members.push(member)
        },
        DEL_MEMBER: (state, args) => {
            utils.array_remove(state.members, args[0], args[1])
        },
        UPDATE_MEMBER: (state, args) => {
            utils.array_update(state.members, args[0], args[1])
        },
        INIT_PLUGIN: (state, plugins) => {
            state.plugins = plugins
        },
        ADD_PLUGIN: (state, plugin) => {
            state.plugins.push(plugin)
        },
        DEL_PLUGIN: (state, args) => {
            utils.array_remove(state.plugins, args[0], args[1])
        },
        UPDATE_PLUGIN: (state, args) => {
            utils.array_update(state.plugins, args[0], args[1])
        },
        INIT_IMAGE: (state, images) => {
            state.images = images
        },
        ADD_IMAGE: (state, image) => {
            state.images.push(image)
        },
        DEL_IMAGE: (state, args) => {
            utils.array_remove(state.images, args[0], args[1])
        },
        UPDATE_IMAGE: (state, args) => {
            utils.array_update(state.images, args[0], args[1])
        },
        INIT_PRODUCT: (state, products) => {
            state.products = products
        },
        ADD_PRODUCT: (state, product) => {
            state.products.push(product)
        },
        DEL_PRODUCT: (state, args) => {
            utils.array_remove(state.products, args[0], args[1])
        },
        UPDATE_PRODUCT: (state, args) => {
            utils.array_update(state.products, args[0], args[1])
        },
        INIT_AUTHKEY: (state, authkeys) => {
            state.authkeys = authkeys
        },
        ADD_AUTHKEY: (state, key) => {
            state.authkeys.push(key)
        },
        DEL_AUTHKEY: (state, args) => {
            utils.array_remove(state.authkeys, args[0], args[1])
        },
        UPDATE_AUTHKEY: (state, args) => {
            utils.array_update(state.authkeys, args[0], args[1])
        },
        INIT_PLAYBOOK: (state, playbooks) => {
            state.playbooks = playbooks
        },
        ADD_PLAYBOOK: (state, playbook) => {
            state.playbooks.push(playbook)
        },
        DEL_PLAYBOOK: (state, args) => {
            utils.array_remove(state.playbooks, args[0], args[1])
        },
        UPDATE_PLAYBOOK: (state, args) => {
            utils.array_update(state.playbooks, args[0], args[1])
        },
        INIT_PIPELINE: (state, pipelines) => {
            state.pipelines = pipelines
        },
        ADD_PIPELINE: (state, pipeline) => {
            state.pipelines.push(pipeline)
        },
        DEL_PIPELINE: (state, args) => {
            utils.array_remove(state.pipelines, args[0], args[1])
        },
        UPDATE_PIPELINE: (state, args) => {
            utils.array_update(state.pipelines, args[0], args[1])
        },
        INIT_DATABASE: (state, databases) => {
            state.databases = databases
        },
        ADD_DATABASE: (state, database) => {
            state.databases.push(database)
        },
        DEL_DATABASE: (state, args) => {
            utils.array_remove(state.databases, args[0], args[1])
        },
        UPDATE_DATABASE: (state, args) => {
            utils.array_update(state.databases, args[0], args[1])
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
