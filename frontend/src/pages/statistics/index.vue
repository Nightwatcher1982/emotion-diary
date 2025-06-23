<template>
  <view class="container">
    <!-- 页面标题区域 -->
    <view class="page-header">
      <view class="header-content">
        <text class="page-title">数据统计</text>
        <text class="page-subtitle">洞察你的情绪变化</text>
      </view>
      <view class="stats-badge">
        <text class="badge-text">{{ statsData.totalRecords }}</text>
        <text class="badge-label">总记录</text>
      </view>
    </view>

    <!-- 时间范围选择 -->
    <view class="time-selector">
      <view 
        class="time-option" 
        v-for="option in timeOptions" 
        :key="option.value"
        :class="{ active: selectedTime === option.value }"
        @click="selectTime(option.value)"
      >
        <text>{{ option.label }}</text>
      </view>
    </view>

    <!-- 统计概览卡片 -->
    <view class="stats-overview">
      <view class="overview-item" v-for="(item, index) in overviewItems" :key="index">
        <view class="item-icon">{{ item.icon }}</view>
        <view class="item-content">
          <text class="overview-number">{{ item.value }}</text>
          <text class="overview-label">{{ item.label }}</text>
        </view>
        <view class="item-glow"></view>
      </view>
    </view>

    <!-- 情绪趋势图 -->
    <view class="chart-section">
      <view class="section-header">
        <view class="header-left">
          <text class="section-title">情绪趋势</text>
          <text class="section-subtitle">{{ getTrendDescription() }}</text>
        </view>
        <view class="chart-controls">
          <text class="chart-type" @click="toggleChartType">
            {{ chartType === 'line' ? '📈' : '📊' }}
          </text>
        </view>
      </view>
      <view class="chart-container">
        <SimpleChart 
          :chart-type="chartType"
          :data="weekPattern"
          title="本周情绪变化"
          @chart-click="onChartClick"
        />
      </view>
    </view>

    <!-- 情绪分布 -->
    <view class="emotion-distribution">
      <view class="section-header">
        <view class="header-left">
          <text class="section-title">情绪分布</text>
          <text class="section-subtitle">了解你的情绪构成</text>
        </view>
        <view class="distribution-status">
          <text class="status-text">{{ getDominantEmotion() }}</text>
        </view>
      </view>
      <view class="chart-container">
        <SimpleChart 
          chart-type="pie"
          :data="emotionDistribution"
          title="情绪类型分布"
          @chart-click="onEmotionClick"
        />
      </view>
    </view>

    <!-- 场景分析 -->
    <view class="scene-analysis">
      <view class="section-header">
        <view class="header-left">
          <text class="section-title">场景分析</text>
          <text class="section-subtitle">不同场景的情绪记录</text>
        </view>
      </view>
      <view class="chart-container">
        <SimpleChart 
          chart-type="bar"
          :data="sceneStats"
          title="不同场景记录次数"
          @chart-click="onSceneClick"
        />
      </view>
    </view>

    <!-- 时间模式 -->
    <view class="time-pattern">
      <view class="section-header">
        <view class="header-left">
          <text class="section-title">时间模式</text>
          <text class="section-subtitle">发现你的情绪规律</text>
        </view>
      </view>
      <view class="pattern-tabs">
        <view 
          class="pattern-tab" 
          v-for="tab in patternTabs" 
          :key="tab.type"
          :class="{ active: activePatternTab === tab.type }"
          @click="switchPatternTab(tab.type)"
        >
          <text>{{ tab.label }}</text>
        </view>
      </view>
      <view class="pattern-content">
        <!-- 周模式 -->
        <view class="week-pattern" v-if="activePatternTab === 'week'">
          <SimpleChart 
            chart-type="bar"
            :data="weekPattern"
            title="一周情绪变化"
            @chart-click="onWeekClick"
          />
        </view>
        
        <!-- 时段模式 -->
        <view class="hour-pattern" v-if="activePatternTab === 'hour'">
          <SimpleChart 
            chart-type="heatmap"
            :data="hourPattern"
            title="时段活跃度热力图"
            @chart-click="onHeatmapClick"
          />
        </view>
      </view>
    </view>

    <!-- 情绪词云 -->
    <view class="emotion-wordcloud">
      <view class="section-header">
        <view class="header-left">
          <text class="section-title">情绪关键词</text>
          <text class="section-subtitle">高频情绪词汇</text>
        </view>
        <text class="wordcloud-tip">点击查看详情</text>
      </view>
      <view class="wordcloud-container">
        <view 
          class="word-item" 
          v-for="word in emotionWords" 
          :key="word.text"
          :style="{ 
            fontSize: word.size + 'rpx',
            color: word.color 
          }"
          @click="viewWordDetail(word)"
        >
          {{ word.text }}
          <view class="word-glow" :style="{ backgroundColor: word.color }"></view>
        </view>
      </view>
    </view>

    <!-- 成就系统 -->
    <view class="achievements">
      <view class="section-header">
        <view class="header-left">
          <text class="section-title">成就徽章</text>
          <text class="section-subtitle">记录你的成长足迹</text>
        </view>
        <view class="achievement-summary">
          <text class="achievement-count">{{ unlockedAchievements }}/{{ totalAchievements }}</text>
          <text class="achievement-percentage">{{ Math.round(unlockedAchievements / totalAchievements * 100) }}%</text>
        </view>
      </view>
      <view class="achievement-grid">
        <view 
          class="achievement-item" 
          v-for="achievement in achievements" 
          :key="achievement.id"
          :class="{ unlocked: achievement.unlocked }"
          @click="viewAchievement(achievement)"
        >
          <view class="achievement-icon-container">
            <text class="achievement-icon">{{ achievement.icon }}</text>
            <view class="icon-glow" v-if="achievement.unlocked"></view>
          </view>
          <text class="achievement-name">{{ achievement.name }}</text>
          <view class="achievement-progress" v-if="!achievement.unlocked">
            <view 
              class="progress-bar" 
              :style="{ width: (achievement.progress / achievement.target * 100) + '%' }"
            ></view>
          </view>
          <text class="achievement-desc" v-if="achievement.unlocked">{{ achievement.description }}</text>
        </view>
      </view>
    </view>

    <!-- 导出报告 -->
    <view class="export-section">
      <button class="export-button" @click="exportReport">
        <view class="button-content">
          <text class="button-icon">📊</text>
          <text class="button-text">导出情绪报告</text>
        </view>
        <view class="button-glow"></view>
      </button>
    </view>

    <!-- 浮动操作按钮 -->
    <view class="floating-actions">
      <view class="fab-item" @click="refreshData">
        <text class="fab-icon">🔄</text>
      </view>
      <view class="fab-item" @click="shareStats">
        <text class="fab-icon">📤</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import SimpleChart from '../../components/SimpleChart.vue'
