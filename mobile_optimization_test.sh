#!/bin/bash

echo "📱 分析页面移动端优化验证..."
echo ""

# 检查服务状态
echo "1️⃣ 服务状态检查..."
if curl -s http://localhost:5173 > /dev/null; then
    echo "   ✅ 前端服务正常运行"
else
    echo "   ❌ 前端服务未运行"
    exit 1
fi

echo ""

# 检查移动端优化
echo "2️⃣ 移动端优化检查..."

# 检查响应式设计
if grep -q "@media (max-width: 750rpx)" "frontend/src/pages/analysis/index.vue"; then
    echo "   ✅ 移动端响应式设计已应用"
else
    echo "   ❌ 移动端响应式设计未找到"
fi

# 检查容器类名
if grep -q 'class="container"' "frontend/src/pages/analysis/index.vue"; then
    echo "   ✅ 容器类名已更新"
else
    echo "   ❌ 容器类名未更新"
fi

# 检查触摸优化
if grep -q "touch-action: manipulation" "frontend/src/pages/analysis/index.vue"; then
    echo "   ✅ 触摸交互优化已应用"
else
    echo "   ❌ 触摸交互优化未找到"
fi

# 检查按钮最小高度
if grep -q "min-height: 88rpx" "frontend/src/pages/analysis/index.vue"; then
    echo "   ✅ 触摸友好按钮尺寸已设置"
else
    echo "   ❌ 触摸友好按钮尺寸未设置"
fi

# 检查横屏优化
if grep -q "orientation: landscape" "frontend/src/pages/analysis/index.vue"; then
    echo "   ✅ 横屏模式优化已应用"
else
    echo "   ❌ 横屏模式优化未找到"
fi

echo ""

# 检查文字可读性
echo "3️⃣ 文字可读性检查..."

if grep -q "line-height: 1.3" "frontend/src/pages/analysis/index.vue"; then
    echo "   ✅ 标题行高优化已应用"
else
    echo "   ❌ 标题行高优化未找到"
fi

if grep -q "font-weight: 700" "frontend/src/pages/analysis/index.vue"; then
    echo "   ✅ 字体粗细优化已应用"
else
    echo "   ❌ 字体粗细优化未找到"
fi

echo ""

# 背景效果检查
echo "4️⃣ 背景效果检查..."

if grep -q "background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%)" "frontend/src/pages/analysis/index.vue"; then
    echo "   ✅ 背景渐变已应用"
else
    echo "   ❌ 背景渐变未找到"
fi

if grep -q "backdrop-filter: blur(20px)" "frontend/src/pages/analysis/index.vue"; then
    echo "   ✅ 毛玻璃效果已应用"
else
    echo "   ❌ 毛玻璃效果未找到"
fi

echo ""

# 提供测试建议
echo "5️⃣ 移动端测试建议..."
echo "   📱 在手机浏览器中访问: http://localhost:5173/#/pages/analysis/index"
echo "   🔄 测试竖屏和横屏模式"
echo "   👆 测试触摸交互"
echo "   📏 检查文字大小和间距"
echo "   🎨 验证背景和卡片效果"

echo ""

echo "✨ 移动端优化总结:"
echo "   - 🎯 响应式布局适配不同屏幕尺寸"
echo "   - �� 触摸友好的按钮设计"
echo "   - 📖 优化文字可读性和行高"
echo "   - 🔄 横屏模式特别优化"
echo "   - 🎨 统一的毛玻璃视觉效果"
echo "   - 📱 改善移动端用户体验"

