#!/bin/bash

echo "🎨 最终移动端效果验证..."
echo ""

# 检查新端口服务
echo "1️⃣ 检查服务状态..."
if curl -s http://localhost:5176 > /dev/null; then
    echo "   ✅ 前端服务正常 (端口: 5176)"
else
    echo "   ❌ 前端服务异常"
fi

if curl -s http://127.0.0.1:8000 > /dev/null; then
    echo "   ✅ 后端服务正常"
else
    echo "   ❌ 后端服务异常"
fi

echo ""

# 检查关键修复
echo "2️⃣ 检查强化效果..."

# 检查新的渐变背景
if grep -q "#667eea.*#764ba2.*#f093fb" "frontend/src/pages/analysis/index.vue"; then
    echo "   ✅ 强化渐变背景已应用"
else
    echo "   ❌ 强化渐变背景未找到"
fi

# 检查增强的毛玻璃效果
if grep -q "backdrop-filter: blur(25px)" "frontend/src/pages/analysis/index.vue"; then
    echo "   ✅ 增强毛玻璃效果已应用"
else
    echo "   ❌ 增强毛玻璃效果未找到"
fi

# 检查内联样式
if grep -q "style.*rgba(255, 255, 255, 0.35)" "frontend/src/pages/analysis/index.vue"; then
    echo "   ✅ 强制内联样式已应用"
else
    echo "   ❌ 强制内联样式未找到"
fi

# 检查文字增强
if grep -q "font-weight: 800" "frontend/src/pages/analysis/index.vue"; then
    echo "   ✅ 文字粗细增强已应用"
else
    echo "   ❌ 文字粗细增强未找到"
fi

echo ""

# 移动端优化检查
echo "3️⃣ 移动端优化检查..."

if grep -q "min-height: 88rpx" "frontend/src/pages/analysis/index.vue"; then
    echo "   ✅ 触摸友好按钮"
else
    echo "   ❌ 触摸友好按钮未设置"
fi

if grep -q "@media.*max-width: 750rpx" "frontend/src/pages/analysis/index.vue"; then
    echo "   ✅ 移动端响应式设计"
else
    echo "   ❌ 移动端响应式设计未找到"
fi

echo ""

# 访问测试
echo "4️⃣ 访问测试 (更新端口)..."
echo "   🌐 分析页面: http://localhost:5176/#/pages/analysis/index"
echo "   🌐 首页对比: http://localhost:5176/#/pages/index/index"
echo ""

echo "5️⃣ 效果说明..."
echo "   🎨 新的渐变背景: 蓝紫渐变，更加鲜明"
echo "   ✨ 增强毛玻璃: 35%透明度 + 25px模糊"
echo "   📱 移动端优化: 触摸友好 + 响应式布局"
echo "   🔤 文字增强: 800粗体 + 白色阴影"
echo "   💫 强制样式: 内联样式确保立即生效"

echo ""
echo "📱 请在手机上访问测试，应该看到:"
echo "   - 鲜明的蓝紫色渐变背景"
echo "   - 清晰的白色毛玻璃卡片"
echo "   - 粗体黑色文字，带白色阴影"
echo "   - 适合手机的按钮和间距"

