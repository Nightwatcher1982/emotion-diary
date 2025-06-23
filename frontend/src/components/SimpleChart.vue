<template>
  <view class="chart-container">
    <!-- 折线图 -->
    <view v-if="chartType === 'line'" class="line-chart">
      <view class="chart-title">{{ title || '情绪趋势' }}</view>
      <view class="line-chart-area">
        <view class="y-axis">
          <text v-for="n in 11" :key="n" class="y-label">{{ 10 - (n - 1) }}</text>
        </view>
        <view class="chart-content">
          <svg class="line-svg" viewBox="0 0 300 200">
            <defs>
              <linearGradient id="gradient" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" style="stop-color:#4A90E2;stop-opacity:0.3" />
                <stop offset="100%" style="stop-color:#4A90E2;stop-opacity:0.05" />
              </linearGradient>
            </defs>
            <polyline 
              :points="getLinePoints()" 
              fill="none" 
              stroke="#4A90E2" 
              stroke-width="2"
            />
            <polygon 
              :points="getAreaPoints()" 
              fill="url(#gradient)"
            />
            <circle 
              v-for="(point, index) in getCirclePoints()" 
              :key="index"
              :cx="point.x" 
              :cy="point.y" 
              r="3" 
              fill="#4A90E2"
              @click="onPointClick(index)"
            />
          </svg>
          <view class="x-axis">
            <text v-for="(item, index) in data" :key="index" class="x-label">
              {{ item.name || item.label }}
            </text>
          </view>
        </view>
      </view>
    </view>

    <!-- 柱状图 -->
    <view v-else-if="chartType === 'bar'" class="bar-chart">
      <view class="chart-title">{{ title || '数据统计' }}</view>
      <view class="bar-chart-area">
        <view class="bars-container">
          <view 
            v-for="(item, index) in data" 
            :key="index" 
            class="bar-item"
            @click="onBarClick(index)"
          >
            <view class="bar-value-top">{{ item.value || item.count }}</view>
            <view 
              class="bar" 
              :style="{ 
                height: getBarHeight(item), 
                backgroundColor: item.color || '#4A90E2' 
              }"
            ></view>
            <text class="bar-label">{{ item.name || item.label }}</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 饼图 -->
    <view v-else-if="chartType === 'pie'" class="pie-chart">
      <view class="chart-title">{{ title || '分布统计' }}</view>
      <view class="pie-chart-area">
        <view class="pie-container">
          <svg class="pie-svg" viewBox="0 0 200 200">
            <g v-for="(segment, index) in getPieSegments()" :key="index">
              <path 
                :d="segment.path" 
                :fill="segment.color"
                @click="onPieClick(index)"
              />
            </g>
          </svg>
        </view>
        <view class="pie-legend">
          <view 
            v-for="(item, index) in data" 
            :key="index" 
            class="legend-item"
          >
            <view 
              class="legend-color" 
              :style="{ backgroundColor: item.color }"
            ></view>
            <text class="legend-text">{{ item.name }} ({{ item.percentage || item.value }}%)</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 热力图 -->
    <view v-else-if="chartType === 'heatmap'" class="heatmap-chart">
      <view class="chart-title">{{ title || '活跃度热力图' }}</view>
      <view class="heatmap-area">
        <view class="heatmap-grid">
          <view 
            v-for="(row, rowIndex) in getHeatmapData()" 
            :key="rowIndex" 
            class="heatmap-row"
          >
            <view 
              v-for="(cell, colIndex) in row" 
              :key="colIndex"
              class="heatmap-cell"
              :style="{ backgroundColor: getHeatmapColor(cell.value) }"
              @click="onHeatmapClick(rowIndex, colIndex)"
            >
              <text class="cell-value">{{ cell.value.toFixed(1) }}</text>
            </view>
          </view>
        </view>
        <view class="heatmap-labels">
          <view class="x-labels">
            <text v-for="hour in hours" :key="hour" class="hour-label">{{ hour }}</text>
          </view>
          <view class="y-labels">
            <text v-for="day in days" :key="day" class="day-label">{{ day }}</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed } from 'vue'

// Props
interface Props {
  chartType: 'line' | 'bar' | 'pie' | 'heatmap'
  data: any[]
  title?: string
  width?: string
  height?: string
}

