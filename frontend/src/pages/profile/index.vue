<template>
  <view class="container">
    <!-- 用户信息卡片 -->
    <view class="user-card">
      <view class="user-avatar" @click="changeAvatar">
        <image class="avatar-image" :src="userInfo.avatar" mode="aspectFill" />
        <view class="avatar-edit">
          <text class="edit-icon">📷</text>
        </view>
      </view>
      <view class="user-info">
        <text class="username">{{ userInfo.nickname }}</text>
        <text class="user-desc">{{ userInfo.description }}</text>
        <text class="join-date">加入时间: {{ formatDate(userInfo.joinDate) }}</text>
      </view>
      <view class="edit-profile" @click="editProfile">
        <text class="edit-text">编辑</text>
      </view>
    </view>

    <!-- 数据概览 -->
    <view class="data-overview">
      <view class="overview-item">
        <text class="overview-number">{{ userStats.totalDays }}</text>
        <text class="overview-label">记录天数</text>
      </view>
      <view class="overview-item">
        <text class="overview-number">{{ userStats.totalRecords }}</text>
        <text class="overview-label">总记录数</text>
      </view>
      <view class="overview-item">
        <text class="overview-number">{{ userStats.averageMood }}</text>
        <text class="overview-label">平均心情</text>
      </view>
      <view class="overview-item">
        <text class="overview-number">{{ userStats.streakDays }}</text>
        <text class="overview-label">连续天数</text>
      </view>
    </view>

    <!-- 功能菜单 -->
    <view class="menu-section">
      <view class="menu-group">
        <text class="group-title">数据管理</text>
        <view class="menu-item" @click="exportData">
          <view class="menu-icon">📊</view>
          <text class="menu-text">导出数据</text>
          <text class="menu-arrow">></text>
        </view>
        <view class="menu-item" @click="backupData">
          <view class="menu-icon">☁️</view>
          <text class="menu-text">云端备份</text>
          <view class="menu-badge" v-if="backupStatus === 'synced'">已同步</view>
          <text class="menu-arrow">></text>
        </view>
        <view class="menu-item" @click="importData">
          <view class="menu-icon">📥</view>
          <text class="menu-text">导入数据</text>
          <text class="menu-arrow">></text>
        </view>
      </view>

      <view class="menu-group">
        <text class="group-title">个性化设置</text>
        <view class="menu-item" @click="themeSettings">
          <view class="menu-icon">🎨</view>
          <text class="menu-text">主题设置</text>
          <text class="menu-value">{{ currentTheme }}</text>
          <text class="menu-arrow">></text>
        </view>
        <view class="menu-item" @click="reminderSettings">
          <view class="menu-icon">⏰</view>
          <text class="menu-text">提醒设置</text>
          <switch 
            :checked="reminderEnabled" 
            @change="toggleReminder"
            color="#4A90E2"
          />
        </view>
        <view class="menu-item" @click="privacySettings">
          <view class="menu-icon">🔒</view>
          <text class="menu-text">隐私设置</text>
          <text class="menu-arrow">></text>
        </view>
      </view>

      <view class="menu-group">
        <text class="group-title">AI功能</text>
        <view class="menu-item" @click="aiSettings">
          <view class="menu-icon">🤖</view>
          <text class="menu-text">AI分析设置</text>
          <text class="menu-arrow">></text>
        </view>
        <view class="menu-item" @click="voiceSettings">
          <view class="menu-icon">🎤</view>
          <text class="menu-text">语音识别</text>
          <switch 
            :checked="voiceEnabled" 
            @change="toggleVoice"
            color="#4A90E2"
          />
        </view>
        <view class="menu-item" @click="analysisHistory">
          <view class="menu-icon">📈</view>
          <text class="menu-text">分析历史</text>
          <text class="menu-arrow">></text>
        </view>
      </view>

      <view class="menu-group">
        <text class="group-title">帮助与支持</text>
        <view class="menu-item" @click="userGuide">
          <view class="menu-icon">📖</view>
          <text class="menu-text">使用指南</text>
          <text class="menu-arrow">></text>
        </view>
        <view class="menu-item" @click="feedback">
          <view class="menu-icon">💬</view>
          <text class="menu-text">意见反馈</text>
          <text class="menu-arrow">></text>
        </view>
        <view class="menu-item" @click="aboutApp">
          <view class="menu-icon">ℹ️</view>
          <text class="menu-text">关于应用</text>
          <text class="menu-value">v1.0.0</text>
          <text class="menu-arrow">></text>
        </view>
      </view>
    </view>

    <!-- 成就展示 -->
    <view class="achievements-preview">
      <view class="preview-header">
        <text class="preview-title">最新成就</text>
        <text class="view-all" @click="viewAllAchievements">查看全部 ></text>
      </view>
      <scroll-view class="achievements-scroll" scroll-x="true">
        <view 
          class="achievement-item" 
          v-for="achievement in recentAchievements" 
          :key="achievement.id"
        >
          <text class="achievement-icon">{{ achievement.icon }}</text>
          <text class="achievement-name">{{ achievement.name }}</text>
        </view>
      </scroll-view>
    </view>

    <!-- 退出登录 -->
    <view class="logout-section">
      <button class="logout-button" @click="logout">
        退出登录
      </button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

