//utils/auth.ts

const TokenKey = 'Authorization'

export function getToken() {
    var token = localStorage.getItem(TokenKey)
    if (token) {
        var now = new Date().getTime()
        var tokenData = JSON.parse(token)
        if (tokenData.tick >= now){
            return tokenData
        }
        localStorage.removeItem(TokenKey)
    }
}

export function setToken(token) {
    token.tick = new Date().getTime() + 3600 * 1000
    localStorage.setItem(TokenKey, JSON.stringify(token))
}

export function removeToken() {
    localStorage.removeItem(TokenKey)
}
