<template>
  <view class="container">
    <!-- 页面头部 -->
    <view class="page-header">
      <text class="page-title">提醒设置</text>
      <text class="page-subtitle">设置个性化的情绪记录提醒</text>
    </view>

    <!-- 主开关 -->
    <view class="main-switch-card">
      <view class="switch-content">
        <view class="switch-info">
          <text class="switch-title">每日提醒</text>
          <text class="switch-desc">开启后将在设定时间提醒您记录情绪</text>
        </view>
        <switch 
          :checked="reminderSettings.enabled" 
          @change="toggleMainReminder"
          color="var(--primary-color)"
          class="main-switch"
        />
      </view>
    </view>

    <!-- 提醒时间设置 -->
    <view class="settings-section" v-if="reminderSettings.enabled">
      <text class="section-title">提醒时间</text>
      
      <view class="time-slots">
        <view 
          class="time-slot" 
          v-for="(slot, index) in reminderSettings.timeSlots" 
          :key="index"
          :class="{ active: slot.enabled }"
        >
          <view class="slot-header">
            <view class="slot-info">
              <text class="slot-name">{{ slot.name }}</text>
              <text class="slot-time">{{ slot.time }}</text>
            </view>
            <switch 
              :checked="slot.enabled" 
              @change="(e) => toggleTimeSlot(index, e)"
              color="var(--primary-color)"
              size="mini"
            />
          </view>
          
          <view class="slot-details" v-if="slot.enabled">
            <picker 
              mode="time" 
              :value="slot.time" 
              @change="(e) => updateTime(index, e)"
              class="time-picker"
            >
              <view class="picker-content">
                <text class="picker-label">时间</text>
                <text class="picker-value">{{ slot.time }}</text>
                <text class="picker-arrow">></text>
              </view>
            </picker>
            
            <view class="repeat-days">
              <text class="repeat-label">重复</text>
              <view class="days-selector">
                <text 
                  v-for="(day, dayIndex) in weekDays" 
                  :key="dayIndex"
                  class="day-item"
                  :class="{ selected: slot.repeatDays.includes(dayIndex) }"
                  @click="toggleRepeatDay(index, dayIndex)"
                >
                  {{ day }}
                </text>
              </view>
            </view>
          </view>
        </view>
      </view>

      <!-- 添加新提醒 -->
      <view class="add-reminder" @click="addNewReminder">
        <text class="add-icon">+</text>
        <text class="add-text">添加新提醒</text>
      </view>
    </view>

    <!-- 提醒内容设置 -->
    <view class="settings-section" v-if="reminderSettings.enabled">
      <text class="section-title">提醒内容</text>
      
      <view class="content-options">
        <view 
          class="content-item"
          v-for="(content, index) in reminderContents"
          :key="index"
          :class="{ selected: reminderSettings.selectedContent === index }"
          @click="selectReminderContent(index)"
        >
          <view class="content-preview">
            <text class="content-title">{{ content.title }}</text>
            <text class="content-text">{{ content.preview }}</text>
          </view>
          <view class="content-indicator">
            <text class="indicator" v-if="reminderSettings.selectedContent === index">✓</text>
          </view>
        </view>
        
        <!-- 自定义内容 -->
        <view class="custom-content">
          <text class="custom-label">自定义提醒内容</text>
          <textarea 
            v-model="reminderSettings.customContent"
            placeholder="输入您的专属提醒内容..."
            class="custom-input"
            maxlength="100"
          />
          <text class="char-count">{{ reminderSettings.customContent.length }}/100</text>
        </view>
      </view>
    </view>

    <!-- 智能提醒设置 -->
    <view class="settings-section" v-if="reminderSettings.enabled">
      <text class="section-title">智能提醒</text>
      
      <view class="smart-options">
        <view class="smart-item">
          <view class="smart-info">
            <text class="smart-title">情绪低落提醒</text>
            <text class="smart-desc">检测到连续低情绪时主动提醒</text>
          </view>
          <switch 
            :checked="reminderSettings.smartReminders.lowMood" 
            @change="toggleSmartReminder('lowMood')"
            color="var(--primary-color)"
            size="mini"
          />
        </view>
        
        <view class="smart-item">
          <view class="smart-info">
            <text class="smart-title">长期未记录提醒</text>
            <text class="smart-desc">超过3天未记录时发送提醒</text>
          </view>
          <switch 
            :checked="reminderSettings.smartReminders.longAbsence" 
            @change="toggleSmartReminder('longAbsence')"
            color="var(--primary-color)"
            size="mini"
          />
        </view>
        
        <view class="smart-item">
          <view class="smart-info">
            <text class="smart-title">成就达成提醒</text>
            <text class="smart-desc">获得新成就时发送祝贺提醒</text>
          </view>
          <switch 
            :checked="reminderSettings.smartReminders.achievement" 
            @change="toggleSmartReminder('achievement')"
            color="var(--primary-color)"
            size="mini"
          />
        </view>
      </view>
    </view>

    <!-- 提醒方式设置 -->
    <view class="settings-section" v-if="reminderSettings.enabled">
      <text class="section-title">提醒方式</text>
      
      <view class="method-options">
        <view 
          class="method-item"
          v-for="(method, index) in reminderMethods"
          :key="index"
          :class="{ selected: reminderSettings.methods.includes(index) }"
          @click="toggleReminderMethod(index)"
        >
          <text class="method-icon">{{ method.icon }}</text>
          <view class="method-info">
            <text class="method-title">{{ method.title }}</text>
            <text class="method-desc">{{ method.description }}</text>
          </view>
          <view class="method-indicator">
            <text class="indicator" v-if="reminderSettings.methods.includes(index)">✓</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 预览提醒 -->
    <view class="preview-section" v-if="reminderSettings.enabled">
      <button class="preview-button" @click="previewReminder">
        <text class="preview-icon">👁️</text>
        <text class="preview-text">预览提醒效果</text>
      </button>
    </view>

    <!-- 保存按钮 -->
    <view class="save-section">
      <button class="save-button" @click="saveSettings">
        保存设置
      </button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'

