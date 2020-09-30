//store/modules/user.ts

import { getToken, setToken, removeToken } from '@/utils/auth'

function getName(){
    var token = getToken()
    if (token) {
        return token.name
    }
    return ""
}

function getAvatar(){
    var token = getToken()
    if (token) {
        return token.avatar
    }
    return require("../../assets/img/img.jpg")
}

function getUser(){
    return getToken()
}

const user = {
    state:  {
        proj: null,
        user: getUser(),
        name: getName(),
        avatar: getAvatar(),
        owns : [{name : "测试项目", desc : "这是一个测试项目", id : "123456"}],
    },
    mutations: {
        SET_NAME: (state, name) => {
            state.name = name
        },
        SET_AVATAR: (state, avatar) => {
            state.avatar = avatar
        },
        SET_USER: (state, user) => {
            state.user = user
        },
        SET_PROJ: (state, proj) => {
            state.proj = proj
        },
        SET_OWNS: (state, owns) => {
            state.owns = owns
        },
    },

    actions: {
        // 用户名登录
        Login(context, data) {
            context.commit('SET_AVATAR', data.avatar)
            context.commit('SET_NAME', data.name)
            context.commit('SET_USER', data)
            setToken(data)
        },
        // 登出
        LogOut(context) {
            context.commit('SET_NAME', '')
            context.commit('SET_AVATAR', '')
            removeToken()
        },
        // 当前项目
        SetProj(context, data) {
            context.commit('SET_PROJ', data.proj)
        },
        // 拥有的项目
        SetOwns(context, data) {
            context.commit('SET_OWNS', data.owns)
        },
    }
}

export default user