const props = withDefaults(defineProps<Props>(), {
  width: '100%',
  height: '300rpx'
})

// Emits
const emit = defineEmits(['chartClick'])

// 常量
const hours = ['6-8', '8-10', '10-12', '12-14', '14-16', '16-18', '18-20', '20-22', '22-24']
const days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']

// 折线图相关方法
const getLinePoints = () => {
  if (!props.data.length) return ''
  
  const width = 300
  const height = 200
  const stepX = width / (props.data.length - 1)
  
  return props.data.map((item, index) => {
    const x = index * stepX
    const y = height - (height * (item.value || item.mood) / 10)
    return `${x},${y}`
  }).join(' ')
}

const getAreaPoints = () => {
  const linePoints = getLinePoints()
  if (!linePoints) return ''
  
  return `0,200 ${linePoints} 300,200`
}

const getCirclePoints = () => {
  if (!props.data.length) return []
  
  const width = 300
  const height = 200
  const stepX = width / (props.data.length - 1)
  
  return props.data.map((item, index) => ({
    x: index * stepX,
    y: height - (height * (item.value || item.mood) / 10)
  }))
}

// 柱状图相关方法
const getBarHeight = (item: any) => {
  if (!props.data.length) return '0%'
  
  const values = props.data.map(d => d.value || d.count || 0).filter(v => v > 0)
  if (values.length === 0) return '0%'
  
  const maxValue = Math.max(...values)
  const itemValue = item.value || item.count || 0
  
  if (maxValue === 0) return '0%'
  
  const percentage = (itemValue / maxValue) * 80 // 最大80%高度，留出空间给标签
  return `${Math.max(percentage, 2)}%`
}

// 饼图相关方法
const getPieSegments = () => {
  if (!props.data.length) return []
  
  const total = props.data.reduce((sum, item) => sum + (item.percentage || item.value || 0), 0)
  if (total === 0) return []
  
  let currentAngle = -Math.PI / 2 // 从顶部开始
  
  return props.data.map((item, index) => {
    const value = item.percentage || item.value || 0
    const percentage = value / total
    const angle = percentage * 2 * Math.PI
    
    if (angle === 0) return { path: '', color: item.color }
    
    const centerX = 100
    const centerY = 100
    const radius = 70
    
    const x1 = centerX + radius * Math.cos(currentAngle)
    const y1 = centerY + radius * Math.sin(currentAngle)
    const x2 = centerX + radius * Math.cos(currentAngle + angle)
    const y2 = centerY + radius * Math.sin(currentAngle + angle)
    
    const largeArcFlag = angle > Math.PI ? 1 : 0
    
    let path
    if (percentage >= 0.999) {
      // 如果是完整的圆（100%或接近100%）
      path = `M ${centerX} ${centerY - radius} A ${radius} ${radius} 0 1 1 ${centerX - 1} ${centerY - radius} Z`
    } else {
      path = [
        `M ${centerX} ${centerY}`,
        `L ${x1} ${y1}`,
        `A ${radius} ${radius} 0 ${largeArcFlag} 1 ${x2} ${y2}`,
        `Z`
      ].join(' ')
    }
    
    currentAngle += angle
    
    return {
      path,
      color: item.color || '#4A90E2',
      percentage: Math.round(percentage * 100)
    }
  }).filter(segment => segment.path !== '')
}

// 热力图相关方法
const getHeatmapData = () => {
  // 生成7x9的网格数据
  const grid = []
  for (let day = 0; day < 7; day++) {
    const row = []
    for (let hour = 0; hour < 9; hour++) {
      // 从props.data中查找对应的数据，或生成随机数据
      const dataPoint = props.data.find(d => d.day === day && d.hour === hour)
      row.push({
        value: dataPoint ? dataPoint.intensity : Math.random()
      })
    }
    grid.push(row)
  }
  return grid
}

const getHeatmapColor = (intensity: number) => {
  const alpha = Math.max(0.1, Math.min(1, intensity))
  return `rgba(74, 144, 226, ${alpha})`
}

// 事件处理
const onPointClick = (index: number) => {
  emit('chartClick', { type: 'point', index, data: props.data[index] })
}

const onBarClick = (index: number) => {
  emit('chartClick', { type: 'bar', index, data: props.data[index] })
}

const onPieClick = (index: number) => {
  emit('chartClick', { type: 'pie', index, data: props.data[index] })
}

