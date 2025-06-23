<template>
  <view class="login-container">
    <view class="login-card glass-card">
      <!-- Logo区域 -->
      <view class="logo-section">
        <text class="logo-text">AI情绪日记</text>
        <text class="subtitle">记录情绪，理解自己</text>
      </view>
      
      <!-- 登录方式选择 -->
      <view class="login-methods">
        <!-- 手机验证码登录 -->
        <view class="phone-login-section">
          <view class="input-group">
            <view class="input-wrapper">
              <text class="input-icon">📱</text>
              <input 
                type="number"
                placeholder="请输入手机号"
                v-model="phoneForm.phone"
                class="input-field"
                maxlength="11"
                @input="onPhoneInput"
              />
            </view>
            <view class="input-underline" :class="{ active: phoneForm.phone }"></view>
          </view>
          
          <view class="input-group">
            <view class="input-wrapper">
              <text class="input-icon">🔢</text>
              <input 
                type="number"
                placeholder="请输入验证码"
                v-model="phoneForm.code"
                class="input-field"
                maxlength="6"
              />
              <button 
                class="sms-btn"
                :class="{ 
                  disabled: !canSendSMS || smsCountdown > 0,
                  loading: isSendingSMS 
                }"
                @click="sendSMS"
                :disabled="!canSendSMS || smsCountdown > 0 || isSendingSMS"
              >
                {{ getSMSButtonText }}
              </button>
            </view>
            <view class="input-underline" :class="{ active: phoneForm.code }"></view>
          </view>
          
          <!-- 昵称输入（可选） -->
          <view class="input-group">
            <view class="input-wrapper">
              <text class="input-icon">✨</text>
              <input 
                type="text"
                placeholder="设置昵称（可选）"
                v-model="phoneForm.nickname"
                class="input-field"
                maxlength="20"
              />
            </view>
            <view class="input-underline" :class="{ active: phoneForm.nickname }"></view>
          </view>
          
          <button 
            class="login-btn phone-login-btn"
            :class="{ loading: isPhoneLogging }"
            @click="handlePhoneLogin"
            :disabled="!canPhoneLogin || isPhoneLogging"
          >
            <text class="btn-text">{{ isPhoneLogging ? '登录中...' : '手机号登录' }}</text>
          </button>
        </view>
        
        <!-- 分隔线 -->
        <view class="divider">
          <view class="divider-line"></view>
          <text class="divider-text">或</text>
          <view class="divider-line"></view>
        </view>
        
        <!-- 微信登录 -->
        <view class="wechat-login-section">
          <button 
            class="login-btn wechat-login-btn"
            :class="{ loading: isWechatLogging }"
            @click="handleWechatLogin"
            :disabled="isWechatLogging"
          >
            <text class="wechat-icon">💬</text>
            <text class="btn-text">{{ isWechatLogging ? '登录中...' : '微信登录' }}</text>
          </button>
        </view>
        
        <!-- 开发环境测试区域 -->
        <view class="debug-section" v-if="isDevelopment">
          <view class="debug-title">开发测试</view>
          <view class="debug-actions">
            <button class="debug-btn" @click="fillTestPhone">测试手机号</button>
            <button class="debug-btn" @click="mockWechatLogin">模拟微信登录</button>
          </view>
          <view class="debug-info" v-if="debugInfo">
            <text class="debug-text">{{ debugInfo }}</text>
          </view>
        </view>
      </view>
    </view>
    
    <!-- 用户协议 -->
    <view class="agreement-section">
      <text class="agreement-text">
        登录即表示同意
        <text class="agreement-link" @click="showPrivacyPolicy">《用户协议》</text>
        和
        <text class="agreement-link" @click="showPrivacyPolicy">《隐私政策》</text>
      </text>
    </view>
  </view>
</template>

<script>
import { authAPI, setToken, setUser } from '../../utils/api'

