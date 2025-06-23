<template>
  <view class="container">
    <!-- 顶部欢迎区域 -->
    <view class="welcome-section">
      <view class="welcome-background"></view>
      <view class="welcome-content">
        <view class="greeting">
          <text class="greeting-text">{{ greetingText }}，</text>
          <text class="username">{{ username || '用户' }}</text>
          <text class="greeting-emoji">{{ greetingEmoji }}</text>
        </view>
        <view class="date-info">
          <text class="date">{{ currentDate }}</text>
          <view class="weather-info" v-if="weatherInfo">
            <text class="weather-icon">{{ weatherInfo.icon }}</text>
            <text class="weather-text">{{ weatherInfo.desc }}</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 今日情绪概览卡片 -->
    <view class="emotion-overview-card glass-card">
      <view class="card-header">
        <view class="card-title-section">
          <text class="card-title">今日情绪</text>
          <view class="emotion-pulse" v-if="todayEmotion"></view>
        </view>
        <text class="view-more" @click="goToStatistics">
          <text>查看详情</text>
          <text class="arrow-icon">→</text>
        </text>
      </view>
      <view class="emotion-display" v-if="todayEmotion">
        <view class="emotion-visual">
          <view class="emotion-icon-container">
            <view class="emotion-glow"></view>
            <text class="emotion-icon">{{ todayEmotion.icon }}</text>
          </view>
          <view class="emotion-spectrum">
            <view class="spectrum-bar">
              <view 
                class="spectrum-fill" 
                :style="{ width: (todayEmotion.intensity * 10) + '%' }"
              ></view>
            </view>
            <text class="intensity-text">{{ todayEmotion.intensity }}/10</text>
          </view>
        </view>
        <view class="emotion-details">
          <text class="emotion-name">{{ todayEmotion.name }}</text>
          <view class="emotion-meta">
            <view class="meta-item">
              <text class="meta-icon">📍</text>
              <text class="meta-text">{{ todayEmotion.scene }}</text>
            </view>
            <view class="meta-item">
              <text class="meta-icon">⏰</text>
              <text class="meta-text">{{ todayEmotion.time }}</text>
            </view>
          </view>
        </view>
      </view>
      <view class="no-emotion" v-else>
        <view class="empty-state">
          <text class="empty-icon">🌱</text>
          <text class="no-emotion-text">今天还没有记录情绪哦</text>
          <text class="encourage-text">开始记录，让心情有迹可循</text>
          <view class="start-button" @click="goToRecord">
            <text>开始记录</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 快速记录区域 -->
    <view class="quick-record-section glass-card">
      <view class="section-header">
        <text class="section-title">快速记录</text>
        <text class="section-subtitle">轻点记录当下心情</text>
      </view>
      <view class="emotion-grid">
        <view 
          class="emotion-card" 
          v-for="emotion in quickEmotions" 
          :key="emotion.name"
          @click="quickRecord(emotion)"
        >
          <view class="card-glow" :class="emotion.type"></view>
          <text class="emotion-icon">{{ emotion.icon }}</text>
          <text class="emotion-name">{{ emotion.name }}</text>
          <view class="emotion-ripple"></view>
        </view>
      </view>
    </view>

    <!-- 最近记录 -->
    <view class="recent-records glass-card" v-if="recentRecords.length > 0">
      <view class="section-header">
        <text class="section-title">最近记录</text>
        <text class="view-more" @click="goToStatistics">
          <text>查看全部</text>
          <text class="arrow-icon">→</text>
        </text>
      </view>
      <view class="timeline">
        <view 
          class="timeline-item" 
          v-for="(record, index) in recentRecords" 
          :key="record.id"
          @click="viewRecord(record)"
        >
          <view class="timeline-dot">
            <text class="record-emotion">{{ record.emotion }}</text>
          </view>
          <view class="timeline-content">
            <view class="record-header">
              <text class="record-name">{{ record.name }}</text>
              <text class="record-time">{{ record.time }}</text>
            </view>
            <text class="record-content">{{ record.content }}</text>
          </view>
          <view class="timeline-line" v-if="index < recentRecords.length - 1"></view>
        </view>
      </view>
    </view>

    <!-- 浮动记录按钮 -->
    <view class="floating-button" @click="goToRecord">
      <view class="button-glow"></view>
      <text class="plus-icon">+</text>
      <view class="button-ripple"></view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { emotionAPI, authAPI, getToken, getUser } from '../../utils/api'

