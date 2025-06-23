<template>
  <view class="container">
    <!-- 页面头部 -->
    <view class="page-header">
      <view class="header-content">
        <text class="page-title">分析历史</text>
        <text class="page-subtitle">回顾你的情绪分析历程</text>
      </view>
      <view class="header-stats">
        <view class="stat-item">
          <text class="stat-number">{{ totalAnalyses }}</text>
          <text class="stat-label">总分析数</text>
        </view>
        <view class="stat-item">
          <text class="stat-number">{{ averageScore }}</text>
          <text class="stat-label">平均评分</text>
        </view>
      </view>
    </view>

    <!-- 筛选和排序 -->
    <view class="filter-section glass-card">
      <view class="filter-row">
        <picker 
          :range="timeRangeOptions" 
          :value="selectedTimeRange"
          @change="onTimeRangeChange"
        >
          <view class="filter-item">
            <text class="filter-icon">📅</text>
            <text class="filter-text">{{ timeRangeOptions[selectedTimeRange] }}</text>
            <text class="filter-arrow">▼</text>
          </view>
        </picker>
        
        <picker 
          :range="sortOptions" 
          :value="selectedSort"
          @change="onSortChange"
        >
          <view class="filter-item">
            <text class="filter-icon">🔄</text>
            <text class="filter-text">{{ sortOptions[selectedSort] }}</text>
            <text class="filter-arrow">▼</text>
          </view>
        </picker>
      </view>
    </view>

    <!-- 分析历史列表 -->
    <view class="history-list">
      <view 
        class="history-item glass-card"
        v-for="analysis in filteredAnalyses"
        :key="analysis.id"
        @click="viewAnalysisDetail(analysis)"
      >
        <!-- 分析头部信息 -->
        <view class="analysis-header">
          <view class="analysis-date">
            <text class="date-text">{{ formatDate(analysis.created_at) }}</text>
            <text class="time-text">{{ formatTime(analysis.created_at) }}</text>
          </view>
          <view class="analysis-status">
            <view class="status-badge" :class="getStatusClass(analysis.confidence_score)">
              <text class="status-text">{{ getStatusText(analysis.confidence_score) }}</text>
            </view>
          </view>
        </view>

        <!-- 情绪信息 -->
        <view class="emotion-info">
          <view class="primary-emotion">
            <text class="emotion-icon">{{ getEmotionIcon(analysis.primary_emotion) }}</text>
            <text class="emotion-name">{{ getEmotionName(analysis.primary_emotion) }}</text>
            <view class="intensity-bar">
              <view 
                class="intensity-fill" 
                :style="{ width: (analysis.intensity_level * 10) + '%' }"
              ></view>
            </view>
            <text class="intensity-text">{{ analysis.intensity_level }}/10</text>
          </view>
        </view>

        <!-- AI洞察预览 -->
        <view class="insights-preview">
          <text class="insights-title">AI洞察</text>
          <text class="insights-summary">{{ analysis.key_insights[0]?.content || '暂无洞察' }}</text>
          <view class="insights-count" v-if="analysis.key_insights.length > 1">
            <text class="count-text">+{{ analysis.key_insights.length - 1 }}个洞察</text>
          </view>
        </view>

        <!-- 建议预览 -->
        <view class="suggestions-preview" v-if="analysis.suggestions.length > 0">
          <text class="suggestions-title">个性化建议</text>
          <view class="suggestion-tags">
            <view 
              class="suggestion-tag"
              v-for="(suggestion, index) in analysis.suggestions.slice(0, 3)"
              :key="index"
            >
              <text class="tag-text">{{ suggestion.title }}</text>
            </view>
            <view class="more-suggestions" v-if="analysis.suggestions.length > 3">
              <text class="more-text">+{{ analysis.suggestions.length - 3 }}</text>
            </view>
          </view>
        </view>

        <!-- 分析评分 -->
        <view class="analysis-footer">
          <view class="confidence-score">
            <text class="score-label">置信度</text>
            <view class="score-bar">
              <view 
                class="score-fill" 
                :style="{ width: analysis.confidence_score + '%' }"
              ></view>
            </view>
            <text class="score-text">{{ analysis.confidence_score }}%</text>
          </view>
          <view class="view-detail">
            <text class="detail-text">查看详情</text>
            <text class="detail-arrow">→</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 加载状态 -->
    <view class="loading-section" v-if="isLoading">
      <view class="loading-spinner"></view>
      <text class="loading-text">加载中...</text>
    </view>

    <!-- 空状态 -->
    <view class="empty-state" v-if="!isLoading && filteredAnalyses.length === 0">
      <text class="empty-icon">📊</text>
      <text class="empty-title">暂无分析记录</text>
      <text class="empty-desc">开始记录情绪，获得AI分析建议</text>
      <button class="start-record-btn" @click="goToRecord">
        开始记录
      </button>
    </view>

    <!-- 加载更多 -->
    <view class="load-more" v-if="hasMore && !isLoading">
      <button class="load-more-btn" @click="loadMore">
        加载更多
      </button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { aiAPI } from '../../utils/api'

