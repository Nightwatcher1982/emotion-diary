<template>
  <view class="container">
    <!-- 页面头部 -->
    <view class="page-header">
      <text class="page-title">成就系统</text>
      <text class="page-subtitle">记录你的每一份成长</text>
    </view>

    <!-- 成就概览 -->
    <view class="achievement-overview">
      <view class="overview-card">
        <view class="overview-item">
          <text class="overview-number">{{ achievementStats.total }}</text>
          <text class="overview-label">总成就</text>
        </view>
        <view class="overview-item">
          <text class="overview-number">{{ achievementStats.unlocked }}</text>
          <text class="overview-label">已解锁</text>
        </view>
        <view class="overview-item">
          <text class="overview-number">{{ achievementStats.points }}</text>
          <text class="overview-label">成就点数</text>
        </view>
        <view class="overview-item">
          <text class="overview-number">{{ achievementStats.rank }}</text>
          <text class="overview-label">当前等级</text>
        </view>
      </view>
      
      <!-- 等级进度条 -->
      <view class="level-progress">
        <view class="progress-header">
          <text class="current-level">{{ currentLevel.name }}</text>
          <text class="next-level">{{ nextLevel.name }}</text>
        </view>
        <view class="progress-bar">
          <view 
            class="progress-fill" 
            :style="{ width: levelProgress + '%' }"
          ></view>
        </view>
        <text class="progress-text">{{ achievementStats.points }}/{{ nextLevel.requiredPoints }} 点</text>
      </view>
    </view>

    <!-- 分类筛选 -->
    <view class="category-filter">
      <scroll-view class="filter-scroll" scroll-x="true">
        <view 
          class="filter-item"
          v-for="category in categories"
          :key="category.key"
          :class="{ active: selectedCategory === category.key }"
          @click="selectCategory(category.key)"
        >
          <text class="filter-icon">{{ category.icon }}</text>
          <text class="filter-name">{{ category.name }}</text>
        </view>
      </scroll-view>
    </view>

    <!-- 成就列表 -->
    <view class="achievements-list">
      <view 
        class="achievement-item"
        v-for="achievement in filteredAchievements"
        :key="achievement.id"
        :class="{ 
          unlocked: achievement.unlocked,
          locked: !achievement.unlocked,
          rare: achievement.rarity === 'rare',
          epic: achievement.rarity === 'epic',
          legendary: achievement.rarity === 'legendary'
        }"
        @click="viewAchievementDetail(achievement)"
      >
        <view class="achievement-icon-container">
          <text class="achievement-icon">{{ achievement.icon }}</text>
          <view class="rarity-glow" v-if="achievement.unlocked && achievement.rarity !== 'common'"></view>
          <view class="unlock-badge" v-if="achievement.unlocked">✓</view>
        </view>
        
        <view class="achievement-info">
          <text class="achievement-name">{{ achievement.name }}</text>
          <text class="achievement-desc">{{ achievement.description }}</text>
          
          <!-- 进度条 -->
          <view class="achievement-progress" v-if="!achievement.unlocked && achievement.progress !== undefined">
            <view class="progress-bar mini">
              <view 
                class="progress-fill" 
                :style="{ width: (achievement.progress / achievement.target) * 100 + '%' }"
              ></view>
            </view>
            <text class="progress-text mini">{{ achievement.progress }}/{{ achievement.target }}</text>
          </view>
          
          <!-- 解锁时间 -->
          <text class="unlock-time" v-if="achievement.unlocked">
            {{ formatUnlockTime(achievement.unlockedAt) }}
          </text>
        </view>
        
        <view class="achievement-reward">
          <text class="reward-points">+{{ achievement.points }}</text>
          <view class="rarity-badge" :class="achievement.rarity">
            {{ getRarityText(achievement.rarity) }}
          </view>
        </view>
      </view>
    </view>

    <!-- 最近解锁 -->
    <view class="recent-unlocks" v-if="recentUnlocks.length > 0">
      <view class="section-header">
        <text class="section-title">最近解锁</text>
        <text class="view-all" @click="viewAllRecent">查看全部</text>
      </view>
      
      <scroll-view class="recent-scroll" scroll-x="true">
        <view 
          class="recent-item"
          v-for="achievement in recentUnlocks"
          :key="achievement.id"
          @click="viewAchievementDetail(achievement)"
        >
          <text class="recent-icon">{{ achievement.icon }}</text>
          <text class="recent-name">{{ achievement.name }}</text>
          <text class="recent-time">{{ formatRecentTime(achievement.unlockedAt) }}</text>
        </view>
      </scroll-view>
    </view>

    <!-- 成就详情模态框 -->
    <view class="achievement-modal" v-if="showModal" @click="closeModal">
      <view class="modal-content" @click.stop>
        <view class="modal-header">
          <view class="modal-icon-container" :class="selectedAchievement?.rarity">
            <text class="modal-icon">{{ selectedAchievement?.icon }}</text>
            <view class="modal-glow"></view>
          </view>
          <text class="modal-title">{{ selectedAchievement?.name }}</text>
          <view class="modal-rarity" :class="selectedAchievement?.rarity">
            {{ getRarityText(selectedAchievement?.rarity) }}
          </view>
        </view>
        
        <view class="modal-body">
          <text class="modal-description">{{ selectedAchievement?.description }}</text>
          
          <view class="modal-details">
            <view class="detail-item">
              <text class="detail-label">奖励点数</text>
              <text class="detail-value">{{ selectedAchievement?.points }} 点</text>
            </view>
            
            <view class="detail-item" v-if="selectedAchievement?.unlocked">
              <text class="detail-label">解锁时间</text>
              <text class="detail-value">{{ formatUnlockTime(selectedAchievement?.unlockedAt) }}</text>
            </view>
            
            <view class="detail-item" v-if="!selectedAchievement?.unlocked">
              <text class="detail-label">完成进度</text>
              <text class="detail-value">{{ selectedAchievement?.progress || 0 }}/{{ selectedAchievement?.target }}</text>
            </view>
            
            <view class="detail-item">
              <text class="detail-label">稀有度</text>
              <text class="detail-value">{{ getRarityText(selectedAchievement?.rarity) }}</text>
            </view>
          </view>
          
          <view class="modal-tips" v-if="!selectedAchievement?.unlocked">
            <text class="tips-title">解锁提示</text>
            <text class="tips-content">{{ selectedAchievement?.hint }}</text>
          </view>
        </view>
        
        <view class="modal-footer">
          <button class="modal-close" @click="closeModal">关闭</button>
          <button 
            class="modal-share" 
            v-if="selectedAchievement?.unlocked"
            @click="shareAchievement"
          >
            分享成就
          </button>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