const onHeatmapClick = (row: number, col: number) => {
  emit('chartClick', { type: 'heatmap', row, col, day: days[row], hour: hours[col] })
}
</script>

<style scoped>
.chart-container {
  width: 100%;
  background: white;
  border-radius: 15rpx;
  padding: 30rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.05);
}

.chart-title {
  font-size: 32rpx;
  font-weight: bold;
  color: #333;
  text-align: center;
  margin-bottom: 30rpx;
}

/* 折线图样式 */
.line-chart-area {
  display: flex;
  height: 300rpx;
}

.y-axis {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  width: 60rpx;
  padding-right: 20rpx;
}

.y-label {
  font-size: 20rpx;
  color: #666;
  text-align: right;
}

.chart-content {
  flex: 1;
  position: relative;
}

.line-svg {
  width: 100%;
  height: 240rpx;
}

.x-axis {
  display: flex;
  justify-content: space-between;
  margin-top: 20rpx;
}

.x-label {
  font-size: 20rpx;
  color: #666;
  text-align: center;
}

/* 柱状图样式 */
.bar-chart-area {
  height: 350rpx;
  padding: 20rpx;
}

.bars-container {
  display: flex;
  justify-content: space-around;
  align-items: flex-end;
  height: 100%;
  position: relative;
}

.bar-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  flex: 1;
  margin: 0 8rpx;
  height: 100%;
  justify-content: flex-end;
}

.bar-value-top {
  font-size: 20rpx;
  color: #333;
  font-weight: bold;
  margin-bottom: 8rpx;
  min-height: 30rpx;
  display: flex;
  align-items: center;
}

.bar {
  width: 100%;
  max-width: 50rpx;
  min-height: 10rpx;
  border-radius: 6rpx 6rpx 0 0;
  transition: all 0.3s ease;
  margin-bottom: 10rpx;
  position: relative;
}

.bar:hover {
  opacity: 0.8;
  transform: scale(1.05);
}

.bar-label {
  font-size: 18rpx;
  color: #666;
  text-align: center;
  line-height: 1.2;
  max-width: 80rpx;
  word-break: break-all;
}

/* 饼图样式 */
.pie-chart-area {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20rpx;
}

.pie-container {
  width: 280rpx;
  height: 280rpx;
  margin-bottom: 30rpx;
}

.pie-svg {
  width: 100%;
  height: 100%;
}

.pie-svg path {
  stroke: white;
  stroke-width: 2;
  cursor: pointer;
  transition: all 0.3s ease;
}

.pie-svg path:hover {
  opacity: 0.8;
  transform: scale(1.02);
  transform-origin: center;
}

.pie-legend {
  display: flex;
  flex-direction: column;
  gap: 12rpx;
  width: 100%;
  max-width: 400rpx;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 12rpx;
  padding: 8rpx;
  border-radius: 8rpx;
  transition: background-color 0.3s ease;
}

.legend-item:hover {
  background-color: #f5f5f5;
}

.legend-color {
  width: 16rpx;
  height: 16rpx;
  border-radius: 50%;
  flex-shrink: 0;
}

.legend-text {
  font-size: 22rpx;
  color: #666;
  flex: 1;
}

/* 热力图样式 */
.heatmap-area {
  position: relative;
}

.heatmap-grid {
  display: flex;
  flex-direction: column;
  gap: 4rpx;
  margin: 40rpx 0 40rpx 80rpx;
}

.heatmap-row {
  display: flex;
  gap: 4rpx;
}

.heatmap-cell {
  width: 60rpx;
  height: 30rpx;
  border-radius: 4rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
}

.cell-value {
  font-size: 18rpx;
  color: white;
  font-weight: bold;
}

.heatmap-labels {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

.x-labels {
  display: flex;
  justify-content: space-between;
  margin-left: 80rpx;
  margin-bottom: 20rpx;
}

.hour-label {
  font-size: 20rpx;
  color: #666;
  width: 60rpx;
  text-align: center;
}

.y-labels {
  position: absolute;
  left: 0;
  top: 40rpx;
  display: flex;
  flex-direction: column;
  gap: 8rpx;
  width: 70rpx;
}

.day-label {
  font-size: 20rpx;
  color: #666;
  text-align: right;
  height: 30rpx;
  line-height: 30rpx;
}
</style> 