// 响应式数据
const userInfo = ref({
  nickname: '小明',
  description: '记录生活，感受美好',
  avatar: '/static/default-avatar.png',
  joinDate: '2024-01-01'
})

const userStats = ref({
  totalDays: 28,
  totalRecords: 56,
  averageMood: 6.8,
  streakDays: 7
})

const backupStatus = ref('synced') // synced, syncing, error
const currentTheme = ref('浅色')
const reminderEnabled = ref(true)
const voiceEnabled = ref(false)

const recentAchievements = ref([
  { id: 1, name: '坚持者', icon: '🔥' },
  { id: 2, name: '探索者', icon: '🔍' },
  { id: 3, name: '分析师', icon: '📊' }
])

// 方法
const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()
  return `${year}年${month}月${day}日`
}

const changeAvatar = () => {
  uni.chooseImage({
    count: 1,
    sizeType: ['compressed'],
    sourceType: ['album', 'camera'],
    success: (res) => {
      userInfo.value.avatar = res.tempFilePaths[0]
      uni.showToast({
        title: '头像更新成功',
        icon: 'success'
      })
    }
  })
}

const editProfile = () => {
  uni.navigateTo({
    url: '/pages/profile/edit'
  })
}

const exportData = () => {
  uni.showActionSheet({
    itemList: ['导出为JSON', '导出为CSV', '导出为PDF'],
    success: (res) => {
      const formats = ['JSON', 'CSV', 'PDF']
      uni.showToast({
        title: `导出${formats[res.tapIndex]}中...`,
        icon: 'loading'
      })
      
      setTimeout(() => {
        uni.showToast({
          title: '导出成功',
          icon: 'success'
        })
      }, 2000)
    }
  })
}

const backupData = () => {
  if (backupStatus.value === 'syncing') return
  
  backupStatus.value = 'syncing'
  uni.showToast({
    title: '备份中...',
    icon: 'loading'
  })
  
  setTimeout(() => {
    backupStatus.value = 'synced'
    uni.showToast({
      title: '备份成功',
      icon: 'success'
    })
  }, 3000)
}

const importData = () => {
  uni.chooseFile({
    count: 1,
    extension: ['.json', '.csv'],
    success: (res) => {
      uni.showToast({
        title: '导入成功',
        icon: 'success'
      })
    }
  })
}

const themeSettings = () => {
  uni.showActionSheet({
    itemList: ['浅色主题', '深色主题', '跟随系统'],
    success: (res) => {
      const themes = ['浅色', '深色', '跟随系统']
      currentTheme.value = themes[res.tapIndex]
      uni.showToast({
        title: `已切换到${themes[res.tapIndex]}主题`,
        icon: 'success'
      })
    }
  })
}

const reminderSettings = () => {
  uni.navigateTo({
    url: '/pages/settings/reminder'
  })
}

const toggleReminder = (e: any) => {
  reminderEnabled.value = e.detail.value
  const message = reminderEnabled.value ? '已开启提醒' : '已关闭提醒'
  uni.showToast({
    title: message,
    icon: 'success'
  })
}

const privacySettings = () => {
  uni.navigateTo({
    url: '/pages/settings/privacy'
  })
}

const aiSettings = () => {
  uni.navigateTo({
    url: '/pages/settings/ai'
  })
}

const toggleVoice = (e: any) => {
  voiceEnabled.value = e.detail.value
  const message = voiceEnabled.value ? '已开启语音识别' : '已关闭语音识别'
  uni.showToast({
    title: message,
    icon: 'success'
  })
}

const analysisHistory = () => {
  uni.navigateTo({
    url: '/pages/analysis/history'
  })
}

const voiceSettings = () => {
  uni.navigateTo({
    url: '/pages/settings/voice'
  })
}

const userGuide = () => {
  uni.navigateTo({
    url: '/pages/help/guide'
  })
}

const feedback = () => {
  uni.navigateTo({
    url: '/pages/help/feedback'
  })
}

const aboutApp = () => {
  uni.showModal({
    title: '关于心晴日记',
    content: '版本: v1.0.0\n一款AI驱动的情绪记录应用\n帮助你更好地了解和管理情绪',
    showCancel: false
  })
}

const viewAllAchievements = () => {
  uni.navigateTo({
    url: '/pages/achievements/index'
  })
}