// 类型定义
interface TimeSlot {
  name: string
  time: string
  enabled: boolean
  repeatDays: number[]
}

interface ReminderSettings {
  enabled: boolean
  timeSlots: TimeSlot[]
  selectedContent: number
  customContent: string
  smartReminders: {
    lowMood: boolean
    longAbsence: boolean
    achievement: boolean
  }
  methods: number[]
}

// 响应式数据
const reminderSettings = reactive<ReminderSettings>({
  enabled: true,
  timeSlots: [
    {
      name: '早安提醒',
      time: '09:00',
      enabled: true,
      repeatDays: [1, 2, 3, 4, 5, 6, 0] // 周一到周日
    },
    {
      name: '午间提醒',
      time: '14:00',
      enabled: false,
      repeatDays: [1, 2, 3, 4, 5]
    },
    {
      name: '晚间提醒',
      time: '21:00',
      enabled: true,
      repeatDays: [1, 2, 3, 4, 5, 6, 0]
    }
  ],
  selectedContent: 0,
  customContent: '',
  smartReminders: {
    lowMood: true,
    longAbsence: true,
    achievement: true
  },
  methods: [0, 1] // 通知和震动
})

const weekDays = ['日', '一', '二', '三', '四', '五', '六']

const reminderContents = ref([
  {
    title: '温馨关怀',
    preview: '记录今天的心情，让每一份情感都被珍视 💝'
  },
  {
    title: '积极鼓励',
    preview: '每一次记录都是成长的脚印，加油！✨'
  },
  {
    title: '简约提醒',
    preview: '该记录情绪了 📝'
  },
  {
    title: '诗意表达',
    preview: '时光荏苒，让我们记录下此刻的心境 🌸'
  }
])

const reminderMethods = ref([
  {
    icon: '🔔',
    title: '通知提醒',
    description: '发送系统通知消息'
  },
  {
    icon: '📳',
    title: '震动提醒',
    description: '设备轻微震动提醒'
  },
  {
    icon: '🔊',
    title: '声音提醒',
    description: '播放提醒铃声'
  },
  {
    icon: '🌟',
    title: '应用角标',
    description: '在应用图标上显示提醒数字'
  }
])