// 类型定义
interface Analysis {
  id: string
  created_at: string
  primary_emotion: string
  intensity_level: number
  confidence_score: number
  key_insights: Array<{
    type: string
    content: string
    icon: string
  }>
  suggestions: Array<{
    title: string
    type: string
  }>
  user_rating?: number
}

// 响应式数据
const analyses = ref<Analysis[]>([])
const isLoading = ref(false)
const hasMore = ref(true)
const currentPage = ref(1)

const selectedTimeRange = ref(0)
const selectedSort = ref(0)

// 选项数据
const timeRangeOptions = ref([
  '全部时间',
  '最近一周',
  '最近一月',
  '最近三月'
])

const sortOptions = ref([
  '按时间排序',
  '按评分排序',
  '按置信度排序'
])

// 计算属性
const totalAnalyses = computed(() => analyses.value.length)
const averageScore = computed(() => {
  if (analyses.value.length === 0) return '0.0'
  const total = analyses.value.reduce((sum, analysis) => sum + (analysis.user_rating || 0), 0)
  return (total / analyses.value.length).toFixed(1)
})

const filteredAnalyses = computed(() => {
  let filtered = [...analyses.value]
  
  // 时间筛选
  const now = new Date()
  switch (selectedTimeRange.value) {
    case 1: // 最近一周
      const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
      filtered = filtered.filter(a => new Date(a.created_at) >= weekAgo)
      break
    case 2: // 最近一月
      const monthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000)
      filtered = filtered.filter(a => new Date(a.created_at) >= monthAgo)
      break
    case 3: // 最近三月
      const threeMonthsAgo = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000)
      filtered = filtered.filter(a => new Date(a.created_at) >= threeMonthsAgo)
      break
  }
  
  // 排序
  switch (selectedSort.value) {
    case 0: // 按时间排序
      filtered.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
      break
    case 1: // 按评分排序
      filtered.sort((a, b) => (b.user_rating || 0) - (a.user_rating || 0))
      break
    case 2: // 按置信度排序
      filtered.sort((a, b) => b.confidence_score - a.confidence_score)
      break
  }
  
  return filtered
})

// 方法
const loadAnalysisHistory = async (page: number = 1) => {
  try {
    isLoading.value = true
    
    const response = await aiAPI.getAnalysisHistory({
      page,
      page_size: 10
    })
    
    if (page === 1) {
      analyses.value = response.results || []
    } else {
      analyses.value.push(...(response.results || []))
    }
    
    hasMore.value = !!response.next
    currentPage.value = page
    
  } catch (error) {
    console.error('加载分析历史失败:', error)
    uni.showToast({
      title: '加载失败，请重试',
      icon: 'none'
    })
  } finally {
    isLoading.value = false
  }
}

const loadMore = () => {
  if (!hasMore.value || isLoading.value) return
  loadAnalysisHistory(currentPage.value + 1)
}

const onTimeRangeChange = (e: any) => {
  selectedTimeRange.value = e.detail.value
}

const onSortChange = (e: any) => {
  selectedSort.value = e.detail.value
}

const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  const now = new Date()
  const diffTime = now.getTime() - date.getTime()
  const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24))
  
  if (diffDays === 0) return '今天'
  if (diffDays === 1) return '昨天'
  if (diffDays < 7) return `${diffDays}天前`
  
  const month = date.getMonth() + 1
  const day = date.getDate()
  return `${month}月${day}日`
}

const formatTime = (dateString: string) => {
  const date = new Date(dateString)
  const hour = date.getHours().toString().padStart(2, '0')
  const minute = date.getMinutes().toString().padStart(2, '0')
  return `${hour}:${minute}`
}

const getEmotionIcon = (emotion: string) => {
  const iconMap: Record<string, string> = {
    'happy': '😊',
    'sad': '😢',
    'angry': '😠',
    'anxious': '😰',
    'excited': '🤩',
    'calm': '😌',
    'confused': '😕'
  }
  return iconMap[emotion] || '😐'
}

