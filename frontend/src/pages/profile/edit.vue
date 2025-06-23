<template>
  <view class="container">
    <!-- 页面头部 -->
    <view class="page-header">
      <view class="header-content">
        <text class="page-title">编辑资料</text>
        <text class="page-subtitle">完善个人信息，获得更好的体验</text>
      </view>
    </view>

    <!-- 头像编辑区域 -->
    <view class="avatar-section glass-card">
      <view class="avatar-container" @click="changeAvatar">
        <image 
          class="avatar-image" 
          :src="userInfo.avatar || '/static/default-avatar.png'" 
          mode="aspectFill" 
        />
        <view class="avatar-overlay">
          <text class="camera-icon">📷</text>
          <text class="change-text">更换头像</text>
        </view>
        <view class="avatar-glow"></view>
      </view>
      <text class="avatar-tip">点击更换头像</text>
    </view>

    <!-- 基本信息编辑 -->
    <view class="form-section glass-card">
      <view class="section-header">
        <text class="section-title">基本信息</text>
      </view>
      
      <view class="form-group">
        <text class="form-label">昵称</text>
        <input 
          class="form-input"
          v-model="userInfo.nickname"
          placeholder="请输入昵称"
          maxlength="50"
        />
        <view class="input-underline"></view>
      </view>

      <view class="form-group">
        <text class="form-label">个人简介</text>
        <textarea 
          class="form-textarea"
          v-model="userInfo.bio"
          placeholder="介绍一下自己吧..."
          maxlength="500"
          auto-height
        />
        <view class="char-count">{{ userInfo.bio?.length || 0 }}/500</view>
        <view class="input-underline"></view>
      </view>

      <view class="form-group">
        <text class="form-label">性别</text>
        <view class="gender-options">
          <view 
            class="gender-option"
            v-for="option in genderOptions"
            :key="option.value"
            :class="{ active: userInfo.gender === option.value }"
            @click="selectGender(option.value)"
          >
            <text class="gender-icon">{{ option.icon }}</text>
            <text class="gender-text">{{ option.label }}</text>
          </view>
        </view>
      </view>

      <view class="form-group">
        <text class="form-label">出生日期</text>
        <picker 
          mode="date" 
          :value="userInfo.birth_date" 
          @change="onDateChange"
          class="date-picker"
        >
          <view class="picker-display">
            <text class="picker-text">
              {{ userInfo.birth_date || '请选择出生日期' }}
            </text>
            <text class="picker-icon">📅</text>
          </view>
        </picker>
        <view class="input-underline"></view>
      </view>
    </view>

    <!-- 应用设置 -->
    <view class="settings-section glass-card">
      <view class="section-header">
        <text class="section-title">应用设置</text>
      </view>

      <view class="setting-item">
        <view class="setting-info">
          <text class="setting-icon">🌙</text>
          <view class="setting-text">
            <text class="setting-name">主题模式</text>
            <text class="setting-desc">选择您喜欢的主题风格</text>
          </view>
        </view>
        <picker 
          :range="themeOptions" 
          :value="themeIndex"
          @change="onThemeChange"
        >
          <view class="setting-value">
            <text>{{ currentTheme }}</text>
            <text class="arrow-icon">></text>
          </view>
        </picker>
      </view>

      <view class="setting-item">
        <view class="setting-info">
          <text class="setting-icon">🔔</text>
          <view class="setting-text">
            <text class="setting-name">推送通知</text>
            <text class="setting-desc">接收情绪提醒和分析报告</text>
          </view>
        </view>
        <switch 
          :checked="userInfo.notification_enabled"
          @change="onNotificationChange"
          color="#667eea"
        />
      </view>

      <view class="setting-item" v-if="userInfo.notification_enabled">
        <view class="setting-info">
          <text class="setting-icon">⏰</text>
          <view class="setting-text">
            <text class="setting-name">提醒时间</text>
            <text class="setting-desc">每日情绪记录提醒</text>
          </view>
        </view>
        <picker 
          mode="time" 
          :value="userInfo.daily_reminder_time" 
          @change="onTimeChange"
        >
          <view class="setting-value">
            <text>{{ userInfo.daily_reminder_time || '21:00' }}</text>
            <text class="arrow-icon">></text>
          </view>
        </picker>
      </view>

      <view class="setting-item">
        <view class="setting-info">
          <text class="setting-icon">🛡️</text>
          <view class="setting-text">
            <text class="setting-name">数据分析</text>
            <text class="setting-desc">允许分析您的情绪数据</text>
          </view>
        </view>
        <switch 
          :checked="userInfo.analytics_consent"
          @change="onAnalyticsChange"
          color="#667eea"
        />
      </view>
    </view>

    <!-- 保存按钮 -->
    <view class="save-section">
      <button 
        class="save-button" 
        @click="saveProfile"
        :disabled="isSaving"
      >
        <view class="button-content">
          <text class="save-icon" v-if="!isSaving">💾</text>
          <view class="loading-spinner" v-if="isSaving"></view>
          <text class="save-text">{{ isSaving ? '保存中...' : '保存修改' }}</text>
        </view>
      </button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { authAPI, getUser, setUser } from '../../utils/api'