import { statisticsAPI } from '../../utils/api'

// 响应式数据
const selectedTime = ref('week')
const chartType = ref('line')
const activePatternTab = ref('week')

// 时间选项
const timeOptions = ref([
  { value: 'week', label: '本周' },
  { value: 'month', label: '本月' },
  { value: 'quarter', label: '本季度' },
  { value: 'year', label: '本年' }
])

// 模式标签
const patternTabs = ref([
  { type: 'week', label: '周模式' },
  { type: 'hour', label: '时段模式' }
])

// 统计数据
const statsData = ref({
  totalRecords: 28,
  averageMood: 6.8,
  streakDays: 7,
  improvementRate: 15
})

// 概览项目
const overviewItems = computed(() => [
  {
    icon: '📝',
    value: statsData.value.totalRecords,
    label: '总记录数'
  },
  {
    icon: '😊',
    value: statsData.value.averageMood.toFixed(1),
    label: '平均情绪'
  },
  {
    icon: '🔥',
    value: statsData.value.streakDays,
    label: '连续天数'
  },
  {
    icon: '📈',
    value: `${statsData.value.improvementRate}%`,
    label: '改善率'
  }
])

// 情绪分布
const emotionDistribution = ref([
  { name: '快乐', value: 33.3, color: '#FFD700' },
  { name: '焦虑', value: 18.2, color: '#FF8C00' },
  { name: '平静', value: 15.9, color: '#87CEEB' },
  { name: '悲伤', value: 13.6, color: '#6495ED' },
  { name: '愤怒', value: 11.4, color: '#DC143C' },
  { name: '恐惧', value: 7.6, color: '#9370DB' }
])

