import axios from 'axios'
import { getBaseUrl } from "./index";


const service = axios.create({
    baseURL: getBaseUrl(window.location.href),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    timeout: 10000
})

service.interceptors.request.use( (config) => {
    return config
}, (error) => {
    console.log(error)
    return Promise.reject()
})

service.interceptors.response.use((response) => {
    if(response.status === 200){
        return response.data
    }else{
        Promise.reject()
    }
}, (error) => {
    console.log(error)
    return Promise.reject()
})

export default service