export default {
  data() {
    return {
      // 手机登录表单
      phoneForm: {
        phone: '',
        code: '',
        nickname: ''
      },
      
      // 状态管理
      isPhoneLogging: false,
      isWechatLogging: false,
      isSendingSMS: false,
      smsCountdown: 0,
      
      // 开发环境标识
      isDevelopment: process.env.NODE_ENV === 'development',
      debugInfo: ''
    }
  },
  
  computed: {
    // 是否可以发送短信
    canSendSMS() {
      return this.phoneForm.phone.length === 11 && /^1[3-9]\d{9}$/.test(this.phoneForm.phone)
    },
    
    // 是否可以手机登录
    canPhoneLogin() {
      return this.canSendSMS && this.phoneForm.code.length === 6
    },
    
    // 短信按钮文本
    getSMSButtonText() {
      if (this.isSendingSMS) return '发送中...'
      if (this.smsCountdown > 0) return `${this.smsCountdown}s`
      return '获取验证码'
    }
  },
  
  methods: {
    // 手机号输入处理
    onPhoneInput(e) {
      // 限制只能输入数字
      this.phoneForm.phone = e.detail.value.replace(/\D/g, '')
    },
    
    // 发送短信验证码
    async sendSMS() {
      if (!this.canSendSMS || this.isSendingSMS) return
      
      this.isSendingSMS = true
      this.debugInfo = '正在发送验证码...'
      
      try {
        const response = await authAPI.sendSMS({
          phone: this.phoneForm.phone,
          purpose: 'login'
        })
        
        uni.showToast({
          title: '验证码发送成功',
          icon: 'success'
        })
        
        // 开发环境显示验证码
        if (response.code && this.isDevelopment) {
          this.debugInfo = `验证码: ${response.code}`
          this.phoneForm.code = response.code
        } else {
          this.debugInfo = '请查收短信验证码'
        }
        
        // 开始倒计时
        this.startCountdown()
        
      } catch (error) {
        console.error('发送验证码失败:', error)
        this.debugInfo = `发送失败: ${error.message}`
        
        uni.showToast({
          title: error.message || '验证码发送失败',
          icon: 'none'
        })
      } finally {
        this.isSendingSMS = false
      }
    },
    
    // 开始倒计时
    startCountdown() {
      this.smsCountdown = 60
      const timer = setInterval(() => {
        this.smsCountdown--
        if (this.smsCountdown <= 0) {
          clearInterval(timer)
        }
      }, 1000)
    },
    
    // 手机号登录
    async handlePhoneLogin() {
      if (!this.canPhoneLogin || this.isPhoneLogging) return
      
      this.isPhoneLogging = true
      this.debugInfo = '正在验证登录...'
      
      try {
        const response = await authAPI.phoneLogin({
          phone: this.phoneForm.phone,
          code: this.phoneForm.code,
          nickname: this.phoneForm.nickname
        })
        
        // 保存token和用户信息
        setToken(response.token)
        setUser(response.user)
        
        this.debugInfo = `登录成功! ${response.is_new_user ? '(新用户)' : '(老用户)'}`
        
        uni.showToast({
          title: response.is_new_user ? '注册成功' : '登录成功',
          icon: 'success'
        })
        
        // 延迟跳转
        setTimeout(() => {
          uni.switchTab({
            url: '/pages/index/index'
          })
        }, 1500)
        
      } catch (error) {
        console.error('手机登录失败:', error)
        this.debugInfo = `登录失败: ${error.message}`
        
        uni.showToast({
          title: error.message || '登录失败',
          icon: 'none'
        })
      } finally {
        this.isPhoneLogging = false
      }
    },
    
    // 微信登录
    async handleWechatLogin() {
      if (this.isWechatLogging) return
      
      this.isWechatLogging = true
      this.debugInfo = '正在微信登录...'
      
      try {
        // 在真实环境中，这里会调用微信登录API
        // uni.login({
        //   provider: 'weixin',
        //   success: async (loginRes) => {
        //     const response = await authAPI.wechatLogin({
        //       code: loginRes.code
        //     })
        //     // 处理登录结果...
        //   }
        // })
        
        // 开发环境模拟微信登录
        if (this.isDevelopment) {
          const mockCode = `mock_code_${Date.now()}`
          const response = await authAPI.wechatLogin({
            code: mockCode,
            nickname: '微信用户',
            gender: 'unknown'
          })
          
          // 保存token和用户信息
          setToken(response.token)
          setUser(response.user)
          
          this.debugInfo = `微信登录成功! ${response.is_new_user ? '(新用户)' : '(老用户)'}`
          
          uni.showToast({
            title: response.is_new_user ? '注册成功' : '登录成功',
            icon: 'success'
          })
          
          // 延迟跳转
          setTimeout(() => {
            uni.switchTab({
              url: '/pages/index/index'
            })
          }, 1500)
        } else {
          // 生产环境提示
          uni.showToast({
            title: '微信登录功能开发中',
            icon: 'none'
          })
        }
        
      } catch (error) {
        console.error('微信登录失败:', error)
        this.debugInfo = `微信登录失败: ${error.message}`
        
        uni.showToast({
          title: error.message || '微信登录失败',
          icon: 'none'
        })
      } finally {
        this.isWechatLogging = false
      }
    },
    
    // 填入测试手机号
    fillTestPhone() {
      this.phoneForm.phone = '13800138000'
      this.phoneForm.nickname = '测试用户'
    },
    
    // 模拟微信登录
    mockWechatLogin() {
      this.handleWechatLogin()
    },
    
    // 显示隐私政策
    showPrivacyPolicy() {
      uni.showModal({
        title: '用户协议与隐私政策',
        content: '我们承诺保护您的隐私，所有情绪数据仅用于个人分析，不会与第三方分享。',
        showCancel: false
      })
    }
  }
}
</script>

