//store/modules/user.ts

import { getToken, setToken, removeToken } from '@/utils/auth'

function getUsername(){
    var token = getToken()
    if (token) {
        return token.username
    }
    return ''
}

function getAvatar(){
    var token = getToken()
    if (token) {
        return token.avatar
    }
    return ''
}

const user = {
    state:  {
        name: getUsername(),
        avatar: getAvatar(),
    },

    mutations: {
        SET_NAME: (state, name) => {
            state.name = name
        },
        SET_AVATAR: (state, avatar) => {
            state.avatar = avatar
        },
    },

    actions: {
        // 用户名登录
        Login(context, data) {
            data.avatar = require("../../assets/img/img.jpg")
            context.commit('SET_AVATAR', data.avatar)
            context.commit('SET_NAME', data.username)
            setToken(data)
        },
        // 登出
        LogOut(context) {
            context.commit('SET_NAME', '')
            context.commit('SET_AVATAR', '')
            removeToken()
        },
    }
}

export default user
