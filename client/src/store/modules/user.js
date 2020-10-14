//store/modules/user.ts

import * as auth from '@/utils/auth'
import { getSessProj } from '../../utils/auth'

function getName(){
    var token = auth.getLocUser()
    if (token) {
        return token.name
    }
    return ""
}

function getAvatar(){
    var token = auth.getLocUser()
    if (token) {
        return token.avatar
    }
    return require("../../assets/img/img.jpg")
}

function getUser(){
    return auth.getLocUser()
}

function getProj(){
    return auth.getSessProj()
}

const user = {
    state:  {
        proj: getProj(),
        user: getUser(),
        name: getName(),
        avatar: getAvatar(),
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
    },

    actions: {
        // 用户名登录
        Login(context, data) {
            context.commit('SET_AVATAR', data.avatar)
            context.commit('SET_NAME', data.name)
            context.commit('SET_USER', data)
            auth.setLocUser(data)
        },
        // 登出
        LogOut(context) {
            context.commit('SET_NAME', '')
            context.commit('SET_AVATAR', '')
            auth.delLocUser()
        },
        // 当前项目
        SetProj(context, data) {
            context.commit('SET_PROJ', data)
            auth.setSessProj(data)
        },
    }
}

export default user