<style scoped>
/* CSS变量定义 */
:root {
  --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  --glass-bg: rgba(255, 255, 255, 0.25);
  --glass-border: rgba(255, 255, 255, 0.18);
  --shadow-light: 0 8rpx 32rpx rgba(31, 38, 135, 0.37);
  --input-focus: #667eea;
  --wechat-green: #07c160;
}

.login-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40rpx 30rpx;
  position: relative;
}

.login-container::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grain" width="100" height="100" patternUnits="userSpaceOnUse"><circle cx="25" cy="25" r="1" fill="rgba(255,255,255,0.1)"/><circle cx="75" cy="75" r="1" fill="rgba(255,255,255,0.1)"/></pattern></defs><rect width="100" height="100" fill="url(%23grain)"/></svg>');
  pointer-events: none;
}

.glass-card {
  background: var(--glass-bg);
  backdrop-filter: blur(25rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  box-shadow: var(--shadow-light);
  position: relative;
  overflow: hidden;
}

.login-card {
  width: 100%;
  max-width: 640rpx;
  padding: 60rpx 50rpx;
  z-index: 1;
}

.logo-section {
  text-align: center;
  margin-bottom: 60rpx;
}

.logo-text {
  font-size: 52rpx;
  font-weight: 700;
  background: var(--primary-gradient);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  display: block;
  margin-bottom: 12rpx;
}

.subtitle {
  font-size: 28rpx;
  color: rgba(102, 126, 234, 0.8);
  display: block;
}

.login-methods {
  width: 100%;
}

.phone-login-section {
  margin-bottom: 40rpx;
}

.input-group {
  margin-bottom: 30rpx;
  position: relative;
}

.input-wrapper {
  display: flex;
  align-items: center;
  position: relative;
}

.input-icon {
  font-size: 32rpx;
  margin-right: 20rpx;
  width: 40rpx;
  text-align: center;
}

.input-field {
  flex: 1;
  height: 80rpx;
  border: none;
  background: transparent;
  font-size: 32rpx;
  color: #333;
  padding: 0 20rpx 0 0;
  outline: none;
}

.input-field::placeholder {
  color: rgba(102, 126, 234, 0.6);
}

.input-underline {
  position: absolute;
  bottom: 0;
  left: 60rpx;
  right: 0;
  height: 2rpx;
  background: rgba(102, 126, 234, 0.3);
  transition: all 0.3s ease;
}

.input-underline.active {
  background: var(--primary-gradient);
  height: 4rpx;
}

.sms-btn {
  padding: 12rpx 24rpx;
  background: var(--primary-gradient);
  color: white;
  border: none;
  border-radius: 20rpx;
  font-size: 24rpx;
  font-weight: 600;
  min-width: 140rpx;
  transition: all 0.3s ease;
}

.sms-btn.disabled {
  background: rgba(102, 126, 234, 0.3);
  color: rgba(255, 255, 255, 0.7);
}

.sms-btn.loading {
  background: rgba(102, 126, 234, 0.6);
}

.login-btn {
  width: 100%;
  height: 88rpx;
  border: none;
  border-radius: 22rpx;
  font-size: 32rpx;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.phone-login-btn {
  background: var(--primary-gradient);
  color: white;
  box-shadow: 0 8rpx 24rpx rgba(102, 126, 234, 0.3);
}

.phone-login-btn:not(:disabled):active {
  transform: translateY(2rpx);
  box-shadow: 0 4rpx 12rpx rgba(102, 126, 234, 0.4);
}

.phone-login-btn.loading {
  background: rgba(102, 126, 234, 0.7);
}

.phone-login-btn:disabled {
  background: rgba(102, 126, 234, 0.3);
  color: rgba(255, 255, 255, 0.7);
}

.wechat-login-btn {
  background: var(--wechat-green);
  color: white;
  box-shadow: 0 8rpx 24rpx rgba(7, 193, 96, 0.3);
}

.wechat-login-btn:not(:disabled):active {
  transform: translateY(2rpx);
  box-shadow: 0 4rpx 12rpx rgba(7, 193, 96, 0.4);
}

.wechat-login-btn.loading {
  background: rgba(7, 193, 96, 0.7);
}

.wechat-icon {
  font-size: 36rpx;
  margin-right: 12rpx;
}

.btn-text {
  font-size: 32rpx;
  font-weight: 700;
}

.divider {
  display: flex;
  align-items: center;
  margin: 40rpx 0;
}

.divider-line {
  flex: 1;
  height: 2rpx;
  background: rgba(102, 126, 234, 0.2);
}

.divider-text {
  margin: 0 20rpx;
  font-size: 24rpx;
  color: rgba(102, 126, 234, 0.6);
}

.debug-section {
  margin-top: 40rpx;
  padding: 20rpx;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 12rpx;
  border: 1rpx solid rgba(102, 126, 234, 0.2);
}

.debug-title {
  font-size: 24rpx;
  color: rgba(102, 126, 234, 0.8);
  font-weight: 600;
  margin-bottom: 12rpx;
}

.debug-actions {
  display: flex;
  gap: 12rpx;
  margin-bottom: 12rpx;
}

.debug-btn {
  padding: 8rpx 16rpx;
  background: rgba(102, 126, 234, 0.2);
  color: #667eea;
  border: none;
  border-radius: 12rpx;
  font-size: 22rpx;
}

.debug-info {
  margin-top: 12rpx;
}

.debug-text {
  font-size: 22rpx;
  color: rgba(102, 126, 234, 0.7);
  word-break: break-all;
  line-height: 1.4;
}

.agreement-section {
  margin-top: 40rpx;
  text-align: center;
}

.agreement-text {
  font-size: 24rpx;
  color: rgba(102, 126, 234, 0.6);
  line-height: 1.4;
}

.agreement-link {
  color: #667eea;
  text-decoration: underline;
}
</style> 