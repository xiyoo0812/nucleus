<template lang="html">
    <div class="login-wrap">
        <div class="ms-login">
            <div class="ms-title">注册账号</div>
            <el-form :model="form" :rules="rules" ref="register" label-width="0px" class="ms-content">
                <el-form-item prop="username">
                    <el-input v-model="form.username" placeholder="username">
                        <el-button slot="prepend" icon="el-icon-lx-people"></el-button>
                    </el-input>
                </el-form-item>
                <el-form-item prop="password">
                    <el-input type="password" placeholder="password" v-model="form.password">
                        <el-button slot="prepend" icon="el-icon-lx-lock"></el-button>
                    </el-input>
                </el-form-item>
                <el-form-item prop="re_password">
                    <el-input type="password" placeholder="password" v-model="form.re_password" @keyup.enter.native="register()">
                        <el-button slot="prepend" icon="el-icon-lx-lock"></el-button>
                    </el-input>
                </el-form-item>
                <div class="login-btn">
                    <el-button type="primary" @click="register()">注册</el-button>
                </div>
                <div class="login-btn">
                    <router-link :to="{ path: '/login' }">
                        <el-button type="text">返回登录</el-button>
                    </router-link>
                </div>
            </el-form>
        </div>
    </div>
</template>

<script>
import { register } from '../../api/login';
import { showSuccess, showFailed } from '../../utils/index';

export default {
    name: 'login',
    data: function() {
        return {
            form: {
                username: '',
                password: '',
                re_password: "",
            },
            rules: {
                username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
                password: [{ required: true, message: '请输入密码', trigger: 'blur' },
                    {   validator: (rule, value, callback) => {
                            // 6-16位, 数字, 字母, 字符至少包含两种, 同时不能包含中文和空格
                            let reg = /(?!^[0-9]+$)(?!^[A-z]+$)(?!^[^A-z0-9]+$)^[^\s\u4e00-\u9fa5]{6,16}$/;
                            if (!reg.test(value)) {
                                callback(new Error('密码长度需6-16位，且包含字母和字符'))
                            } else {
                                callback()
                            }
                        },
                        trigger: 'blur'
                    }
                ],
                re_password: [{ required: true, message: '请再次输入密码', trigger: 'blur' },
                    { validator: (rule, value, callback) => {
                            if (value === '') {
                                callback(new Error('请再次输入密码'))
                            } else if (value !== this.form.password) {
                                callback(new Error('两次输入密码不一致!'))
                            } else {
                                callback()
                            }
                        },
                        trigger: 'blur'
                    }
                ],
            },
        };
    },
    methods: {
        register() {
            this.$refs.register.validate(valid => {
                if (valid) {
                    register(this.form.username, this.form.password).then(res => {
                        if (res.code == 0){
                            showSuccess(this, '注册成功')
                            this.$router.push("/login")
                        } else if (res.code == -1){
                            showFailed(this, "数据库错误，注册失败，请联系管理员")
                        }
                    });
                } else {
                    showFailed(this, '请检查账号和密码')
                    return false
                }
            })
        }
    },
};
</script>

<style scoped>
.login-wrap {
    position: relative;
    width: 100%;
    height: 100%;
    background-image: url(../../assets/img/login-bg.jpg);
    background-size: 100%;
}
.ms-title {
    width: 100%;
    line-height: 50px;
    text-align: center;
    font-size: 20px;
    color: #fff;
    border-bottom: 1px solid #ddd;
}
.ms-login {
    position: absolute;
    left: 50%;
    top: 50%;
    width: 350px;
    margin: -190px 0 0 -175px;
    border-radius: 5px;
    background: rgba(255, 255, 255, 0.3);
    overflow: hidden;
}
.ms-content {
    padding: 30px 30px;
}
.login-btn {
    text-align: center;
}
.login-btn button {
    width: 100%;
    height: 36px;
    margin-bottom: 10px;
}
.login-tips {
    font-size: 12px;
    line-height: 30px;
    color: #fff;
}
</style>