const logout = () => {
  uni.showModal({
    title: '确认退出',
    content: '退出登录后需要重新登录才能使用',
    success: (res) => {
      if (res.confirm) {
        // 清除用户数据
        uni.clearStorageSync()
        uni.showToast({
          title: '已退出登录',
          icon: 'success'
        })
        
        // 跳转到登录页面
        setTimeout(() => {
          uni.reLaunch({
            url: '/pages/login/index'
          })
        }, 1500)
      }
    }
  })
}

// 生命周期
onMounted(() => {
  // 加载用户信息和统计数据
  console.log('加载个人中心数据')
})
</script>

<style scoped>
/* 页面特定变量（继承全局变量） */
.container {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  padding: 0 30rpx 120rpx;
  position: relative;
}

/* 用户信息卡片 - 现代化设计 */
.user-card {
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  padding: 50rpx 40rpx;
  margin: 30rpx 0;
  box-shadow: var(--shadow-medium);
  display: flex;
  align-items: center;
  position: relative;
  overflow: hidden;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.user-card:hover {
  transform: translateY(-4rpx);
  box-shadow: var(--shadow-heavy);
}

.user-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 6rpx;
  background: var(--primary-gradient);
  border-radius: 25rpx 25rpx 0 0;
}

.user-avatar {
  position: relative;
  margin-right: 30rpx;
}

.avatar-image {
  width: 140rpx;
  height: 140rpx;
  border-radius: 50%;
  border: 6rpx solid rgba(255, 255, 255, 0.3);
  box-shadow: 0 8rpx 32rpx rgba(0, 0, 0, 0.15);
  transition: all 0.3s ease;
}

.user-avatar:hover .avatar-image {
  transform: scale(1.05);
  box-shadow: 0 12rpx 48rpx rgba(0, 0, 0, 0.2);
}

.avatar-edit {
  position: absolute;
  bottom: 5rpx;
  right: 5rpx;
  width: 45rpx;
  height: 45rpx;
  background: var(--primary-gradient);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.2);
  transition: all 0.3s ease;
}

.avatar-edit:hover {
  transform: scale(1.1);
  box-shadow: 0 6rpx 24rpx rgba(0, 0, 0, 0.3);
}

.edit-icon {
  font-size: 24rpx;
  color: white;
}

.user-info {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.username {
  font-size: 42rpx;
  font-weight: 700;
  margin-bottom: 12rpx;
  background: var(--primary-gradient);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  color: var(--text-primary);
}

.user-desc {
  font-size: 28rpx;
  color: var(--text-secondary);
  margin-bottom: 12rpx;
  opacity: 0.9;
}

.join-date {
  font-size: 24rpx;
  color: var(--text-placeholder);
  opacity: 0.8;
}

.edit-profile {
  padding: 20rpx 30rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(10rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.edit-profile::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.5s ease;
}

.edit-profile:hover::before {
  left: 100%;
}

.edit-profile:hover {
  transform: translateY(-2rpx);
  box-shadow: 0 8rpx 32rpx rgba(0, 0, 0, 0.15);
}

.edit-text {
  font-size: 26rpx;
  color: var(--text-primary);
  font-weight: 600;
}

/* 数据概览 - 现代化网格 */
.data-overview {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 25rpx;
  margin-bottom: 40rpx;
}

.overview-item {
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  padding: 40rpx 30rpx;
  text-align: center;
  box-shadow: var(--shadow-light);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.overview-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4rpx;
  background: var(--primary-gradient);
  transform: scaleX(0);
  transition: transform 0.3s ease;
}

.overview-item:hover {
  transform: translateY(-6rpx);
  box-shadow: var(--shadow-medium);
}

.overview-item:hover::before {
  transform: scaleX(1);
}

.overview-number {
  font-size: 52rpx;
  font-weight: 800;
  background: var(--primary-gradient);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  color: var(--primary-color);
  display: block;
  margin-bottom: 12rpx;
  animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.8; }
}

.overview-label {
  font-size: 26rpx;
  color: var(--text-secondary);
  font-weight: 500;
}

/* 功能菜单 - 现代化卡片 */
.menu-section {
  margin-bottom: 40rpx;
}

.menu-group {
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  margin-bottom: 30rpx;
  overflow: hidden;
  box-shadow: var(--shadow-light);
  transition: all 0.3s ease;
}

.menu-group:hover {
  transform: translateY(-2rpx);
  box-shadow: var(--shadow-medium);
}

.group-title {
  font-size: 28rpx;
  color: var(--text-primary);
  padding: 30rpx 40rpx 20rpx;
  font-weight: 700;
  display: block;
  background: var(--primary-gradient);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  position: relative;
}

.group-title::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 40rpx;
  right: 40rpx;
  height: 2rpx;
  background: var(--primary-gradient);
  opacity: 0.3;
}