// 类型定义
interface EmotionType {
  name: string
  icon: string
  type: string
}

interface TodayEmotionType {
  name: string
  icon: string
  intensity: number
  scene: string
  time: string
}

interface RecentRecord {
  id: number
  emotion: string
  name: string
  time: string
  content: string
}

interface WeatherInfo {
  icon: string
  desc: string
}

interface UserType {
  nickname?: string
  username: string
}

// 响应式数据
const username = ref('小明')
const todayEmotion = ref<TodayEmotionType | null>(null)
const recentRecords = ref<RecentRecord[]>([])
const isLoading = ref(true)
const user = ref<UserType | null>(null)
const weatherInfo = ref<WeatherInfo | null>({
  icon: '☀️',
  desc: '晴朗'
})

// 快速记录情绪选项
const quickEmotions = ref<EmotionType[]>([
  { name: '快乐', icon: '😄', type: 'happy' },
  { name: '平静', icon: '😌', type: 'calm' },
  { name: '焦虑', icon: '😟', type: 'anxious' },
  { name: '悲伤', icon: '😢', type: 'sad' },
  { name: '愤怒', icon: '😡', type: 'angry' },
  { name: '恐惧', icon: '😨', type: 'fearful' }
])

// 计算属性
const greetingText = computed(() => {
  const hour = new Date().getHours()
  if (hour < 6) return '夜深了'
  if (hour < 12) return '早上好'
  if (hour < 18) return '下午好'
  return '晚上好'
})

const greetingEmoji = computed(() => {
  const hour = new Date().getHours()
  if (hour < 6) return '🌙'
  if (hour < 12) return '🌅'
  if (hour < 18) return '☀️'
  return '🌆'
})

const currentDate = computed(() => {
  const now = new Date()
  const month = now.getMonth() + 1
  const date = now.getDate()
  const weekdays = ['日', '一', '二', '三', '四', '五', '六']
  const weekday = weekdays[now.getDay()]
  return `${month}月${date}日 星期${weekday}`
})

// 方法
const goToRecord = () => {
  uni.switchTab({
    url: '/pages/record/index'
  })
}

const goToStatistics = () => {
  uni.switchTab({
    url: '/pages/statistics/index'
  })
}

const quickRecord = async (emotion: EmotionType) => {
  try {
    uni.showLoading({
      title: '记录中...'
    })
    
    // 快速记录情绪
    const recordData = {
      emotion_type: emotion.type,
      intensity: 5, // 默认强度
      scenario: 'personal',
      description: `快速记录${emotion.name}情绪`,
      triggers: ['快速记录'],
      physical_symptoms: [],
      coping_methods: []
    }
    
    await emotionAPI.createRecord(recordData)
    
    uni.hideLoading()
    uni.showToast({
      title: `${emotion.name}情绪记录成功`,
      icon: 'success'
    })
    
    // 重新加载数据
    await loadData()
    
  } catch (error) {
    uni.hideLoading()
    console.error('快速记录失败:', error)
    uni.showToast({
      title: '记录失败，请重试',
      icon: 'none'
    })
  }
}

const viewRecord = (record: RecentRecord) => {
  uni.navigateTo({
    url: `/pages/analysis/index?recordId=${record.id}`
  })
}

const formatTime = (timestamp: string | number) => {
  const date = new Date(timestamp)
  const hour = date.getHours().toString().padStart(2, '0')
  const minute = date.getMinutes().toString().padStart(2, '0')
  return `${hour}:${minute}`
}

// 检查认证状态并加载数据
const checkAuthAndLoadData = async () => {
  const token = getToken()
  if (!token) {
    // 没有token，跳转到登录页
    uni.navigateTo({
      url: '/pages/login/index'
    })
    return
  }
  
  user.value = getUser()
  if (user.value) {
    username.value = user.value.nickname || user.value.username
  }
  
  await loadData()
}

