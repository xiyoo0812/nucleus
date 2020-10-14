//utils/auth.ts

const userToken = 'Authorization'
const projToken = 'AuthorizationProj'

export function getLocUser() {
    var token = localStorage.getItem(userToken)
    if (token) {
        var now = new Date().getTime()
        var userData = JSON.parse(token)
        if (userData.tick >= now){
            return userData
        }
        localStorage.removeItem(userToken)
    }
}

export function setLocUser(user) {
    user.tick = new Date().getTime() + 3600 * 1000
    localStorage.setItem(userToken, JSON.stringify(user))
}

export function delLocUser() {
    localStorage.removeItem(userToken)
}

export function getSessProj() {
    return JSON.parse(sessionStorage.getItem(projToken))
}

export function setSessProj(proj) {
    sessionStorage.setItem(projToken, JSON.stringify(proj))
}