// 方法
const toggleMainReminder = (e: any) => {
  reminderSettings.enabled = e.detail.value
  const message = reminderSettings.enabled ? '已开启每日提醒' : '已关闭每日提醒'
  uni.showToast({
    title: message,
    icon: 'success'
  })
}

const toggleTimeSlot = (index: number, e: any) => {
  reminderSettings.timeSlots[index].enabled = e.detail.value
}

const updateTime = (index: number, e: any) => {
  reminderSettings.timeSlots[index].time = e.detail.value
}

const toggleRepeatDay = (slotIndex: number, dayIndex: number) => {
  const slot = reminderSettings.timeSlots[slotIndex]
  const index = slot.repeatDays.indexOf(dayIndex)
  
  if (index > -1) {
    slot.repeatDays.splice(index, 1)
  } else {
    slot.repeatDays.push(dayIndex)
  }
}

const addNewReminder = () => {
  const newSlot: TimeSlot = {
    name: `提醒 ${reminderSettings.timeSlots.length + 1}`,
    time: '12:00',
    enabled: true,
    repeatDays: [1, 2, 3, 4, 5, 6, 0]
  }
  reminderSettings.timeSlots.push(newSlot)
}

const selectReminderContent = (index: number) => {
  reminderSettings.selectedContent = index
}

const toggleSmartReminder = (type: string) => {
  reminderSettings.smartReminders[type as keyof typeof reminderSettings.smartReminders] = 
    !reminderSettings.smartReminders[type as keyof typeof reminderSettings.smartReminders]
}

const toggleReminderMethod = (index: number) => {
  const methodIndex = reminderSettings.methods.indexOf(index)
  
  if (methodIndex > -1) {
    reminderSettings.methods.splice(methodIndex, 1)
  } else {
    reminderSettings.methods.push(index)
  }
}

const previewReminder = () => {
  const selectedContent = reminderContents.value[reminderSettings.selectedContent]
  const content = reminderSettings.customContent || selectedContent.preview
  
  uni.showModal({
    title: '提醒预览',
    content: content,
    showCancel: false,
    confirmText: '知道了'
  })
}

const saveSettings = () => {
  uni.showLoading({
    title: '保存中...'
  })
  
  // 模拟保存过程
  setTimeout(() => {
    uni.hideLoading()
    uni.showToast({
      title: '设置已保存',
      icon: 'success'
    })
    
    // 返回上一页
    setTimeout(() => {
      uni.navigateBack()
    }, 1500)
  }, 1000)
}
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

/* 主开关卡片 */
.main-switch-card {
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  padding: 40rpx;
  margin-bottom: 40rpx;
  box-shadow: 0 8rpx 32rpx rgba(0, 0, 0, 0.1);
}

.switch-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.switch-info {
  flex: 1;
}

.switch-title {
  display: block;
  font-size: 32rpx;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 8rpx;
}

.switch-desc {
  display: block;
  font-size: 26rpx;
  color: var(--text-secondary);
  line-height: 1.4;
}

.main-switch {
  transform: scale(1.2);
}

/* 设置区域 */
.settings-section {
  margin-bottom: 40rpx;
}

.section-title {
  display: block;
  font-size: 30rpx;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 24rpx;
  padding-left: 16rpx;
}

/* 时间段设置 */
.time-slots {
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  overflow: hidden;
  margin-bottom: 24rpx;
}

.time-slot {
  padding: 32rpx;
  border-bottom: 1rpx solid rgba(255, 255, 255, 0.2);
}

.time-slot:last-child {
  border-bottom: none;
}

.time-slot.active {
  background: rgba(74, 144, 226, 0.1);
}

.slot-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}

.slot-info {
  flex: 1;
}

.slot-name {
  display: block;
  font-size: 28rpx;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 8rpx;
}

.slot-time {
  display: block;
  font-size: 24rpx;
  color: var(--text-secondary);
}

.slot-details {
  padding-top: 20rpx;
  border-top: 1rpx solid rgba(255, 255, 255, 0.2);
}

.time-picker {
  margin-bottom: 24rpx;
}

.picker-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx 0;
}

.picker-label {
  font-size: 26rpx;
  color: var(--text-primary);
}

.picker-value {
  font-size: 26rpx;
  color: var(--primary-color);
  font-weight: 600;
}