// 类型定义
interface Achievement {
  id: number
  name: string
  description: string
  icon: string
  points: number
  rarity: 'common' | 'rare' | 'epic' | 'legendary'
  category: string
  unlocked: boolean
  unlockedAt?: string
  progress?: number
  target?: number
  hint: string
}

interface AchievementStats {
  total: number
  unlocked: number
  points: number
  rank: string
}

interface Level {
  name: string
  requiredPoints: number
}

interface Category {
  key: string
  name: string
  icon: string
}

// 响应式数据
const selectedCategory = ref('all')
const showModal = ref(false)
const selectedAchievement = ref<Achievement | null>(null)

const achievementStats = ref<AchievementStats>({
  total: 48,
  unlocked: 12,
  points: 850,
  rank: '情绪探索者'
})

const categories: Category[] = [
  { key: 'all', name: '全部', icon: '🏆' },
  { key: 'record', name: '记录', icon: '📝' },
  { key: 'analysis', name: '分析', icon: '📊' },
  { key: 'streak', name: '坚持', icon: '🔥' },
  { key: 'social', name: '社交', icon: '👥' },
  { key: 'milestone', name: '里程碑', icon: '🎯' },
  { key: 'special', name: '特殊', icon: '⭐' }
]

const levels: Level[] = [
  { name: '情绪新手', requiredPoints: 0 },
  { name: '情绪学徒', requiredPoints: 100 },
  { name: '情绪探索者', requiredPoints: 500 },
  { name: '情绪分析师', requiredPoints: 1000 },
  { name: '情绪大师', requiredPoints: 2000 },
  { name: '情绪导师', requiredPoints: 5000 }
]