// 场景统计
const sceneStats = ref([
  { name: '个人', value: 18, color: '#FFB6C1' },
  { name: '工作', value: 8, color: '#4A90E2' },
  { name: '社交', value: 6, color: '#90EE90' },
  { name: '学习', value: 4, color: '#20B2AA' },
  { name: '健康', value: 3, color: '#DDA0DD' },
  { name: '其他', value: 2, color: '#F0E68C' }
])

// 周模式数据
const weekPattern = ref([
  { name: '周一', value: 6.2, color: '#4A90E2' },
  { name: '周二', value: 7.1, color: '#4A90E2' },
  { name: '周三', value: 5.8, color: '#4A90E2' },
  { name: '周四', value: 6.9, color: '#4A90E2' },
  { name: '周五', value: 7.5, color: '#4A90E2' },
  { name: '周六', value: 8.2, color: '#4A90E2' },
  { name: '周日', value: 7.8, color: '#4A90E2' }
])

// 时段模式数据
const hourPattern = ref([
  { hour: '早晨', value: 7.2, color: '#FFD700' },
  { hour: '上午', value: 6.8, color: '#FFA500' },
  { hour: '中午', value: 6.5, color: '#FF8C00' },
  { hour: '下午', value: 6.2, color: '#FF6347' },
  { hour: '傍晚', value: 7.0, color: '#9370DB' },
  { hour: '晚上', value: 7.5, color: '#4169E1' }
])

// 情绪词汇
const emotionWords = ref([
  { text: '开心', size: 48, color: '#FFD700' },
  { text: '焦虑', size: 36, color: '#FF8C00' },
  { text: '平静', size: 32, color: '#87CEEB' },
  { text: '压力', size: 28, color: '#DC143C' },
  { text: '满足', size: 24, color: '#90EE90' },
  { text: '疲惫', size: 20, color: '#9370DB' }
])

// 成就数据
const achievements = ref([
  {
    id: 1,
    name: '初心者',
    icon: '🌱',
    description: '完成第一次情绪记录',
    unlocked: true,
    progress: 1,
    target: 1
  },
  {
    id: 2,
    name: '坚持者',
    icon: '🔥',
    description: '连续记录7天',
    unlocked: true,
    progress: 7,
    target: 7
  },
  {
    id: 3,
    name: '探索者',
    icon: '🔍',
    description: '尝试所有情绪类型',
    unlocked: false,
    progress: 4,
    target: 6
  },
  {
    id: 4,
    name: '分析师',
    icon: '📊',
    description: '使用AI分析10次',
    unlocked: false,
    progress: 6,
    target: 10
  }
])

// 计算属性
const unlockedAchievements = computed(() => 
  achievements.value.filter(a => a.unlocked).length
)

const totalAchievements = computed(() => achievements.value.length)

// 方法
const selectTime = (value: string) => {
  selectedTime.value = value
  loadStatsData()
}

const toggleChartType = () => {
  chartType.value = chartType.value === 'line' ? 'bar' : 'line'
}

const switchPatternTab = (type: string) => {
  activePatternTab.value = type
}

const getTrendDescription = () => {
  const trend = statsData.value.improvementRate
  if (trend > 10) return '情绪呈上升趋势 📈'
  if (trend > 0) return '情绪保持稳定 ➡️'
  return '需要关注情绪变化 📉'
}

