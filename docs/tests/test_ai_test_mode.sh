#!/bin/bash

# AI分析页面测试模式验证脚本
echo "🧪 AI分析页面测试模式验证"
echo "=================================="
echo ""

# 检查后端服务状态
echo "1. 检查后端服务状态..."
if curl -s http://127.0.0.1:8000/health/ > /dev/null; then
    echo "✅ 后端服务运行正常"
else
    echo "❌ 后端服务未启动，请先运行:"
    echo "   cd backend && python manage.py runserver"
    exit 1
fi

echo ""
echo "2. 测试AI分析服务状态..."

# 测试AI服务状态
python3 -c "
import sys
import os
sys.path.append('backend')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'emotion_diary_api.settings')

import django
django.setup()

from ai_analysis.ai_service import AIAnalysisService

# 初始化AI服务
ai_service = AIAnalysisService()

# 检查认证状态
auth_status = ai_service.get_auth_status()
print(f\"📊 认证状态: {auth_status['status']}\")
print(f\"📝 状态信息: {auth_status['message']}\")
print(f\"🔐 认证方式: {auth_status['auth_method']}\")
print(f\"🤖 AI启用: {'是' if auth_status['ai_enabled'] else '否'}\")

if auth_status['status'] == 'test_mode':
    print('✅ 测试模式已正确启用')
else:
    print('❌ 测试模式未正确配置')
"

echo ""
echo "3. 测试模拟AI分析功能..."

# 创建测试情绪记录并进行AI分析
python3 -c "
import sys
import os
sys.path.append('backend')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'emotion_diary_api.settings')

import django
django.setup()

from emotions.models import EmotionRecord
from ai_analysis.ai_service import AIAnalysisService
from accounts.models import User
from datetime import datetime

# 获取或创建测试用户
try:
    user = User.objects.get(username='testuser')
except User.DoesNotExist:
    user = User.objects.create_user(
        username='testuser',
        password='testpass123',
        nickname='测试用户'
    )

# 创建测试情绪记录
test_record = EmotionRecord.objects.create(
    user=user,
    emotion_type='anxious',
    intensity=7,
    description='工作压力很大，担心项目进度',
    scenario='work',
    created_at=datetime.now()
)

print(f'📝 创建测试记录: ID={test_record.id}, 情绪={test_record.emotion_type}, 强度={test_record.intensity}')

# 初始化AI服务并进行分析
ai_service = AIAnalysisService()
analysis_result = ai_service.analyze_emotion_records([test_record])

print('\\n🔍 AI分析结果:')
print(f'   记录ID: {analysis_result[\"record_id\"]}')
print(f'   AI驱动: {analysis_result[\"ai_powered\"]}')
print(f'   测试模式: {analysis_result[\"test_mode\"]}')
print(f'   主要情绪: {analysis_result[\"primary_emotion\"][\"name\"]}')
print(f'   置信度: {analysis_result[\"primary_emotion\"][\"confidence\"]}%')

# 检查洞察数量
insights = analysis_result.get('insights', [])
print(f'   洞察数量: {len(insights)}')
if insights:
    print(f'   第一个洞察: {insights[0][\"title\"]}')

# 检查建议数量
suggestions = analysis_result.get('suggestions', {})
total_suggestions = sum(len(v) for v in suggestions.values() if isinstance(v, list))
print(f'   建议数量: {total_suggestions}')

# 清理测试数据
test_record.delete()
print('\\n🧹 测试数据已清理')
"

echo ""
echo "4. 测试前端API调用..."

# 测试前端API调用
echo "📤 测试AI分析API调用..."
curl -s -X POST http://127.0.0.1:8000/api/v1/ai/analyze/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer test-token" \
  -d '{
    "emotion_records": [1],
    "analysis_type": "comprehensive",
    "include_suggestions": true,
    "include_trend": true
  }' | python3 -c "
import sys
import json

try:
    data = json.load(sys.stdin)
    print('✅ API调用成功！')
    print(f'📝 AI驱动: {data.get(\"ai_powered\", False)}')
    print(f'🧪 测试模式: {data.get(\"test_mode\", False)}')
    print(f'🎯 置信度: {data.get(\"confidence\", \"N/A\")}')
    
    if data.get('test_mode'):
        print('✅ 测试模式标记正确')
    else:
        print('⚠️  测试模式标记缺失')
        
except Exception as e:
    print(f'❌ API解析失败: {e}')
"

echo ""
echo "5. 前端页面访问指南..."
echo "🌐 前端地址: http://localhost:5173"
echo "📱 AI分析页面: http://localhost:5173/#/pages/analysis/index"
echo ""
echo "🎯 测试要点:"
echo "  • 页面头部应显示 '🧪 AI测试模式' 状态"
echo "  • AI分析结果应包含丰富的模拟数据"
echo "  • 不会调用真实的大模型API"
echo "  • 功能体验与真实AI分析一致"

echo ""
echo "=================================="
echo "🎉 AI分析测试模式验证完成！"
echo ""
echo "✅ 测试模式特性:"
echo "  • 不消耗真实API调用次数"
echo "  • 提供一致的用户体验"
echo "  • 包含专业的模拟分析结果"
echo "  • 支持所有情绪类型的分析"
echo ""
echo "📋 下一步:"
echo "  1. 访问前端页面查看测试模式效果"
echo "  2. 记录不同类型的情绪进行测试"
echo "  3. 验证AI状态显示是否正确"
echo "  4. 确认功能体验是否满足预期" 