const achievements = ref<Achievement[]>([
  {
    id: 1,
    name: '初次记录',
    description: '完成第一次情绪记录',
    icon: '🌱',
    points: 10,
    rarity: 'common',
    category: 'record',
    unlocked: true,
    unlockedAt: '2024-06-01T10:30:00Z',
    hint: '开始你的情绪记录之旅'
  },
  {
    id: 2,
    name: '坚持一周',
    description: '连续7天记录情绪',
    icon: '🔥',
    points: 50,
    rarity: 'rare',
    category: 'streak',
    unlocked: true,
    unlockedAt: '2024-06-08T09:15:00Z',
    hint: '保持记录的习惯'
  },
  {
    id: 3,
    name: 'AI分析师',
    description: '使用AI分析功能10次',
    icon: '🤖',
    points: 30,
    rarity: 'common',
    category: 'analysis',
    unlocked: false,
    progress: 6,
    target: 10,
    hint: '多使用AI分析功能了解自己'
  },
  {
    id: 4,
    name: '情绪光谱',
    description: '记录所有7种基础情绪',
    icon: '🌈',
    points: 80,
    rarity: 'epic',
    category: 'milestone',
    unlocked: false,
    progress: 5,
    target: 7,
    hint: '体验更多元的情绪'
  },
  {
    id: 5,
    name: '深度思考者',
    description: '完成50次深度分析',
    icon: '🧠',
    points: 100,
    rarity: 'epic',
    category: 'analysis',
    unlocked: false,
    progress: 23,
    target: 50,
    hint: '深入探索内心世界'
  },
  {
    id: 6,
    name: '月度坚持者',
    description: '连续30天记录情绪',
    icon: '📅',
    points: 200,
    rarity: 'legendary',
    category: 'streak',
    unlocked: false,
    progress: 18,
    target: 30,
    hint: '养成长期记录的好习惯'
  },
  {
    id: 7,
    name: '社交达人',
    description: '分享成就5次',
    icon: '📢',
    points: 40,
    rarity: 'rare',
    category: 'social',
    unlocked: true,
    unlockedAt: '2024-06-15T14:20:00Z',
    hint: '与朋友分享你的成长'
  },
  {
    id: 8,
    name: '午夜记录者',
    description: '在午夜12点记录情绪',
    icon: '🌙',
    points: 25,
    rarity: 'rare',
    category: 'special',
    unlocked: false,
    hint: '在特殊时刻记录特殊心情'
  }
])

const recentUnlocks = ref<Achievement[]>([
  {
    id: 7,
    name: '社交达人',
    icon: '📢',
    unlockedAt: '2024-06-15T14:20:00Z'
  },
  {
    id: 2,
    name: '坚持一周',
    icon: '🔥',
    unlockedAt: '2024-06-08T09:15:00Z'
  }
])

// 计算属性
const filteredAchievements = computed(() => {
  if (selectedCategory.value === 'all') {
    return achievements.value
  }
  return achievements.value.filter(a => a.category === selectedCategory.value)
})

const currentLevel = computed(() => {
  const points = achievementStats.value.points
  for (let i = levels.length - 1; i >= 0; i--) {
    if (points >= levels[i].requiredPoints) {
      return levels[i]
    }
  }
  return levels[0]
})

const nextLevel = computed(() => {
  const currentIndex = levels.findIndex(l => l.name === currentLevel.value.name)
  return currentIndex < levels.length - 1 ? levels[currentIndex + 1] : levels[levels.length - 1]
})

const levelProgress = computed(() => {
  const points = achievementStats.value.points
  const currentPoints = currentLevel.value.requiredPoints
  const nextPoints = nextLevel.value.requiredPoints
  
  if (currentPoints === nextPoints) return 100
  
  return ((points - currentPoints) / (nextPoints - currentPoints)) * 100
})

