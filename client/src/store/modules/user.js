//store/modules/user.ts

import { getToken, setToken, removeToken } from '@/utils/auth'

function getName(){
    var token = getToken()
    if (token) {
        return token.name
    }
    return 'TEST'
}

function getAvatar(){
    var token = getToken()
    if (token) {
        return token.avatar
    }
    return require("../../assets/img/img.jpg")
}

const user = {
    state:  {
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
    },

    actions: {
        // 用户名登录
        Login(context, data) {
            context.commit('SET_AVATAR', data.avatar)
            context.commit('SET_NAME', data.name)
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