// 加载数据
const loadData = async () => {
  isLoading.value = true
  
  try {
    // 并行加载多个数据
    const [todayRecords, recentRecordsData] = await Promise.all([
      emotionAPI.getTodayRecords(),
      emotionAPI.getRecentRecords()
    ])
    
    // 处理今日记录
    if (todayRecords && todayRecords.length > 0) {
      const latestRecord = todayRecords[0]
      todayEmotion.value = {
        name: getEmotionDisplayName(latestRecord.emotion_type),
        icon: getEmotionIcon(latestRecord.emotion_type),
        intensity: latestRecord.intensity,
        scene: getScenarioDisplayName(latestRecord.scenario),
        time: formatTime(latestRecord.emotion_time)
      }
    } else {
      todayEmotion.value = null
    }
    
    // 处理最近记录
    recentRecords.value = recentRecordsData.slice(0, 3).map((record: any) => ({
      id: record.id,
      emotion: getEmotionIcon(record.emotion_type),
      name: getEmotionDisplayName(record.emotion_type),
      time: formatTime(record.emotion_time),
      content: record.description.length > 30 ? 
               record.description.substring(0, 30) + '...' : 
               record.description
    }))
    
  } catch (error: any) {
    console.error('加载数据失败:', error)
    uni.showToast({
      title: '数据加载失败',
      icon: 'none'
    })
    
    // 如果是认证错误，跳转到登录页
    if (error?.message === 'Unauthorized') {
      uni.navigateTo({
        url: '/pages/login/index'
      })
    }
  } finally {
    isLoading.value = false
  }
}

// 获取情绪类型的中文显示名称
const getEmotionDisplayName = (emotionType: string) => {
  const emotionMap: Record<string, string> = {
    'happy': '快乐',
    'sad': '悲伤',
    'angry': '愤怒',
    'anxious': '焦虑',
    'calm': '平静',
    'fearful': '恐惧',
    'excited': '兴奋',
    'frustrated': '沮丧',
    'grateful': '感激',
    'lonely': '孤独',
    'confident': '自信',
    'overwhelmed': '不知所措'
  }
  return emotionMap[emotionType] || emotionType
}

// 获取情绪图标
const getEmotionIcon = (emotionType: string) => {
  const iconMap: Record<string, string> = {
    'happy': '😊',
    'sad': '😢',
    'angry': '😠',
    'anxious': '😰',
    'calm': '😌',
    'fearful': '😨',
    'excited': '🤩',
    'frustrated': '😤',
    'grateful': '🙏',
    'lonely': '😔',
    'confident': '😎',
    'overwhelmed': '🤯'
  }
  return iconMap[emotionType] || '😊'
}

// 获取场景显示名称
const getScenarioDisplayName = (scenario: string) => {
  const scenarioMap: Record<string, string> = {
    'work': '工作',
    'study': '学习',
    'family': '家庭',
    'social': '社交',
    'health': '健康',
    'finance': '财务',
    'relationship': '感情',
    'personal': '个人',
    'entertainment': '娱乐',
    'travel': '旅行',
    'other': '其他'
  }
  return scenarioMap[scenario] || scenario
}

// 生命周期
onMounted(() => {
  checkAuthAndLoadData()
})
</script>

<style scoped>
/* CSS变量定义 */
:root {
  --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  --secondary-gradient: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  --success-gradient: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  --glass-bg: rgba(255, 255, 255, 0.25);
  --glass-border: rgba(255, 255, 255, 0.18);
  --shadow-light: 0 8rpx 32rpx rgba(31, 38, 135, 0.37);
  --shadow-card: 0 4rpx 20rpx rgba(0, 0, 0, 0.08);
}

.container {
  padding: 0;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  min-height: 100vh;
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

.welcome-section {
  position: relative;
  margin: 0 20rpx 30rpx;
  border-radius: 25rpx;
  overflow: hidden;
  z-index: 1;
}

.welcome-background {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: var(--primary-gradient);
  opacity: 0.9;
}

.welcome-background::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grain" width="100" height="100" patternUnits="userSpaceOnUse"><circle cx="25" cy="25" r="1" fill="white" opacity="0.1"/><circle cx="75" cy="75" r="1" fill="white" opacity="0.1"/></pattern></defs><rect width="100" height="100" fill="url(%23grain)"/></svg>');
}