// 类型定义
interface UserInfo {
  nickname: string
  bio: string
  gender: string
  birth_date: string
  avatar: string
  notification_enabled: boolean
  daily_reminder_time: string
  theme_preference: string
  analytics_consent: boolean
}

// 响应式数据
const userInfo = ref<UserInfo>({
  nickname: '',
  bio: '',
  gender: 'N',
  birth_date: '',
  avatar: '',
  notification_enabled: true,
  daily_reminder_time: '21:00',
  theme_preference: 'auto',
  analytics_consent: true
})

const isSaving = ref(false)

// 选项数据
const genderOptions = ref([
  { value: 'M', label: '男', icon: '👨' },
  { value: 'F', label: '女', icon: '👩' },
  { value: 'O', label: '其他', icon: '🧑' },
  { value: 'N', label: '保密', icon: '🤐' }
])

const themeOptions = ref(['跟随系统', '浅色主题', '深色主题'])
const themeIndex = ref(0)

// 计算属性
const currentTheme = computed(() => {
  const themeMap: Record<string, string> = {
    'auto': '跟随系统',
    'light': '浅色主题',
    'dark': '深色主题'
  }
  return themeMap[userInfo.value.theme_preference] || '跟随系统'
})

// 方法
const loadUserInfo = async () => {
  try {
    const user = getUser()
    if (user) {
      userInfo.value = {
        nickname: user.nickname || '',
        bio: user.bio || '',
        gender: user.gender || 'N',
        birth_date: user.birth_date || '',
        avatar: user.avatar || '',
        notification_enabled: user.notification_enabled !== false,
        daily_reminder_time: user.daily_reminder_time || '21:00',
        theme_preference: user.theme_preference || 'auto',
        analytics_consent: user.analytics_consent !== false
      }
      
      // 设置主题索引
      const themeMap: Record<string, number> = {
        'auto': 0,
        'light': 1,
        'dark': 2
      }
      themeIndex.value = themeMap[userInfo.value.theme_preference] || 0
    }
  } catch (error) {
    console.error('加载用户信息失败:', error)
    uni.showToast({
      title: '加载失败，请重试',
      icon: 'none'
    })
  }
}

const changeAvatar = () => {
  uni.chooseImage({
    count: 1,
    sizeType: ['compressed'],
    sourceType: ['album', 'camera'],
    success: (res) => {
      userInfo.value.avatar = res.tempFilePaths[0]
      uni.showToast({
        title: '头像已选择',
        icon: 'success'
      })
    },
    fail: () => {
      uni.showToast({
        title: '选择头像失败',
        icon: 'none'
      })
    }
  })
}

const selectGender = (value: string) => {
  userInfo.value.gender = value
}

const onDateChange = (e: any) => {
  userInfo.value.birth_date = e.detail.value
}

const onThemeChange = (e: any) => {
  const index = e.detail.value
  themeIndex.value = index
  const themeMap = ['auto', 'light', 'dark']
  userInfo.value.theme_preference = themeMap[index]
}

const onNotificationChange = (e: any) => {
  userInfo.value.notification_enabled = e.detail.value
}

const onTimeChange = (e: any) => {
  userInfo.value.daily_reminder_time = e.detail.value
}

const onAnalyticsChange = (e: any) => {
  userInfo.value.analytics_consent = e.detail.value
}

