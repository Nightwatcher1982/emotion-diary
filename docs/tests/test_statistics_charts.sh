#!/bin/bash

echo "🎯 统计页面图表集成测试"
echo "================================"

# 测试用户登录
echo "1. 测试用户登录..."
LOGIN_RESPONSE=$(curl -s -X POST http://127.0.0.1:8000/api/v1/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "testpass123"}')

echo "登录响应: $LOGIN_RESPONSE"

# 提取token
TOKEN=$(echo $LOGIN_RESPONSE | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'token' in data:
        print(data['token'])
    else:
        print('NO_TOKEN')
except:
    print('PARSE_ERROR')
")

if [ "$TOKEN" = "NO_TOKEN" ] || [ "$TOKEN" = "PARSE_ERROR" ]; then
    echo "❌ 登录失败，无法获取token"
    exit 1
fi

echo "✅ 登录成功，Token: ${TOKEN:0:20}..."

# 测试统计数据API
echo ""
echo "2. 测试统计数据API..."

# 测试概览数据
echo "2.1 测试概览数据..."
OVERVIEW_RESPONSE=$(curl -s -X GET "http://127.0.0.1:8000/api/v1/emotions/statistics/overview/?time_range=week" \
  -H "Authorization: Token $TOKEN")
echo "概览数据: $OVERVIEW_RESPONSE"

# 测试趋势数据
echo "2.2 测试趋势数据..."
TREND_RESPONSE=$(curl -s -X GET "http://127.0.0.1:8000/api/v1/emotions/statistics/trend/?time_range=week" \
  -H "Authorization: Token $TOKEN")
echo "趋势数据: $TREND_RESPONSE"

# 测试分布数据
echo "2.3 测试分布数据..."
DISTRIBUTION_RESPONSE=$(curl -s -X GET "http://127.0.0.1:8000/api/v1/emotions/statistics/distribution/?time_range=week" \
  -H "Authorization: Token $TOKEN")
echo "分布数据: $DISTRIBUTION_RESPONSE"

# 测试场景数据
echo "2.4 测试场景数据..."
SCENE_RESPONSE=$(curl -s -X GET "http://127.0.0.1:8000/api/v1/emotions/statistics/scenes/?time_range=week" \
  -H "Authorization: Token $TOKEN")
echo "场景数据: $SCENE_RESPONSE"

# 测试时间模式数据
echo "2.5 测试时间模式数据..."
PATTERN_RESPONSE=$(curl -s -X GET "http://127.0.0.1:8000/api/v1/emotions/statistics/time-pattern/?time_range=week" \
  -H "Authorization: Token $TOKEN")
echo "时间模式数据: $PATTERN_RESPONSE"

echo ""
echo "3. 前端服务状态检查..."

# 检查前端服务
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5173)
if [ "$FRONTEND_STATUS" = "200" ]; then
    echo "✅ 前端服务运行正常 (http://localhost:5173)"
else
    echo "❌ 前端服务状态异常: $FRONTEND_STATUS"
fi

# 检查后端服务
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8000)
if [ "$BACKEND_STATUS" = "200" ]; then
    echo "✅ 后端服务运行正常 (http://127.0.0.1:8000)"
else
    echo "❌ 后端服务状态异常: $BACKEND_STATUS"
fi

echo ""
echo "🎉 统计页面图表集成测试完成！"
echo ""
echo "📊 访问统计页面："
echo "   前端地址: http://localhost:5173"
echo "   导航到: 首页 -> 统计页面"
echo ""
echo "🔧 图表功能："
echo "   ✅ 情绪趋势折线图/柱状图"
echo "   ✅ 情绪分布饼图"
echo "   ✅ 场景分析柱状图"
echo "   ✅ 时间模式热力图"
echo "   ✅ 图表交互点击事件"
echo ""
echo "💡 下一步："
echo "   1. 在浏览器中访问统计页面"
echo "   2. 测试不同时间范围的数据"
echo "   3. 点击图表元素查看交互效果"
echo "   4. 验证数据更新和图表重绘" 