.welcome-content {
  position: relative;
  padding: 40rpx 30rpx;
  color: white;
  z-index: 2;
}

.greeting {
  display: flex;
  align-items: center;
  margin-bottom: 15rpx;
  flex-wrap: wrap;
}

.greeting-text {
  font-size: 32rpx;
  margin-right: 8rpx;
  font-weight: 500;
}

.username {
  font-size: 36rpx;
  font-weight: 700;
  margin-right: 10rpx;
  background: linear-gradient(45deg, #fff, #f0f8ff);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.greeting-emoji {
  font-size: 32rpx;
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-5px); }
}

.date-info {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.date-info .date {
  font-size: 28rpx;
  opacity: 0.9;
  font-weight: 500;
}

.weather-info {
  display: flex;
  align-items: center;
  background: rgba(255, 255, 255, 0.2);
  padding: 8rpx 15rpx;
  border-radius: 20rpx;
  backdrop-filter: blur(10px);
}

.weather-icon {
  font-size: 24rpx;
  margin-right: 8rpx;
}

.weather-text {
  font-size: 22rpx;
  opacity: 0.9;
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
}

.emotion-overview-card {
  padding: 30rpx;
  overflow: hidden;
}

.emotion-overview-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.1) 0%, rgba(255, 255, 255, 0.05) 100%);
  pointer-events: none;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25rpx;
  position: relative;
  z-index: 2;
}

.card-title-section {
  display: flex;
  align-items: center;
}

.card-title {
  font-size: 32rpx;
  font-weight: 700;
  color: #2d3748;
  margin-right: 15rpx;
}

.emotion-pulse {
  width: 12rpx;
  height: 12rpx;
  background: #48bb78;
  border-radius: 50%;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0% {
    transform: scale(0.95);
    box-shadow: 0 0 0 0 rgba(72, 187, 120, 0.7);
  }
  70% {
    transform: scale(1);
    box-shadow: 0 0 0 10rpx rgba(72, 187, 120, 0);
  }
  100% {
    transform: scale(0.95);
    box-shadow: 0 0 0 0 rgba(72, 187, 120, 0);
  }
}

.view-more {
  display: flex;
  align-items: center;
  font-size: 26rpx;
  color: #667eea;
  font-weight: 600;
  transition: all 0.3s ease;
}

.view-more:active {
  transform: scale(0.95);
}

.arrow-icon {
  margin-left: 8rpx;
  transition: transform 0.3s ease;
}

.view-more:active .arrow-icon {
  transform: translateX(5rpx);
}

.emotion-display {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
  position: relative;
  z-index: 2;
}

.emotion-visual {
  display: flex;
  align-items: center;
  gap: 25rpx;
}

