#!/bin/bash

echo "🤖 测试真实AI分析功能"
echo "=================================="

# 获取测试用户token
echo "1. 登录测试用户..."
LOGIN_RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"testpass123"}' \
  http://127.0.0.1:8000/api/v1/auth/login/)

TOKEN=$(echo $LOGIN_RESPONSE | python3 -c "import sys, json; print(json.load(sys.stdin)['token'])" 2>/dev/null)

if [ -z "$TOKEN" ]; then
    echo "❌ 登录失败，请检查用户凭据"
    exit 1
fi

echo "✅ 登录成功，Token: ${TOKEN:0:20}..."

# 创建测试情绪记录
echo ""
echo "2. 创建测试情绪记录..."
RECORD_RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Token $TOKEN" \
  -d '{
    "emotion_type": "anxious",
    "intensity": 7,
    "scenario": "work",
    "description": "今天工作压力很大，有很多任务要完成，感觉时间不够用，很焦虑",
    "triggers": ["工作压力", "时间压力"],
    "physical_symptoms": ["心跳加速", "肌肉紧张"],
    "coping_methods": ["深呼吸"],
    "enable_ai_analysis": true
  }' \
  http://127.0.0.1:8000/api/v1/emotions/records/)

RECORD_ID=$(echo $RECORD_RESPONSE | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])" 2>/dev/null)

if [ -z "$RECORD_ID" ]; then
    echo "❌ 创建记录失败"
    echo "Response: $RECORD_RESPONSE"
    exit 1
fi

echo "✅ 记录创建成功，ID: $RECORD_ID"

# 请求AI分析
echo ""
echo "3. 请求AI分析..."
ANALYSIS_RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Token $TOKEN" \
  -d "{\"emotion_records\": [$RECORD_ID], \"analysis_type\": \"comprehensive\"}" \
  http://127.0.0.1:8000/api/v1/ai/analyze/)

echo "📊 AI分析结果："
echo $ANALYSIS_RESPONSE | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(f\"✅ 分析成功！\")
    print(f\"📝 主要情绪: {data.get('primary_emotion', {}).get('name', 'N/A')}\")
    print(f\"🎯 置信度: {data.get('confidence', 'N/A')}%\")
    print(f\"🤖 AI驱动: {'是' if data.get('ai_powered', False) else '否'}\")
    
    insights = data.get('insights', [])
    if insights:
        print(f\"💡 洞察数量: {len(insights)}\")
        for i, insight in enumerate(insights[:2]):
            print(f\"   {i+1}. {insight.get('title', 'N/A')}\")
    
    suggestions = data.get('suggestions', {})
    total_suggestions = sum(len(v) for v in suggestions.values() if isinstance(v, list))
    print(f\"💭 建议数量: {total_suggestions}\")
    
except Exception as e:
    print(f\"❌ 解析失败: {e}\")
    print(f\"Raw response: {sys.stdin.read()}\")
"

# 测试前端访问
echo ""
echo "4. 测试前端页面访问..."
echo "🌐 前端地址: http://localhost:5173"
echo "📱 分析页面: http://localhost:5173/#/pages/analysis/index"

echo ""
echo "=================================="
echo "🎉 AI分析功能测试完成！"
echo ""
echo "📋 下一步："
echo "1. 在浏览器中访问 http://localhost:5173"
echo "2. 登录测试用户 (testuser/testpass123)"
echo "3. 查看AI分析页面的真实数据" 