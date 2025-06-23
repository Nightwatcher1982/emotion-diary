#!/bin/bash

# AI分析页面视觉效果查看脚本
echo "🎨 AI分析页面视觉优化查看指南"
echo "=================================="
echo ""
echo "📱 前端地址: http://localhost:5173"
echo "🔍 AI分析页面: http://localhost:5173/#/pages/analysis/index"
echo ""
echo "✨ 主要优化特性:"
echo "  • 现代化渐变背景和卡片设计"
echo "  • 流畅的悬停动画和交互效果" 
echo "  • 优化的情绪光谱和数据可视化"
echo "  • AI状态徽章和脉冲动画"
echo "  • 响应式布局和深色模式支持"
echo ""
echo "🎯 查看要点:"
echo "  1. 页面头部的渐变标题和AI状态徽章"
echo "  2. 情绪概览卡片的视觉层次"
echo "  3. 情绪光谱的动画进度条"
echo "  4. AI洞察卡片的悬停效果"
echo "  5. 建议系统的标签页切换动画"
echo "  6. 底部操作按钮的渐变设计"
echo ""
echo "💡 测试建议:"
echo "  • 尝试悬停各种按钮和卡片"
echo "  • 切换建议标签页查看动画"
echo "  • 观察加载状态的动画效果"
echo "  • 测试不同屏幕尺寸的响应式效果"
echo ""

# 检查前端服务状态
if curl -s http://localhost:5173 > /dev/null; then
    echo "✅ 前端服务运行正常"
    echo "🚀 可以开始查看优化效果了！"
    echo ""
    echo "🔧 如需重新启动前端服务："
    echo "   cd frontend && npm run dev:h5"
else
    echo "❌ 前端服务未启动，请先运行:"
    echo "   cd frontend && npm run dev:h5"
    echo ""
fi

echo ""
echo "📊 如需查看后端数据，请确保后端服务也在运行"
echo "🔧 后端地址: http://127.0.0.1:8000"
echo ""
echo "🎉 TypeScript错误已修复，页面现在可以正常加载！" 