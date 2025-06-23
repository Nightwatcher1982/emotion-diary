<script setup lang="ts">
import { onLaunch, onShow, onHide } from "@dcloudio/uni-app";

onLaunch(() => {
  console.log("AI情绪日记APP启动");
});

onShow(() => {
  console.log("APP显示");
});

onHide(() => {
  console.log("APP隐藏");
});
</script>

<style>
/* 全局样式 */
page {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
}

/* 浅色模式变量 */
:root {
  --primary-color: #4A90E2;
  --secondary-color: #2196F3;
  --success-color: #4CAF50;
  --warning-color: #FF9800;
  --error-color: #F44336;
  --text-primary: #333333;
  --text-secondary: #666666;
  --text-placeholder: #999999;
  --border-color: #e0e0e0;
  --background-color: #f8f9fa;
  
  /* 现代化设计变量 */
  --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  --secondary-gradient: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  --success-gradient: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  --warning-gradient: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
  --glass-bg: rgba(255, 255, 255, 0.25);
  --glass-border: rgba(255, 255, 255, 0.18);
  --shadow-light: 0 8rpx 32rpx rgba(0, 0, 0, 0.1);
  --shadow-medium: 0 12rpx 48rpx rgba(0, 0, 0, 0.15);
  --shadow-heavy: 0 20rpx 64rpx rgba(0, 0, 0, 0.2);
}

/* 深色模式变量 */
@media (prefers-color-scheme: dark) {
  :root {
    --primary-color: #5BA3F5;
    --secondary-color: #42A5F5;
    --success-color: #66BB6A;
    --warning-color: #FFA726;
    --error-color: #EF5350;
    --text-primary: #ffffff;
    --text-secondary: #b0b0b0;
    --text-placeholder: #808080;
    --border-color: #404040;
    --background-color: #1a1a2e;
    
    /* 深色模式毛玻璃效果 */
    --glass-bg: rgba(255, 255, 255, 0.1);
    --glass-border: rgba(255, 255, 255, 0.2);
    --shadow-light: 0 8rpx 32rpx rgba(0, 0, 0, 0.3);
    --shadow-medium: 0 12rpx 48rpx rgba(0, 0, 0, 0.4);
    --shadow-heavy: 0 20rpx 64rpx rgba(0, 0, 0, 0.5);
  }
  
  page {
    background-color: var(--background-color);
    color: var(--text-primary);
  }
}

/* 浅色模式默认样式 */
@media (prefers-color-scheme: light) {
  page {
    background-color: var(--background-color);
    color: var(--text-primary);
  }
}

/* 通用样式重置 */
* {
  box-sizing: border-box;
}

/* 滚动条样式 */
::-webkit-scrollbar {
  width: 8rpx;
}

::-webkit-scrollbar-track {
  background: rgba(0, 0, 0, 0.1);
  border-radius: 4rpx;
}

::-webkit-scrollbar-thumb {
  background: var(--primary-color);
  border-radius: 4rpx;
}

::-webkit-scrollbar-thumb:hover {
  background: var(--secondary-color);
}

/*每个页面公共css */
* {
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  margin: 0;
  padding: 0;
}

page {
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  min-height: 100vh;
}

/* 导航栏样式优化 - 艺术字体版本 */
.uni-tabbar {
  background: rgba(245, 247, 250, 0.95) !important;
  backdrop-filter: blur(20px) !important;
  -webkit-backdrop-filter: blur(20px) !important;
  border-top: 1px solid rgba(255, 255, 255, 0.3) !important;
  box-shadow: 0 -2px 20px rgba(0, 0, 0, 0.1) !important;
  height: 70px !important;
}

.uni-tabbar-item {
  padding: 12px 0 8px 0 !important;
  position: relative !important;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
}

.uni-tabbar .uni-tabbar-item-text {
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif !important;
  font-size: 16px !important;
  font-weight: 600 !important;
  letter-spacing: 0.5px !important;
  text-shadow: 0 1px 2px rgba(255, 255, 255, 0.8) !important;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
  margin-top: 4px !important;
  position: relative !important;
  z-index: 2 !important;
}

/* 普通状态文字颜色 */
.uni-tabbar .uni-tabbar-item:not(.uni-tabbar-item-active) .uni-tabbar-item-text {
  background: linear-gradient(135deg, #7B8794 0%, #9CA3AF 100%) !important;
  -webkit-background-clip: text !important;
  -webkit-text-fill-color: transparent !important;
  background-clip: text !important;
}

/* 选中状态文字颜色 */
.uni-tabbar .uni-tabbar-item-active .uni-tabbar-item-text {
  background: linear-gradient(135deg, #4A90E2 0%, #6366F1 50%, #8B5CF6 100%) !important;
  -webkit-background-clip: text !important;
  -webkit-text-fill-color: transparent !important;
  background-clip: text !important;
  font-weight: 700 !important;
  transform: scale(1.1) !important;
  filter: drop-shadow(0 0 8px rgba(74, 144, 226, 0.3)) !important;
}

/* 选中状态发光效果 */
.uni-tabbar .uni-tabbar-item-active::before {
  content: '' !important;
  position: absolute !important;
  top: 50% !important;
  left: 50% !important;
  width: 60px !important;
  height: 60px !important;
  background: radial-gradient(circle, rgba(74, 144, 226, 0.2) 0%, transparent 70%) !important;
  border-radius: 50% !important;
  transform: translate(-50%, -50%) !important;
  z-index: 1 !important;
  animation: glow 2s ease-in-out infinite alternate !important;
}

/* 悬停效果 */
.uni-tabbar .uni-tabbar-item:hover .uni-tabbar-item-text {
  transform: scale(1.05) !important;
  filter: drop-shadow(0 0 4px rgba(74, 144, 226, 0.2)) !important;
}

/* 发光动画 */
@keyframes glow {
  from {
    opacity: 0.3;
    transform: translate(-50%, -50%) scale(0.8);
  }
  to {
    opacity: 0.6;
    transform: translate(-50%, -50%) scale(1.2);
  }
}

/* 页面容器通用样式 */
.page-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  position: relative;
}

.page-container::before {
  content: '';
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: 
    radial-gradient(circle at 20% 50%, rgba(120, 119, 198, 0.3) 0%, transparent 50%),
    radial-gradient(circle at 80% 20%, rgba(255, 119, 198, 0.3) 0%, transparent 50%),
    radial-gradient(circle at 40% 80%, rgba(120, 219, 255, 0.3) 0%, transparent 50%);
  pointer-events: none;
  z-index: 0;
}

.page-content {
  position: relative;
  z-index: 1;
}

/* 毛玻璃卡片通用样式 */
.glass-card {
  background: rgba(255, 255, 255, 0.25);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

/* 通用按钮样式 */
.glass-button {
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 12px;
  color: #333;
  font-weight: 600;
  transition: all 0.3s ease;
}

.glass-button:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-2px);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
}

/* 响应式设计 */
@media (max-width: 750rpx) {
  .uni-tabbar .uni-tabbar-item-icon {
    width: 28px !important;
    height: 28px !important;
  }
}

@media (max-width: 480rpx) {
  .uni-tabbar .uni-tabbar-item-icon {
    width: 26px !important;
    height: 26px !important;
  }
}
</style>