.menu-item {
  display: flex;
  align-items: center;
  padding: 30rpx 40rpx;
  border-bottom: 1rpx solid rgba(255, 255, 255, 0.1);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.menu-item:last-child {
  border-bottom: none;
}

.menu-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.1), transparent);
  transition: left 0.5s ease;
}

.menu-item:hover::before {
  left: 100%;
}

.menu-item:hover {
  background: rgba(255, 255, 255, 0.1);
  transform: translateX(8rpx);
}

.menu-item:active {
  transform: translateX(4rpx) scale(0.98);
}

.menu-icon {
  font-size: 36rpx;
  margin-right: 25rpx;
  width: 50rpx;
  text-align: center;
  filter: drop-shadow(0 2rpx 8rpx rgba(0, 0, 0, 0.1));
}

.menu-text {
  flex: 1;
  font-size: 30rpx;
  color: var(--text-primary);
  font-weight: 500;
}

.menu-value {
  font-size: 26rpx;
  color: var(--text-secondary);
  margin-right: 15rpx;
  padding: 8rpx 16rpx;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 15rpx;
  font-weight: 500;
}

.menu-badge {
  background: var(--success-gradient);
  color: white;
  padding: 8rpx 16rpx;
  border-radius: 20rpx;
  font-size: 22rpx;
  margin-right: 15rpx;
  font-weight: 600;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.15);
  animation: glow 2s ease-in-out infinite alternate;
}

@keyframes glow {
  from { box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.15); }
  to { box-shadow: 0 4rpx 20rpx rgba(76, 175, 80, 0.3); }
}

.menu-arrow {
  font-size: 28rpx;
  color: var(--text-placeholder);
  transition: all 0.3s ease;
}

.menu-item:hover .menu-arrow {
  transform: translateX(4rpx);
  color: var(--primary-color);
}

/* 成就展示 - 现代化预览 */
.achievements-preview {
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  padding: 40rpx;
  margin-bottom: 40rpx;
  box-shadow: var(--shadow-light);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.achievements-preview::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 6rpx;
  background: var(--warning-gradient);
  border-radius: 25rpx 25rpx 0 0;
}

.achievements-preview:hover {
  transform: translateY(-4rpx);
  box-shadow: var(--shadow-medium);
}

.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30rpx;
}

.preview-title {
  font-size: 36rpx;
  font-weight: 700;
  background: var(--warning-gradient);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  color: var(--text-primary);
}

.view-all {
  font-size: 26rpx;
  color: var(--primary-color);
  font-weight: 600;
  padding: 12rpx 20rpx;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 20rpx;
  transition: all 0.3s ease;
}

.view-all:hover {
  background: var(--primary-color);
  color: white;
  transform: translateY(-2rpx);
}

.achievements-scroll {
  white-space: nowrap;
}

.achievement-item {
  display: inline-flex;
  flex-direction: column;
  align-items: center;
  padding: 25rpx 20rpx;
  margin-right: 20rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(10rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 20rpx;
  min-width: 140rpx;
  box-shadow: var(--shadow-light);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.achievement-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3rpx;
  background: var(--warning-gradient);
  transform: scaleX(0);
  transition: transform 0.3s ease;
}

.achievement-item:hover {
  transform: translateY(-6rpx) scale(1.05);
  box-shadow: var(--shadow-medium);
}

.achievement-item:hover::before {
  transform: scaleX(1);
}

.achievement-icon {
  font-size: 48rpx;
  margin-bottom: 12rpx;
  filter: drop-shadow(0 4rpx 12rpx rgba(0, 0, 0, 0.15));
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0rpx); }
  50% { transform: translateY(-6rpx); }
}

.achievement-name {
  font-size: 24rpx;
  color: var(--text-secondary);
  text-align: center;
  font-weight: 600;
}

/* 退出登录 - 现代化按钮 */
.logout-section {
  padding: 40rpx 0;
}

.logout-button {
  width: 100%;
  height: 90rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  color: var(--error-color);
  border: 2rpx solid var(--error-color);
  border-radius: 25rpx;
  font-size: 30rpx;
  font-weight: 600;
  box-shadow: var(--shadow-light);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.logout-button::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: var(--error-color);
  transition: left 0.3s ease;
  z-index: -1;
}

.logout-button:hover::before {
  left: 0;
}

.logout-button:hover {
  color: white;
  transform: translateY(-4rpx);
  box-shadow: var(--shadow-medium);
}

.logout-button:active {
  transform: translateY(-2rpx) scale(0.98);
}

/* 深色模式特定样式调整 */
@media (prefers-color-scheme: dark) {
  .container {
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
  }
  
  .username {
    color: var(--text-primary);
  }
  
  .preview-title {
    color: var(--text-primary);
  }
}
</style> 