const getDominantEmotion = () => {
  const dominant = emotionDistribution.value[0]
  return `${dominant.name} ${dominant.value}%`
}

const onChartClick = (data: any) => {
  console.log('Chart clicked:', data)
  uni.showToast({
    title: `查看${data.name}详情`,
    icon: 'none'
  })
}

const onEmotionClick = (data: any) => {
  console.log('Emotion clicked:', data)
  uni.showToast({
    title: `${data.name}: ${data.value}%`,
    icon: 'none'
  })
}

const onSceneClick = (data: any) => {
  console.log('Scene clicked:', data)
  uni.showToast({
    title: `${data.name}: ${data.value}次`,
    icon: 'none'
  })
}

const onWeekClick = (data: any) => {
  console.log('Week clicked:', data)
  uni.showToast({
    title: `${data.name}: ${data.value}分`,
    icon: 'none'
  })
}

const onHeatmapClick = (data: any) => {
  console.log('Heatmap clicked:', data)
  uni.showToast({
    title: `${data.hour}: ${data.value}分`,
    icon: 'none'
  })
}

const viewWordDetail = (word: any) => {
  console.log('Word clicked:', word)
  uni.showToast({
    title: `查看"${word.text}"相关记录`,
    icon: 'none'
  })
}

const viewAchievement = (achievement: any) => {
  console.log('Achievement clicked:', achievement)
  const message = achievement.unlocked 
    ? `已获得: ${achievement.description}`
    : `进度: ${achievement.progress}/${achievement.target}`
  
  uni.showToast({
    title: message,
    icon: 'none'
  })
}

const exportReport = () => {
  uni.showToast({
    title: '正在生成报告...',
    icon: 'loading'
  })
  
  setTimeout(() => {
    uni.showToast({
      title: '报告已生成',
      icon: 'success'
    })
  }, 2000)
}

const refreshData = () => {
  uni.showToast({
    title: '正在刷新数据...',
    icon: 'loading'
  })
  loadStatsData()
}

const shareStats = () => {
  uni.showToast({
    title: '分享功能开发中',
    icon: 'none'
  })
}

const loadStatsData = async () => {
  try {
    // 这里可以调用真实的API
    // const response = await statisticsAPI.getOverview(selectedTime.value)
    // statsData.value = response.data
    
    console.log('Loading stats data for:', selectedTime.value)
  } catch (error) {
    console.error('Failed to load stats:', error)
    uni.showToast({
      title: '数据加载失败',
      icon: 'none'
    })
  }
}

// 生命周期
onMounted(() => {
  loadStatsData()
})
</script>

<style scoped>
/* 页面特定变量（继承全局变量） */

.container {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  padding: 0 30rpx 120rpx;
}

/* 页面标题区域 */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 60rpx 0 40rpx;
}

.header-content {
  flex: 1;
}

.page-title {
  font-size: 48rpx;
  font-weight: bold;
  background: var(--primary-gradient);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin-bottom: 8rpx;
  display: block;
}

.page-subtitle {
  font-size: 28rpx;
  color: var(--text-secondary);
  opacity: 0.8;
}

.stats-badge {
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  padding: 20rpx 30rpx;
  text-align: center;
  box-shadow: var(--shadow-light);
}

.badge-text {
  font-size: 36rpx;
  font-weight: bold;
  color: var(--text-primary);
  display: block;
  margin-bottom: 4rpx;
}

.badge-label {
  font-size: 22rpx;
  color: var(--text-secondary);
}

/* 时间选择器 */
.time-selector {
  display: flex;
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  padding: 8rpx;
  margin-bottom: 40rpx;
  box-shadow: var(--shadow-light);
}

.time-option {
  flex: 1;
  text-align: center;
  padding: 20rpx 15rpx;
  border-radius: 20rpx;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.time-option.active {
  background: var(--primary-gradient);
  color: white;
  transform: translateY(-2rpx);
  box-shadow: var(--shadow-medium);
}

.time-option.active::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(45deg, rgba(255,255,255,0.1), transparent);
  pointer-events: none;
}