const getEmotionName = (emotion: string) => {
  const nameMap: Record<string, string> = {
    'happy': '快乐',
    'sad': '悲伤',
    'angry': '愤怒',
    'anxious': '焦虑',
    'excited': '兴奋',
    'calm': '平静',
    'confused': '困惑'
  }
  return nameMap[emotion] || '未知'
}

const getStatusClass = (confidence: number) => {
  if (confidence >= 80) return 'status-high'
  if (confidence >= 60) return 'status-medium'
  return 'status-low'
}

const getStatusText = (confidence: number) => {
  if (confidence >= 80) return '高置信度'
  if (confidence >= 60) return '中置信度'
  return '低置信度'
}

const viewAnalysisDetail = (analysis: Analysis) => {
  uni.navigateTo({
    url: `/pages/analysis/index?analysisId=${analysis.id}`
  })
}

const goToRecord = () => {
  uni.switchTab({
    url: '/pages/record/index'
  })
}

// 生命周期
onMounted(() => {
  loadAnalysisHistory()
})
</script>

<style scoped>
/* CSS变量定义 */
:root {
  --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  --glass-bg: rgba(255, 255, 255, 0.25);
  --glass-border: rgba(255, 255, 255, 0.18);
  --shadow-light: 0 8rpx 32rpx rgba(31, 38, 135, 0.37);
  --success-color: #10b981;
  --warning-color: #f59e0b;
  --danger-color: #ef4444;
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

/* 页面头部 */
.page-header {
  padding: 40rpx 30rpx;
  position: relative;
  z-index: 1;
}

.header-content {
  text-align: center;
  margin-bottom: 30rpx;
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

.header-stats {
  display: flex;
  justify-content: center;
  gap: 60rpx;
}

.stat-item {
  text-align: center;
}

.stat-number {
  font-size: 36rpx;
  font-weight: 700;
  color: #667eea;
  display: block;
  margin-bottom: 8rpx;
}

.stat-label {
  font-size: 24rpx;
  color: #718096;
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

/* 筛选区域 */
.filter-section {
  padding: 25rpx 30rpx;
}

.filter-row {
  display: flex;
  gap: 20rpx;
}

.filter-item {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20rpx 25rpx;
  background: rgba(255, 255, 255, 0.4);
  border-radius: 15rpx;
  position: relative;
  z-index: 2;
}

.filter-icon {
  font-size: 24rpx;
  margin-right: 10rpx;
}

.filter-text {
  flex: 1;
  font-size: 26rpx;
  color: #4a5568;
  font-weight: 500;
}

.filter-arrow {
  font-size: 20rpx;
  color: #a0aec0;
}

/* 历史列表 */
.history-list {
  position: relative;
  z-index: 1;
}

.history-item {
  padding: 30rpx;
  margin-bottom: 20rpx;
  transition: transform 0.2s ease;
}

.history-item:active {
  transform: translateY(2rpx);
}

/* 分析头部 */
.analysis-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 25rpx;
  position: relative;
  z-index: 2;
}

.analysis-date {
  display: flex;
  flex-direction: column;
}

.date-text {
  font-size: 28rpx;
  font-weight: 600;
  color: #2d3748;
  margin-bottom: 5rpx;
}

.time-text {
  font-size: 22rpx;
  color: #718096;
}

.analysis-status {
  position: relative;
  z-index: 2;
}

.status-badge {
  padding: 8rpx 16rpx;
  border-radius: 20rpx;
  font-size: 20rpx;
  font-weight: 600;
}

.status-badge.status-high {
  background: rgba(16, 185, 129, 0.2);
  color: var(--success-color);
}

.status-badge.status-medium {
  background: rgba(245, 158, 11, 0.2);
  color: var(--warning-color);
}

.status-badge.status-low {
  background: rgba(239, 68, 68, 0.2);
  color: var(--danger-color);
}

/* 情绪信息 */
.emotion-info {
  margin-bottom: 25rpx;
  position: relative;
  z-index: 2;
}

.primary-emotion {
  display: flex;
  align-items: center;
  gap: 15rpx;
}

.emotion-icon {
  font-size: 32rpx;
}

.emotion-name {
  font-size: 28rpx;
  font-weight: 600;
  color: #2d3748;
  min-width: 80rpx;
}

.intensity-bar {
  flex: 1;
  height: 8rpx;
  background: rgba(0, 0, 0, 0.1);
  border-radius: 4rpx;
  overflow: hidden;
  margin: 0 15rpx;
}

.intensity-fill {
  height: 100%;
  background: linear-gradient(90deg, #667eea, #764ba2);
  border-radius: 4rpx;
  transition: width 0.3s ease;
}

.intensity-text {
  font-size: 24rpx;
  color: #718096;
  font-weight: 500;
  min-width: 60rpx;
}

/* AI洞察预览 */
.insights-preview {
  margin-bottom: 25rpx;
  position: relative;
  z-index: 2;
}

.insights-title {
  font-size: 24rpx;
  font-weight: 600;
  color: #667eea;
  margin-bottom: 10rpx;
  display: block;
}

.insights-summary {
  font-size: 26rpx;
  color: #4a5568;
  line-height: 1.6;
  display: block;
  margin-bottom: 10rpx;
}

.insights-count {
  display: inline-block;
}

.count-text {
  font-size: 22rpx;
  color: #a0aec0;
  background: rgba(160, 174, 192, 0.1);
  padding: 4rpx 12rpx;
  border-radius: 12rpx;
}

/* 建议预览 */
.suggestions-preview {
  margin-bottom: 25rpx;
  position: relative;
  z-index: 2;
}

.suggestions-title {
  font-size: 24rpx;
  font-weight: 600;
  color: #10b981;
  margin-bottom: 15rpx;
  display: block;
}

.suggestion-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 10rpx;
  align-items: center;
}

.suggestion-tag {
  background: rgba(16, 185, 129, 0.1);
  border: 1px solid rgba(16, 185, 129, 0.2);
  border-radius: 15rpx;
  padding: 8rpx 16rpx;
}

.tag-text {
  font-size: 22rpx;
  color: var(--success-color);
  font-weight: 500;
}

.more-suggestions {
  background: rgba(160, 174, 192, 0.1);
  border: 1px solid rgba(160, 174, 192, 0.2);
  border-radius: 15rpx;
  padding: 8rpx 16rpx;
}

.more-text {
  font-size: 22rpx;
  color: #a0aec0;
  font-weight: 500;
}

/* 分析底部 */
.analysis-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: relative;
  z-index: 2;
}

.confidence-score {
  display: flex;
  align-items: center;
  gap: 15rpx;
  flex: 1;
}

.score-label {
  font-size: 24rpx;
  color: #718096;
  min-width: 80rpx;
}

.score-bar {
  flex: 1;
  height: 6rpx;
  background: rgba(0, 0, 0, 0.1);
  border-radius: 3rpx;
  overflow: hidden;
  max-width: 200rpx;
}

.score-fill {
  height: 100%;
  background: linear-gradient(90deg, #667eea, #764ba2);
  border-radius: 3rpx;
  transition: width 0.3s ease;
}

.score-text {
  font-size: 24rpx;
  color: #4a5568;
  font-weight: 600;
  min-width: 60rpx;
}

.view-detail {
  display: flex;
  align-items: center;
  gap: 8rpx;
}

.detail-text {
  font-size: 24rpx;
  color: #667eea;
  font-weight: 500;
}

.detail-arrow {
  font-size: 20rpx;
  color: #667eea;
}

/* 加载状态 */
.loading-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 60rpx 0;
  position: relative;
  z-index: 1;
}

.loading-spinner {
  width: 60rpx;
  height: 60rpx;
  border: 4rpx solid rgba(102, 126, 234, 0.2);
  border-top: 4rpx solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 20rpx;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-text {
  font-size: 26rpx;
  color: #718096;
}

/* 空状态 */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 100rpx 40rpx;
  text-align: center;
  position: relative;
  z-index: 1;
}

.empty-icon {
  font-size: 120rpx;
  margin-bottom: 30rpx;
}

.empty-title {
  font-size: 32rpx;
  font-weight: 600;
  color: #4a5568;
  margin-bottom: 15rpx;
}

.empty-desc {
  font-size: 26rpx;
  color: #718096;
  margin-bottom: 40rpx;
  line-height: 1.6;
}

.start-record-btn {
  padding: 20rpx 40rpx;
  background: var(--primary-gradient);
  color: white;
  border: none;
  border-radius: 25rpx;
  font-size: 28rpx;
  font-weight: 600;
  box-shadow: 0 8rpx 25rpx rgba(102, 126, 234, 0.4);
}

.start-record-btn:active {
  transform: translateY(2rpx);
}

/* 加载更多 */
.load-more {
  display: flex;
  justify-content: center;
  padding: 40rpx;
  position: relative;
  z-index: 1;
}

.load-more-btn {
  padding: 20rpx 60rpx;
  background: rgba(255, 255, 255, 0.4);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 25rpx;
  font-size: 26rpx;
  color: #4a5568;
  font-weight: 500;
  backdrop-filter: blur(10px);
}

.load-more-btn:active {
  transform: translateY(2rpx);
}
</style> 