.emotion-icon-container {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.emotion-glow {
  position: absolute;
  width: 80rpx;
  height: 80rpx;
  background: radial-gradient(circle, rgba(102, 126, 234, 0.3) 0%, transparent 70%);
  border-radius: 50%;
  animation: glow 3s ease-in-out infinite alternate;
}

@keyframes glow {
  from { transform: scale(0.8); opacity: 0.5; }
  to { transform: scale(1.2); opacity: 0.8; }
}

.emotion-icon {
  font-size: 60rpx;
  position: relative;
  z-index: 2;
  filter: drop-shadow(0 4rpx 8rpx rgba(0, 0, 0, 0.1));
}

.emotion-spectrum {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 10rpx;
}

.spectrum-bar {
  height: 8rpx;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 10rpx;
  overflow: hidden;
  position: relative;
}

.spectrum-fill {
  height: 100%;
  background: linear-gradient(90deg, #48bb78, #38a169, #2f855a);
  border-radius: 10rpx;
  transition: width 1s ease-out;
  position: relative;
}

.spectrum-fill::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
  animation: shimmer 2s infinite;
}

@keyframes shimmer {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

.intensity-text {
  font-size: 24rpx;
  color: #4a5568;
  font-weight: 600;
  align-self: flex-end;
}

.emotion-details {
  display: flex;
  flex-direction: column;
  gap: 15rpx;
}

.emotion-name {
  font-size: 36rpx;
  font-weight: 700;
  color: #2d3748;
  text-shadow: 0 2rpx 4rpx rgba(0, 0, 0, 0.1);
}

.emotion-meta {
  display: flex;
  gap: 20rpx;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 8rpx;
  padding: 8rpx 15rpx;
  background: rgba(255, 255, 255, 0.4);
  border-radius: 20rpx;
  backdrop-filter: blur(10px);
}

.meta-icon {
  font-size: 20rpx;
}

.meta-text {
  font-size: 24rpx;
  color: #4a5568;
  font-weight: 500;
}

.no-emotion {
  position: relative;
  z-index: 2;
}

.empty-state {
  text-align: center;
  padding: 50rpx 30rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20rpx;
}

.empty-icon {
  font-size: 80rpx;
  opacity: 0.6;
  animation: float 3s ease-in-out infinite;
}

.no-emotion-text {
  font-size: 30rpx;
  color: #4a5568;
  font-weight: 600;
}

.encourage-text {
  font-size: 26rpx;
  color: #718096;
  margin-bottom: 20rpx;
}

.start-button {
  padding: 15rpx 40rpx;
  background: var(--success-gradient);
  color: white;
  border-radius: 25rpx;
  font-size: 28rpx;
  font-weight: 600;
  box-shadow: 0 8rpx 20rpx rgba(79, 172, 254, 0.3);
  transition: all 0.3s ease;
}

.start-button:active {
  transform: translateY(2rpx);
  box-shadow: 0 4rpx 12rpx rgba(79, 172, 254, 0.4);
}

.quick-record-section {
  padding: 30rpx;
  overflow: hidden;
}

.quick-record-section::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.15) 0%, rgba(255, 255, 255, 0.05) 100%);
  pointer-events: none;
}

.section-header {
  display: flex;
  flex-direction: column;
  gap: 8rpx;
  margin-bottom: 25rpx;
  position: relative;
  z-index: 2;
}

.section-title {
  font-size: 32rpx;
  font-weight: 700;
  color: #2d3748;
}

.section-subtitle {
  font-size: 24rpx;
  color: #718096;
  font-weight: 500;
}

.emotion-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20rpx;
  position: relative;
  z-index: 2;
}

.emotion-card {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 25rpx 15rpx;
  background: rgba(255, 255, 255, 0.4);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 20rpx;
  backdrop-filter: blur(10px);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  overflow: hidden;
  cursor: pointer;
}

.emotion-card:active {
  transform: translateY(2rpx) scale(0.98);
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.15);
}

.card-glow {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 60rpx;
  height: 60rpx;
  border-radius: 50%;
  transform: translate(-50%, -50%);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.card-glow.happy { background: radial-gradient(circle, rgba(255, 193, 7, 0.4) 0%, transparent 70%); }
.card-glow.calm { background: radial-gradient(circle, rgba(52, 144, 220, 0.4) 0%, transparent 70%); }
.card-glow.anxious { background: radial-gradient(circle, rgba(255, 152, 0, 0.4) 0%, transparent 70%); }
.card-glow.sad { background: radial-gradient(circle, rgba(108, 117, 125, 0.4) 0%, transparent 70%); }
.card-glow.angry { background: radial-gradient(circle, rgba(220, 53, 69, 0.4) 0%, transparent 70%); }
.card-glow.fearful { background: radial-gradient(circle, rgba(111, 66, 193, 0.4) 0%, transparent 70%); }

.emotion-card:active .card-glow {
  opacity: 1;
  animation: ripple 0.6s ease-out;
}

@keyframes ripple {
  0% {
    transform: translate(-50%, -50%) scale(0);
    opacity: 1;
  }
  100% {
    transform: translate(-50%, -50%) scale(4);
    opacity: 0;
  }
}

.emotion-icon {
  font-size: 45rpx;
  margin-bottom: 12rpx;
  position: relative;
  z-index: 2;
  transition: transform 0.3s ease;
}

.emotion-card:active .emotion-icon {
  transform: scale(1.1);
}

.emotion-name {
  font-size: 24rpx;
  color: #4a5568;
  font-weight: 600;
  position: relative;
  z-index: 2;
}

.emotion-ripple {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 0;
  height: 0;
  background: rgba(255, 255, 255, 0.4);
  border-radius: 50%;
  transform: translate(-50%, -50%);
  transition: width 0.3s ease, height 0.3s ease;
}

.emotion-card:active .emotion-ripple {
  width: 200rpx;
  height: 200rpx;
}

.recent-records {
  padding: 30rpx;
  margin-bottom: 120rpx;
  overflow: hidden;
}

.recent-records::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.1) 0%, rgba(255, 255, 255, 0.05) 100%);
  pointer-events: none;
}