.time-option text {
  font-size: 28rpx;
  font-weight: 500;
}

/* 统计概览 */
.stats-overview {
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
  padding: 35rpx 25rpx;
  display: flex;
  align-items: center;
  gap: 20rpx;
  box-shadow: var(--shadow-light);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.overview-item:hover {
  transform: translateY(-4rpx);
  box-shadow: var(--shadow-medium);
}

.item-icon {
  font-size: 40rpx;
  width: 60rpx;
  height: 60rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 50%;
  backdrop-filter: blur(10rpx);
}

.item-content {
  flex: 1;
}

.overview-number {
  font-size: 36rpx;
  font-weight: bold;
  color: var(--text-primary);
  display: block;
  margin-bottom: 8rpx;
}

.overview-label {
  font-size: 24rpx;
  color: var(--text-secondary);
  opacity: 0.8;
}

.item-glow {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(45deg, transparent, rgba(255,255,255,0.1), transparent);
  transform: translateX(-100%);
  transition: transform 0.6s ease;
}

.overview-item:hover .item-glow {
  transform: translateX(100%);
}

/* 图表区域 */
.chart-section,
.emotion-distribution,
.scene-analysis,
.time-pattern,
.emotion-wordcloud,
.achievements {
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  padding: 40rpx;
  margin-bottom: 40rpx;
  box-shadow: var(--shadow-light);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.chart-section:hover,
.emotion-distribution:hover,
.scene-analysis:hover,
.time-pattern:hover,
.emotion-wordcloud:hover,
.achievements:hover {
  transform: translateY(-2rpx);
  box-shadow: var(--shadow-medium);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 30rpx;
}

.header-left {
  flex: 1;
}

.section-title {
  font-size: 36rpx;
  font-weight: bold;
  color: var(--text-primary);
  margin-bottom: 8rpx;
  display: block;
}

.section-subtitle {
  font-size: 26rpx;
  color: var(--text-secondary);
  opacity: 0.8;
}

.chart-controls {
  display: flex;
  gap: 15rpx;
}

.chart-type {
  font-size: 32rpx;
  padding: 10rpx 15rpx;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 15rpx;
  backdrop-filter: blur(10rpx);
  transition: all 0.3s ease;
}

.chart-type:active {
  transform: scale(0.95);
  background: rgba(255, 255, 255, 0.5);
}

.distribution-status,
.achievement-summary {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 5rpx;
}

.status-text {
  font-size: 24rpx;
  color: var(--text-primary);
  font-weight: 600;
}

.achievement-count {
  font-size: 28rpx;
  font-weight: bold;
  color: var(--text-primary);
}

.achievement-percentage {
  font-size: 22rpx;
  color: var(--text-secondary);
}

.chart-container {
  margin: 25rpx 0;
  min-height: 300rpx;
}

/* 模式切换标签 */
.pattern-tabs {
  display: flex;
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10rpx);
  border-radius: 20rpx;
  padding: 8rpx;
  margin-bottom: 30rpx;
}

.pattern-tab {
  flex: 1;
  text-align: center;
  padding: 18rpx 15rpx;
  border-radius: 15rpx;
  font-size: 28rpx;
  color: var(--text-secondary);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  font-weight: 500;
}

.pattern-tab.active {
  background: var(--primary-gradient);
  color: white;
  transform: translateY(-2rpx);
  box-shadow: 0 8rpx 25rpx rgba(102, 126, 234, 0.3);
}

/* 词云容器 */
.wordcloud-container {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  align-items: center;
  gap: 25rpx;
  padding: 40rpx 0;
  min-height: 250rpx;
}

.word-item {
  padding: 15rpx 25rpx;
  border-radius: 30rpx;
  background: rgba(255, 255, 255, 0.3);
  backdrop-filter: blur(10rpx);
  border: 2rpx solid rgba(255, 255, 255, 0.2);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  cursor: pointer;
  position: relative;
  overflow: hidden;
  font-weight: 600;
}

.word-item:active {
  transform: scale(1.1) translateY(-4rpx);
  box-shadow: var(--shadow-medium);
}

.word-glow {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  opacity: 0.1;
  border-radius: 30rpx;
  transition: opacity 0.3s ease;
}

.word-item:hover .word-glow {
  opacity: 0.2;
}

.wordcloud-tip {
  font-size: 24rpx;
  color: var(--text-secondary);
  opacity: 0.7;
}

/* 成就网格 */
.achievement-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 25rpx;
}

