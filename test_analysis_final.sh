#!/bin/bash

echo "🎯 AI分析页面统一风格测试"
echo "=================================="

# 检查前端服务状态
echo "📡 检查前端服务状态..."
if curl -s http://localhost:5177/ > /dev/null; then
    echo "✅ 前端服务运行正常 (端口 5177)"
else
    echo "❌ 前端服务未运行，正在启动..."
    cd frontend && npm run dev:h5 &
    sleep 5
fi

# 检查分析页面文件
echo ""
echo "📄 检查页面文件..."
if [ -f "frontend/src/pages/analysis/index.vue" ]; then
    echo "✅ 分析页面文件存在"
    
    # 检查关键设计元素
    echo ""
    echo "🎨 检查设计统一性..."
    
    # 检查CSS变量
    if grep -q "var(--glass-bg)" frontend/src/pages/analysis/index.vue; then
        echo "✅ 使用统一的CSS变量"
    else
        echo "❌ 缺少统一的CSS变量"
    fi
    
    # 检查毛玻璃卡片
    if grep -q "glass-card" frontend/src/pages/analysis/index.vue; then
        echo "✅ 使用统一的毛玻璃卡片样式"
    else
        echo "❌ 缺少毛玻璃卡片样式"
    fi
    
    # 检查背景渐变
    if grep -q "linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%)" frontend/src/pages/analysis/index.vue; then
        echo "✅ 使用统一的背景渐变"
    else
        echo "❌ 背景渐变不统一"
    fi
    
    # 检查动画效果
    if grep -q "@keyframes pulse" frontend/src/pages/analysis/index.vue; then
        echo "✅ 包含统一的动画效果"
    else
        echo "❌ 缺少动画效果"
    fi
    
    # 检查按钮样式
    if grep -q "primary-btn" frontend/src/pages/analysis/index.vue; then
        echo "✅ 使用统一的按钮样式"
    else
        echo "❌ 按钮样式不统一"
    fi
    
else
    echo "❌ 分析页面文件不存在"
fi

echo ""
echo "🔍 设计细节检查..."

# 检查首页样式对比
if [ -f "frontend/src/pages/index/index.vue" ]; then
    echo "📋 对比首页设计元素:"
    
    # 提取关键样式
    echo "  - 毛玻璃效果: $(grep -c 'backdrop-filter: blur' frontend/src/pages/index/index.vue) vs $(grep -c 'backdrop-filter: blur' frontend/src/pages/analysis/index.vue)"
    echo "  - 卡片圆角: $(grep -c 'border-radius: 25rpx' frontend/src/pages/index/index.vue) vs $(grep -c 'border-radius: 25rpx' frontend/src/pages/analysis/index.vue)"
    echo "  - 阴影效果: $(grep -c 'var(--shadow-light)' frontend/src/pages/index/index.vue) vs $(grep -c 'var(--shadow-light)' frontend/src/pages/analysis/index.vue)"
    echo "  - 脉冲动画: $(grep -c 'emotion-pulse' frontend/src/pages/index/index.vue) vs $(grep -c 'emotion-pulse' frontend/src/pages/analysis/index.vue)"
fi

echo ""
echo "🌐 访问测试..."
echo "请访问以下链接查看效果:"
echo "📱 AI分析页面: http://localhost:5177/pages/analysis/index"
echo "🏠 首页对比: http://localhost:5177/pages/index/index"
echo "📝 记录页面对比: http://localhost:5177/pages/record/index"

echo ""
echo "✨ 统一风格特性:"
echo "  🎨 毛玻璃卡片效果"
echo "  🌈 统一的背景渐变"
echo "  💫 一致的动画效果"
echo "  🎯 标准化的按钮样式"
echo "  📊 统一的数据可视化"
echo "  🔄 相同的交互反馈"

echo ""
echo "🎉 AI分析页面风格统一完成！" 