.timeline {
  position: relative;
  z-index: 2;
}

.timeline-item {
  position: relative;
  display: flex;
  align-items: flex-start;
  gap: 20rpx;
  padding: 20rpx 0;
  transition: all 0.3s ease;
}

.timeline-item:active {
  transform: translateX(10rpx);
}

.timeline-dot {
  position: relative;
  width: 60rpx;
  height: 60rpx;
  background: rgba(255, 255, 255, 0.6);
  border: 3rpx solid rgba(102, 126, 234, 0.3);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  backdrop-filter: blur(10px);
  z-index: 2;
}

.record-emotion {
  font-size: 32rpx;
  filter: drop-shadow(0 2rpx 4rpx rgba(0, 0, 0, 0.1));
}

.timeline-content {
  flex: 1;
  background: rgba(255, 255, 255, 0.4);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 15rpx;
  padding: 20rpx;
  backdrop-filter: blur(10px);
  position: relative;
  margin-top: 5rpx;
}

.timeline-content::before {
  content: '';
  position: absolute;
  left: -8rpx;
  top: 20rpx;
  width: 0;
  height: 0;
  border-top: 8rpx solid transparent;
  border-bottom: 8rpx solid transparent;
  border-right: 8rpx solid rgba(255, 255, 255, 0.4);
}

.record-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8rpx;
}

.record-name {
  font-size: 28rpx;
  color: #2d3748;
  font-weight: 600;
}

.record-time {
  font-size: 22rpx;
  color: #718096;
  font-weight: 500;
}

.record-content {
  font-size: 24rpx;
  color: #4a5568;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.timeline-line {
  position: absolute;
  left: 29rpx;
  top: 80rpx;
  width: 2rpx;
  height: calc(100% - 20rpx);
  background: linear-gradient(180deg, rgba(102, 126, 234, 0.3) 0%, rgba(102, 126, 234, 0.1) 100%);
  z-index: 1;
}

.floating-button {
  position: fixed;
  right: 30rpx;
  bottom: 120rpx;
  width: 120rpx;
  height: 120rpx;
  background: var(--primary-gradient);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 12rpx 40rpx rgba(102, 126, 234, 0.4);
  z-index: 999;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  overflow: hidden;
}

.floating-button:active {
  transform: scale(0.95);
  box-shadow: 0 8rpx 25rpx rgba(102, 126, 234, 0.6);
}

.button-glow {
  position: absolute;
  width: 100%;
  height: 100%;
  background: radial-gradient(circle, rgba(255, 255, 255, 0.3) 0%, transparent 70%);
  border-radius: 50%;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.floating-button:active .button-glow {
  opacity: 1;
  animation: buttonPulse 0.6s ease-out;
}

@keyframes buttonPulse {
  0% {
    transform: scale(0);
    opacity: 1;
  }
  100% {
    transform: scale(2);
    opacity: 0;
  }
}

.plus-icon {
  font-size: 50rpx;
  color: white;
  font-weight: 300;
  position: relative;
  z-index: 2;
  text-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.2);
}

.button-ripple {
  position: absolute;
  width: 100%;
  height: 100%;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 50%;
  transform: scale(0);
  transition: transform 0.3s ease;
}

.floating-button:active .button-ripple {
  transform: scale(1);
}
</style> 