.picker-arrow {
  font-size: 24rpx;
  color: var(--text-secondary);
}

.repeat-days {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.repeat-label {
  font-size: 26rpx;
  color: var(--text-primary);
  min-width: 60rpx;
}

.days-selector {
  display: flex;
  gap: 12rpx;
  flex-wrap: wrap;
}

.day-item {
  width: 60rpx;
  height: 60rpx;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24rpx;
  color: var(--text-secondary);
  transition: all 0.3s ease;
}

.day-item.selected {
  background: var(--primary-color);
  color: white;
  transform: scale(1.1);
}

/* 添加提醒按钮 */
.add-reminder {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16rpx;
  padding: 32rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx dashed var(--glass-border);
  border-radius: 25rpx;
  transition: all 0.3s ease;
}

.add-reminder:active {
  transform: scale(0.98);
}

.add-icon {
  font-size: 32rpx;
  color: var(--primary-color);
}

.add-text {
  font-size: 28rpx;
  color: var(--primary-color);
  font-weight: 600;
}

/* 内容选项 */
.content-options {
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  overflow: hidden;
}

.content-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 32rpx;
  border-bottom: 1rpx solid rgba(255, 255, 255, 0.2);
  transition: all 0.3s ease;
}

.content-item:last-child {
  border-bottom: none;
}

.content-item.selected {
  background: rgba(74, 144, 226, 0.1);
}

.content-preview {
  flex: 1;
}

.content-title {
  display: block;
  font-size: 28rpx;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 8rpx;
}

.content-text {
  display: block;
  font-size: 24rpx;
  color: var(--text-secondary);
  line-height: 1.4;
}

.content-indicator {
  width: 40rpx;
  text-align: center;
}

.indicator {
  color: var(--success-color);
  font-size: 28rpx;
  font-weight: bold;
}

/* 自定义内容 */
.custom-content {
  padding: 32rpx;
  border-top: 1rpx solid rgba(255, 255, 255, 0.2);
}

.custom-label {
  display: block;
  font-size: 26rpx;
  color: var(--text-primary);
  margin-bottom: 16rpx;
}

.custom-input {
  width: 100%;
  min-height: 120rpx;
  padding: 20rpx;
  background: rgba(255, 255, 255, 0.5);
  border: 2rpx solid var(--glass-border);
  border-radius: 16rpx;
  font-size: 26rpx;
  color: var(--text-primary);
  line-height: 1.4;
  resize: none;
  margin-bottom: 12rpx;
}

.char-count {
  display: block;
  text-align: right;
  font-size: 22rpx;
  color: var(--text-secondary);
}

/* 智能选项和方式选项 */
.smart-options,
.method-options {
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  overflow: hidden;
}

.smart-item,
.method-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 32rpx;
  border-bottom: 1rpx solid rgba(255, 255, 255, 0.2);
  transition: all 0.3s ease;
}

.smart-item:last-child,
.method-item:last-child {
  border-bottom: none;
}

.method-item.selected {
  background: rgba(74, 144, 226, 0.1);
}

.smart-info,
.method-info {
  flex: 1;
}

.smart-title,
.method-title {
  display: block;
  font-size: 28rpx;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 8rpx;
}

.smart-desc,
.method-desc {
  display: block;
  font-size: 24rpx;
  color: var(--text-secondary);
  line-height: 1.4;
}

.method-icon {
  font-size: 32rpx;
  margin-right: 20rpx;
}

/* 预览和保存按钮 */
.preview-section,
.save-section {
  margin-top: 40rpx;
}

.preview-button,
.save-button {
  width: 100%;
  height: 88rpx;
  border-radius: 25rpx;
  font-size: 30rpx;
  font-weight: 600;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16rpx;
  transition: all 0.3s ease;
}

.preview-button {
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  color: var(--primary-color);
}

.save-button {
  background: linear-gradient(45deg, var(--primary-color), #667eea);
  color: white;
  box-shadow: 0 8rpx 32rpx rgba(74, 144, 226, 0.3);
}

.preview-button:active,
.save-button:active {
  transform: scale(0.98);
}

.preview-icon {
  font-size: 28rpx;
}

.preview-text {
  font-size: 28rpx;
}
</style> 