const saveProfile = async () => {
  if (isSaving.value) return
  
  try {
    isSaving.value = true
    
    // 验证必填字段
    if (!userInfo.value.nickname.trim()) {
      uni.showToast({
        title: '请输入昵称',
        icon: 'none'
      })
      return
    }
    
    uni.showLoading({
      title: '保存中...'
    })
    
    // 调用API保存
    const response = await authAPI.updateProfile(userInfo.value)
    
    // 更新本地存储的用户信息
    const currentUser = getUser()
    if (currentUser) {
      const updatedUser = { ...currentUser, ...userInfo.value }
      setUser(updatedUser)
    }
    
    uni.hideLoading()
    uni.showToast({
      title: '保存成功',
      icon: 'success'
    })
    
    // 延迟返回上一页
    setTimeout(() => {
      uni.navigateBack()
    }, 1500)
    
  } catch (error: any) {
    uni.hideLoading()
    console.error('保存失败:', error)
    
    const errorMessage = error?.response?.data?.message || '保存失败，请重试'
    uni.showToast({
      title: errorMessage,
      icon: 'none'
    })
  } finally {
    isSaving.value = false
  }
}

// 生命周期
onMounted(() => {
  loadUserInfo()
})
</script>

<style scoped>
/* CSS变量定义 */
:root {
  --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  --glass-bg: rgba(255, 255, 255, 0.25);
  --glass-border: rgba(255, 255, 255, 0.18);
  --shadow-light: 0 8rpx 32rpx rgba(31, 38, 135, 0.37);
  --input-focus: #667eea;
}

.container {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  position: relative;
}

.container::before {
  content: '';
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: 
    radial-gradient(circle at 20% 80%, rgba(120, 119, 198, 0.3) 0%, transparent 50%),
    radial-gradient(circle at 80% 20%, rgba(255, 119, 198, 0.3) 0%, transparent 50%);
  pointer-events: none;
  z-index: 0;
}

.page-header {
  padding: 40rpx 30rpx 30rpx;
  position: relative;
  z-index: 1;
}

.header-content {
  text-align: center;
}

.page-title {
  font-size: 40rpx;
  font-weight: 700;
  color: #2d3748;
  display: block;
  margin-bottom: 10rpx;
}

.page-subtitle {
  font-size: 26rpx;
  color: #718096;
  font-weight: 500;
}

/* 毛玻璃卡片样式 */
.glass-card {
  background: var(--glass-bg);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid var(--glass-border);
  border-radius: 25rpx;
  box-shadow: var(--shadow-light);
  margin: 0 20rpx 30rpx;
  position: relative;
  z-index: 1;
  overflow: hidden;
}

.glass-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.1) 0%, rgba(255, 255, 255, 0.05) 100%);
  pointer-events: none;
}

/* 头像编辑区域 */
.avatar-section {
  padding: 40rpx;
  text-align: center;
}

.avatar-container {
  position: relative;
  width: 160rpx;
  height: 160rpx;
  margin: 0 auto 20rpx;
  cursor: pointer;
}

.avatar-image {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  border: 4rpx solid rgba(255, 255, 255, 0.8);
  position: relative;
  z-index: 2;
}

.avatar-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  border-radius: 50%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s ease;
  z-index: 3;
}

.avatar-container:active .avatar-overlay {
  opacity: 1;
}

.camera-icon {
  font-size: 40rpx;
  color: white;
  margin-bottom: 8rpx;
}

.change-text {
  font-size: 22rpx;
  color: white;
  font-weight: 500;
}

