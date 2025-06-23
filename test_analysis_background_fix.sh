#!/bin/bash

echo "🔍 测试分析页面背景修复..."

# 检查前端服务
echo "📡 检查前端服务状态..."
if curl -s http://localhost:5173 > /dev/null; then
    echo "✅ 前端服务正常运行 (localhost:5173)"
else
    echo "❌ 前端服务未运行"
    exit 1
fi

# 检查后端服务
echo "📡 检查后端服务状态..."
if curl -s http://127.0.0.1:8000 > /dev/null; then
    echo "✅ 后端服务正常运行 (127.0.0.1:8000)"
else
    echo "❌ 后端服务未运行"
    exit 1
fi

# 检查关键文件是否存在
echo "📄 检查关键文件..."
if [ -f "frontend/src/pages/analysis/index.vue" ]; then
    echo "✅ 分析页面文件存在"
else
    echo "❌ 分析页面文件不存在"
    exit 1
fi

# 检查CSS样式是否包含背景修复
echo "🎨 检查CSS样式修复..."
if grep -q "background.*linear-gradient.*#f5f7fa.*#c3cfe2" "frontend/src/pages/analysis/index.vue"; then
    echo "✅ 背景渐变样式已应用"
else
    echo "❌ 背景渐变样式未找到"
fi

if grep -q "style.*background.*linear-gradient" "frontend/src/pages/analysis/index.vue"; then
    echo "✅ 内联背景样式已应用"
else
    echo "❌ 内联背景样式未找到"
fi

if grep -q "glass-card" "frontend/src/pages/analysis/index.vue"; then
    echo "✅ 毛玻璃卡片样式已应用"
else
    echo "❌ 毛玻璃卡片样式未找到"
fi

echo ""
echo "🎯 测试完成！请访问以下地址查看效果："
echo "   http://localhost:5173/#/pages/analysis/index"
echo ""
echo "💡 如果背景仍未生效，请："
echo "   1. 强制刷新浏览器 (Ctrl+Shift+R 或 Cmd+Shift+R)"
echo "   2. 清除浏览器缓存"
echo "   3. 尝试无痕模式访问"
echo ""
echo "🔧 修复内容："
echo "   - ✅ 添加内联样式强制应用背景"
echo "   - ✅ 统一毛玻璃卡片效果"
echo "   - ✅ 与其他页面风格保持一致"  
echo "   - ✅ 增强文字对比度和可读性"
