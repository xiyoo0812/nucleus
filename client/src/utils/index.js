
export function parseTime(time, cFormat) {
    if (arguments.length === 0) {
        return ""
    }
    const format = cFormat || '{y}-{m}-{d} {h}:{i}:{s}'
    let date
    if (typeof time === 'object') {
        date = time
    } else {
        if (('' + time).length === 10) time = parseInt(time) * 1000
        date = new Date(time)
    }
    const formatObj = {
        y: date.getFullYear(),
        m: date.getMonth() + 1,
        d: date.getDate(),
        h: date.getHours(),
        i: date.getMinutes(),
        s: date.getSeconds(),
        a: date.getDay()
    }
    const time_str = format.replace(/{(y|m|d|h|i|s|a)+}/g, (result, key) => {
        let value = formatObj[key]
        if (key === 'a') { return ['日', '一', '二', '三', '四', '五', '六'][value ] }
        if (result.length > 0 && value < 10) {
        value = '0' + value
        }
        return value || 0
    })
    return time_str
}

export function formatTime(time, option) {
    if (time <= 0) {
        return ""
    } 
    time = +time * 1000
    const now = Date.now()
    const dt = new Date(time)
    const diff = (now - dt.getTime()) / 1000
    if (diff < 30) {
        return '刚刚'
    } else if (diff < 3600) {
        return Math.ceil(diff / 60) + '分钟前'
    } else if (diff < 3600 * 24) {
        return Math.ceil(diff / 3600) + '小时前'
    } else if (diff < 3600 * 24 * 2) {
        return '1天前'
    }
    if (option) {
        return parseTime(time, option)
    } else {
        return (dt.getMonth() + 1 + '月' + dt.getDate() + '日' + dt.getHours() + '时' + dt.getMinutes() + '分')
    }
}

export function getTime(type) {
    if (type === 'start') {
        return new Date().getTime() - 3600 * 1000 * 24 * 90
    } else {
        return new Date(new Date().toDateString())
    }
}

export function formatTimeDuration(time) {
    if (typeof (time) !== 'number') {
        return time
    }
    if (time < 1) {
        time = 0
    }
    var str = ''
    var hour = Math.floor(time / 3600)
    var minutes = Math.floor(time % 3600 / 60)
    var sec = Math.floor(time % 60)
    if (hour > 0) {
        str += hour + '小时'
    }
    if (minutes > 0) {
        str += minutes + '分'
    }
    if (sec > 0) {
        str += sec + '秒'
    }
    if (!str) {
        str = '0秒'
    }
    return str
}

export function formatBool(b) {
    if (b) {
        return '是'
    } else {
        return '否'
    }
}

export function newGuid() {
    var d = new Date().getTime()
    var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
        var r = (d + Math.random() * 16) % 16 | 0
        d = Math.floor(d / 16)
        return (c == 'x' ? r : (r & 0x3 | 0x8)).toString(16)
    })
    return uuid
}

export function today() {
    return new Date(parseTime(new Date(), '{y}-{m}-{d}'))
}

export function getBaseUrl(url) {
    var reg = /^((\w+):\/\/([^\/:]*)(?::(\d+))?)(.*)/;
    reg.exec(url);
    return RegExp.$1;
}

export function showSuccess(view, msg) {
    view.$notify({title: '成功', message: msg, type: 'success', duration: 2000 })
}

export function showFailed(view, msg) {
    view.$notify({title: '失败', message: msg, type: 'success', duration: 2000 })
}

export function showNetRes(view, res, func) {
    if (res.code == 0) {
        func()
    } else if (res.code == -2) {
        view.$store.dispatch("LogOut", res.user)
        view.$router.push({ path: '/login' })
    } else {
        showFailed(view, res.msg)
    }
}

export function confirm(view, msg, func) {
    view.$confirm(msg, '提示', {confirmButtonText: '确定',cancelButtonText: '取消',type: 'warning'}).then(func);
}

export function array_find(array, obj_key, key) {
    for (let i = 0, len = array.length; i < len; i++) {
        if(array[i][key] == obj_key) {
            return true
        }
    }
    return false
}

export function array_count(array, obj_key, key) {
    var count = 0
    for (let i = 0, len = array.length; i < len; i++) {
        if(array[i][key] == obj_key) {
            count++
        }
    }
    return count
}

export function array_remove(array, obj_key, key) {
    for (let i = 0, len = array.length; i < len; i++) {
        if(array[i][key] == obj_key) {
            array.splice(i, 1)
            break;
        }
    }
}

export function array_update(array, obj, key) {
    for (let i = 0, len = array.length; i < len; i++) {
        if(array[i][key] == obj[key]) {
            array.splice(i, 1, obj)
            break;
        }
    }
}