// 方法
const selectCategory = (category: string) => {
  selectedCategory.value = category
}

const getRarityText = (rarity?: string) => {
  const rarityMap = {
    common: '普通',
    rare: '稀有',
    epic: '史诗',
    legendary: '传说'
  }
  return rarityMap[rarity as keyof typeof rarityMap] || '普通'
}

const formatUnlockTime = (timeStr?: string) => {
  if (!timeStr) return ''
  
  const date = new Date(timeStr)
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  const days = Math.floor(diff / (1000 * 60 * 60 * 24))
  
  if (days === 0) {
    return '今天解锁'
  } else if (days === 1) {
    return '昨天解锁'
  } else if (days < 7) {
    return `${days}天前解锁`
  } else {
    return date.toLocaleDateString('zh-CN')
  }
}

const formatRecentTime = (timeStr?: string) => {
  if (!timeStr) return ''
  
  const date = new Date(timeStr)
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  const hours = Math.floor(diff / (1000 * 60 * 60))
  const days = Math.floor(hours / 24)
  
  if (hours < 1) {
    return '刚刚'
  } else if (hours < 24) {
    return `${hours}小时前`
  } else {
    return `${days}天前`
  }
}

const viewAchievementDetail = (achievement: Achievement) => {
  selectedAchievement.value = achievement
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  selectedAchievement.value = null
}

const shareAchievement = () => {
  const achievement = selectedAchievement.value
  if (!achievement) return
  
  uni.share({
    provider: 'weixin',
    scene: 'WXSceneSession',
    type: 0,
    href: '',
    title: `我获得了成就：${achievement.name}`,
    summary: achievement.description,
    imageUrl: '',
    success: () => {
      uni.showToast({
        title: '分享成功',
        icon: 'success'
      })
      closeModal()
    },
    fail: () => {
      uni.showToast({
        title: '分享失败',
        icon: 'none'
      })
    }
  })
}

const viewAllRecent = () => {
  uni.showModal({
    title: '最近解锁',
    content: '查看所有最近解锁的成就',
    showCancel: false
  })
}

// 生命周期
onMounted(() => {
  // 加载成就数据
  console.log('加载成就系统数据')
})
</script>

<style scoped>
/* 页面特定变量 */
:root {
  --primary-color: #4A90E2;
  --glass-bg: rgba(255, 255, 255, 0.25);
  --glass-border: rgba(255, 255, 255, 0.3);
  --text-primary: #2c3e50;
  --text-secondary: #7f8c8d;
  --success-color: #27ae60;
  --warning-color: #f39c12;
  --rare-color: #3498db;
  --epic-color: #9b59b6;
  --legendary-color: #f39c12;
}

.container {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  padding: 0 30rpx 120rpx;
}

/* 页面头部 */
.page-header {
  padding: 40rpx 0 30rpx;
  text-align: center;
}

.page-title {
  display: block;
  font-size: 42rpx;
  font-weight: 800;
  background: linear-gradient(45deg, var(--primary-color), #667eea);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin-bottom: 16rpx;
}

.page-subtitle {
  display: block;
  font-size: 28rpx;
  color: var(--text-secondary);
  opacity: 0.8;
}

/* 成就概览 */
.achievement-overview {
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  padding: 40rpx;
  margin-bottom: 40rpx;
  box-shadow: 0 8rpx 32rpx rgba(0, 0, 0, 0.1);
}

.overview-card {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 32rpx;
  margin-bottom: 32rpx;
}

.overview-item {
  text-align: center;
}

.overview-number {
  display: block;
  font-size: 36rpx;
  font-weight: 800;
  color: var(--primary-color);
  margin-bottom: 8rpx;
}

.overview-label {
  display: block;
  font-size: 24rpx;
  color: var(--text-secondary);
}

/* 等级进度 */
.level-progress {
  margin-top: 32rpx;
}

.progress-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16rpx;
}