.avatar-glow {
  position: absolute;
  top: -10rpx;
  left: -10rpx;
  width: calc(100% + 20rpx);
  height: calc(100% + 20rpx);
  background: conic-gradient(from 0deg, #667eea, #764ba2, #667eea);
  border-radius: 50%;
  opacity: 0;
  animation: rotate 3s linear infinite;
  z-index: 1;
}

.avatar-container:active .avatar-glow {
  opacity: 0.6;
}

@keyframes rotate {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.avatar-tip {
  font-size: 24rpx;
  color: #718096;
  position: relative;
  z-index: 2;
}

/* 表单样式 */
.form-section,
.settings-section {
  padding: 30rpx;
}

.section-header {
  margin-bottom: 30rpx;
  position: relative;
  z-index: 2;
}

.section-title {
  font-size: 32rpx;
  font-weight: 700;
  color: #2d3748;
}

.form-group {
  margin-bottom: 40rpx;
  position: relative;
  z-index: 2;
}

.form-label {
  font-size: 28rpx;
  color: #4a5568;
  font-weight: 600;
  display: block;
  margin-bottom: 15rpx;
}

.form-input,
.form-textarea {
  width: 100%;
  padding: 20rpx 0;
  font-size: 28rpx;
  color: #2d3748;
  background: transparent;
  border: none;
  outline: none;
  position: relative;
  z-index: 2;
}

.form-textarea {
  min-height: 120rpx;
  resize: none;
}

.input-underline {
  height: 2rpx;
  background: linear-gradient(90deg, #e2e8f0, var(--input-focus), #e2e8f0);
  background-size: 200% 100%;
  background-position: 100% 0;
  transition: background-position 0.3s ease;
}

.form-input:focus + .input-underline,
.form-textarea:focus + .input-underline {
  background-position: 0 0;
}

.char-count {
  text-align: right;
  font-size: 22rpx;
  color: #a0aec0;
  margin-top: 8rpx;
}

/* 性别选择 */
.gender-options {
  display: flex;
  gap: 15rpx;
  flex-wrap: wrap;
}

.gender-option {
  flex: 1;
  min-width: 120rpx;
  padding: 20rpx;
  background: rgba(255, 255, 255, 0.4);
  border: 2rpx solid rgba(255, 255, 255, 0.2);
  border-radius: 15rpx;
  text-align: center;
  transition: all 0.3s ease;
  backdrop-filter: blur(10px);
}

.gender-option.active {
  background: rgba(102, 126, 234, 0.2);
  border-color: #667eea;
  transform: translateY(-2rpx);
}

.gender-icon {
  font-size: 32rpx;
  display: block;
  margin-bottom: 8rpx;
}

.gender-text {
  font-size: 24rpx;
  color: #4a5568;
  font-weight: 500;
}

/* 日期选择器 */
.date-picker {
  width: 100%;
}

.picker-display {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx 0;
}

.picker-text {
  font-size: 28rpx;
  color: #2d3748;
}

.picker-icon {
  font-size: 24rpx;
  color: #a0aec0;
}

/* 设置项样式 */
.setting-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 25rpx 0;
  border-bottom: 1rpx solid rgba(255, 255, 255, 0.1);
  position: relative;
  z-index: 2;
}

.setting-item:last-child {
  border-bottom: none;
}

.setting-info {
  display: flex;
  align-items: center;
  flex: 1;
}

.setting-icon {
  font-size: 32rpx;
  margin-right: 20rpx;
  width: 40rpx;
  text-align: center;
}

.setting-text {
  flex: 1;
}

.setting-name {
  font-size: 28rpx;
  color: #2d3748;
  font-weight: 600;
  display: block;
  margin-bottom: 5rpx;
}

.setting-desc {
  font-size: 22rpx;
  color: #718096;
}

.setting-value {
  display: flex;
  align-items: center;
  font-size: 26rpx;
  color: #667eea;
  font-weight: 500;
}

.arrow-icon {
  margin-left: 8rpx;
  font-size: 20rpx;
}

/* 保存按钮 */
.save-section {
  padding: 30rpx;
  position: relative;
  z-index: 1;
}

.save-button {
  width: 100%;
  height: 100rpx;
  background: var(--primary-gradient);
  border: none;
  border-radius: 25rpx;
  box-shadow: 0 12rpx 40rpx rgba(102, 126, 234, 0.4);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.save-button:active {
  transform: translateY(2rpx);
  box-shadow: 0 8rpx 25rpx rgba(102, 126, 234, 0.6);
}

.save-button:disabled {
  opacity: 0.7;
  transform: none;
}

.button-content {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  position: relative;
  z-index: 2;
}

.save-icon {
  font-size: 32rpx;
  margin-right: 12rpx;
}

.save-text {
  font-size: 32rpx;
  color: white;
  font-weight: 600;
}

.loading-spinner {
  width: 32rpx;
  height: 32rpx;
  border: 3rpx solid rgba(255, 255, 255, 0.3);
  border-top: 3rpx solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-right: 12rpx;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style> 