.achievement-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 30rpx 25rpx;
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10rpx);
  border: 2rpx solid rgba(255, 255, 255, 0.3);
  border-radius: 20rpx;
  opacity: 0.6;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.achievement-item.unlocked {
  opacity: 1;
  background: var(--success-gradient);
  border-color: rgba(255, 255, 255, 0.5);
  color: white;
  transform: translateY(-2rpx);
  box-shadow: var(--shadow-medium);
}

.achievement-icon-container {
  position: relative;
  margin-bottom: 15rpx;
}

.achievement-icon {
  font-size: 48rpx;
  display: block;
}

.icon-glow {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 80rpx;
  height: 80rpx;
  background: radial-gradient(circle, rgba(255,255,255,0.3), transparent);
  border-radius: 50%;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { transform: translate(-50%, -50%) scale(1); opacity: 0.7; }
  50% { transform: translate(-50%, -50%) scale(1.2); opacity: 0.3; }
}

.achievement-name {
  font-size: 26rpx;
  font-weight: bold;
  margin-bottom: 10rpx;
  text-align: center;
}

.achievement-desc {
  font-size: 22rpx;
  opacity: 0.9;
  text-align: center;
  line-height: 1.4;
}

.achievement-progress {
  width: 100%;
  height: 8rpx;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 4rpx;
  overflow: hidden;
  margin-top: 10rpx;
}

.progress-bar {
  height: 100%;
  background: var(--primary-gradient);
  transition: width 0.5s cubic-bezier(0.4, 0, 0.2, 1);
  border-radius: 4rpx;
}

/* 导出按钮 */
.export-section {
  padding: 40rpx 0;
}

.export-button {
  width: 100%;
  height: 100rpx;
  background: var(--primary-gradient);
  color: white;
  border: none;
  border-radius: 25rpx;
  font-size: 30rpx;
  font-weight: bold;
  box-shadow: var(--shadow-medium);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.export-button:active {
  transform: translateY(2rpx);
  box-shadow: var(--shadow-light);
}

.button-content {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 15rpx;
  position: relative;
  z-index: 2;
}

.button-icon {
  font-size: 32rpx;
}

.button-text {
  font-size: 30rpx;
  font-weight: bold;
}

.button-glow {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(45deg, transparent, rgba(255,255,255,0.2), transparent);
  transform: translateX(-100%);
  transition: transform 0.6s ease;
}

.export-button:hover .button-glow {
  transform: translateX(100%);
}

/* 浮动操作按钮 */
.floating-actions {
  position: fixed;
  right: 30rpx;
  bottom: 150rpx;
  display: flex;
  flex-direction: column;
  gap: 20rpx;
  z-index: 100;
}

.fab-item {
  width: 100rpx;
  height: 100rpx;
  background: var(--primary-gradient);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: var(--shadow-heavy);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.fab-item:active {
  transform: scale(0.9);
  box-shadow: var(--shadow-medium);
}

.fab-icon {
  font-size: 36rpx;
  color: white;
}

/* 响应式设计 */
@media (max-width: 750rpx) {
  .stats-overview {
    grid-template-columns: 1fr;
  }
  
  .achievement-grid {
    grid-template-columns: 1fr;
  }
  
  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 20rpx;
  }
}

/* 深色模式特定样式调整 */
@media (prefers-color-scheme: dark) {
  .container {
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
  }
}
</style> 