.current-level,
.next-level {
  font-size: 26rpx;
  font-weight: 600;
  color: var(--text-primary);
}

.progress-bar {
  height: 16rpx;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 8rpx;
  overflow: hidden;
  margin-bottom: 12rpx;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--primary-color), #667eea);
  border-radius: 8rpx;
  transition: width 0.3s ease;
}

.progress-text {
  display: block;
  text-align: center;
  font-size: 22rpx;
  color: var(--text-secondary);
}

/* 分类筛选 */
.category-filter {
  margin-bottom: 40rpx;
}

.filter-scroll {
  white-space: nowrap;
}

.filter-item {
  display: inline-flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
  padding: 20rpx 24rpx;
  margin-right: 16rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 20rpx;
  transition: all 0.3s ease;
}

.filter-item.active {
  background: rgba(74, 144, 226, 0.2);
  border-color: var(--primary-color);
  transform: translateY(-4rpx);
}

.filter-icon {
  font-size: 28rpx;
}

.filter-name {
  font-size: 22rpx;
  color: var(--text-primary);
  font-weight: 500;
}

/* 成就列表 */
.achievements-list {
  display: flex;
  flex-direction: column;
  gap: 24rpx;
  margin-bottom: 40rpx;
}

.achievement-item {
  display: flex;
  align-items: center;
  gap: 24rpx;
  padding: 32rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.achievement-item.unlocked {
  background: rgba(39, 174, 96, 0.1);
  border-color: rgba(39, 174, 96, 0.3);
}

.achievement-item.locked {
  opacity: 0.7;
}

.achievement-item.rare {
  box-shadow: 0 0 20rpx rgba(52, 152, 219, 0.3);
}

.achievement-item.epic {
  box-shadow: 0 0 20rpx rgba(155, 89, 182, 0.3);
}

.achievement-item.legendary {
  box-shadow: 0 0 20rpx rgba(243, 156, 18, 0.3);
}

.achievement-icon-container {
  position: relative;
  width: 80rpx;
  height: 80rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.achievement-icon {
  font-size: 48rpx;
  z-index: 2;
}

.rarity-glow {
  position: absolute;
  inset: -8rpx;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(74, 144, 226, 0.3), transparent);
  animation: glow 2s ease-in-out infinite alternate;
}

.unlock-badge {
  position: absolute;
  top: -8rpx;
  right: -8rpx;
  width: 32rpx;
  height: 32rpx;
  background: var(--success-color);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18rpx;
  font-weight: bold;
  z-index: 3;
}

.achievement-info {
  flex: 1;
}

.achievement-name {
  display: block;
  font-size: 28rpx;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 8rpx;
}

.achievement-desc {
  display: block;
  font-size: 24rpx;
  color: var(--text-secondary);
  line-height: 1.4;
  margin-bottom: 12rpx;
}

.achievement-progress {
  display: flex;
  align-items: center;
  gap: 16rpx;
  margin-bottom: 8rpx;
}

.progress-bar.mini {
  height: 8rpx;
  flex: 1;
}

.progress-text.mini {
  font-size: 20rpx;
  color: var(--text-secondary);
  min-width: 80rpx;
}

.unlock-time {
  font-size: 20rpx;
  color: var(--success-color);
}

.achievement-reward {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
}

.reward-points {
  font-size: 24rpx;
  font-weight: 600;
  color: var(--primary-color);
}

.rarity-badge {
  padding: 4rpx 12rpx;
  border-radius: 12rpx;
  font-size: 18rpx;
  font-weight: 600;
}

.rarity-badge.common {
  background: rgba(149, 165, 166, 0.2);
  color: #95a5a6;
}

.rarity-badge.rare {
  background: rgba(52, 152, 219, 0.2);
  color: var(--rare-color);
}

.rarity-badge.epic {
  background: rgba(155, 89, 182, 0.2);
  color: var(--epic-color);
}

.rarity-badge.legendary {
  background: rgba(243, 156, 18, 0.2);
  color: var(--legendary-color);
}

/* 最近解锁 */
.recent-unlocks {
  margin-bottom: 40rpx;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24rpx;
}

.section-title {
  font-size: 30rpx;
  font-weight: 600;
  color: var(--text-primary);
}

.view-all {
  font-size: 24rpx;
  color: var(--primary-color);
}

.recent-scroll {
  white-space: nowrap;
}

.recent-item {
  display: inline-flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
  padding: 24rpx;
  margin-right: 16rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 20rpx;
  min-width: 120rpx;
}

.recent-icon {
  font-size: 36rpx;
}

.recent-name {
  font-size: 22rpx;
  color: var(--text-primary);
  font-weight: 500;
  text-align: center;
}

.recent-time {
  font-size: 18rpx;
  color: var(--text-secondary);
}

/* 成就详情模态框 */
.achievement-modal {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 40rpx;
}

.modal-content {
  background: var(--glass-bg);
  backdrop-filter: blur(30rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 30rpx;
  max-width: 600rpx;
  width: 100%;
  overflow: hidden;
}

.modal-header {
  padding: 40rpx;
  text-align: center;
  background: linear-gradient(135deg, rgba(74, 144, 226, 0.1), rgba(102, 126, 234, 0.1));
}

.modal-icon-container {
  position: relative;
  width: 120rpx;
  height: 120rpx;
  margin: 0 auto 24rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-icon {
  font-size: 80rpx;
  z-index: 2;
}

.modal-glow {
  position: absolute;
  inset: -16rpx;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(74, 144, 226, 0.4), transparent);
  animation: glow 2s ease-in-out infinite alternate;
}

.modal-title {
  display: block;
  font-size: 36rpx;
  font-weight: 800;
  color: var(--text-primary);
  margin-bottom: 16rpx;
}

.modal-rarity {
  padding: 8rpx 20rpx;
  border-radius: 20rpx;
  font-size: 24rpx;
  font-weight: 600;
  display: inline-block;
}

.modal-body {
  padding: 40rpx;
}

.modal-description {
  display: block;
  font-size: 28rpx;
  color: var(--text-secondary);
  line-height: 1.5;
  margin-bottom: 32rpx;
  text-align: center;
}

.modal-details {
  display: flex;
  flex-direction: column;
  gap: 24rpx;
  margin-bottom: 32rpx;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx 0;
  border-bottom: 1rpx solid rgba(255, 255, 255, 0.2);
}

.detail-label {
  font-size: 26rpx;
  color: var(--text-secondary);
}

.detail-value {
  font-size: 26rpx;
  color: var(--text-primary);
  font-weight: 600;
}

.modal-tips {
  padding: 24rpx;
  background: rgba(74, 144, 226, 0.1);
  border-radius: 16rpx;
  border: 2rpx solid rgba(74, 144, 226, 0.2);
}

.tips-title {
  display: block;
  font-size: 24rpx;
  color: var(--primary-color);
  font-weight: 600;
  margin-bottom: 12rpx;
}

.tips-content {
  display: block;
  font-size: 22rpx;
  color: var(--text-secondary);
  line-height: 1.4;
}

.modal-footer {
  display: flex;
  gap: 24rpx;
  padding: 40rpx;
  border-top: 1rpx solid rgba(255, 255, 255, 0.2);
}

.modal-close,
.modal-share {
  flex: 1;
  height: 80rpx;
  border: none;
  border-radius: 20rpx;
  font-size: 28rpx;
  font-weight: 600;
  transition: all 0.3s ease;
}

.modal-close {
  background: rgba(255, 255, 255, 0.3);
  color: var(--text-primary);
}

.modal-share {
  background: linear-gradient(45deg, var(--primary-color), #667eea);
  color: white;
}

.modal-close:active,
.modal-share:active {
  transform: scale(0.95);
}

/* 动画效果 */
@keyframes glow {
  from {
    opacity: 0.5;
    transform: scale(1);
  }
  to {
    opacity: 1;
    transform: scale(1.1);
  }
}
</style> 