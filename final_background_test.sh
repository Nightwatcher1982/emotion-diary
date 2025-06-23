#!/bin/bash

echo "🎨 分析页面背景修复最终验证..."
echo ""

# 检查服务状态
echo "1️⃣ 检查服务状态..."
if curl -s http://localhost:5173 > /dev/null; then
    echo "   ✅ 前端服务正常 (localhost:5173)"
else
    echo "   ❌ 前端服务异常"
fi

if curl -s http://127.0.0.1:8000 > /dev/null; then
    echo "   ✅ 后端服务正常 (127.0.0.1:8000)"
else
    echo "   ❌ 后端服务异常"
fi

echo ""

# 检查关键修复
echo "2️⃣ 检查关键修复..."

# 检查容器类名
if grep -q 'class="container"' "frontend/src/pages/analysis/index.vue"; then
    echo "   ✅ 容器类名已更新为 'container'"
else
    echo "   ❌ 容器类名未更新"
fi

# 检查背景样式
if grep -q "background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%)" "frontend/src/pages/analysis/index.vue"; then
    echo "   ✅ 背景渐变样式已应用"
else
    echo "   ❌ 背景渐变样式未找到"
fi

# 检查毛玻璃样式
if grep -q "glass-card" "frontend/src/pages/analysis/index.vue"; then
    echo "   ✅ 毛玻璃卡片样式已应用"
else
    echo "   ❌ 毛玻璃卡片样式未找到"
fi

# 检查装饰效果
if grep -q "radial-gradient.*rgba(120, 119, 198" "frontend/src/pages/analysis/index.vue"; then
    echo "   ✅ 装饰光效已应用"
else
    echo "   ❌ 装饰光效未找到"
fi

echo ""

# 与其他页面对比
echo "3️⃣ 与其他页面对比..."

# 检查首页背景
if grep -q "background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%)" "frontend/src/pages/index/index.vue"; then
    echo "   ✅ 首页使用相同背景"
else
    echo "   ❌ 首页背景不同"
fi

# 检查记录页面背景
if [ -f "frontend/src/pages/record/index.vue" ]; then
    if grep -q "#f5f7fa.*#c3cfe2" "frontend/src/pages/record/index.vue"; then
        echo "   ✅ 记录页面使用相同背景"
    else
        echo "   ❌ 记录页面背景不同"
    fi
fi

echo ""

# 提供访问信息
echo "4️⃣ 访问测试..."
echo "   🌐 分析页面: http://localhost:5173/#/pages/analysis/index"
echo "   🌐 首页对比: http://localhost:5173/#/pages/index/index"
echo ""

echo "5️⃣ 故障排除建议..."
echo "   如果背景仍未生效，请尝试："
echo "   1. 强制刷新: Ctrl+Shift+R (Win) 或 Cmd+Shift+R (Mac)"
echo "   2. 清除缓存: 浏览器设置 -> 清除数据"
echo "   3. 无痕模式: 避免缓存干扰"
echo "   4. 检查控制台: F12 -> Console 查看错误"
echo ""

echo "✨ 修复总结："
echo "   - 更新容器类名为 'container'"
echo "   - 应用与首页相同的背景渐变"
echo "   - 添加装饰光效"
echo "   - 统一毛玻璃卡片效果"
echo "   - 优化文字对比度"

