"""
AI分析应用基础测试
"""

from django.test import TestCase
from django.contrib.auth import get_user_model
from .models import AIAnalysisResult

User = get_user_model()


class BasicAIAnalysisTest(TestCase):
    """基础AI分析测试"""
    
    def setUp(self):
        """设置测试数据"""
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
    
    def test_create_ai_analysis_result(self):
        """测试创建AI分析结果"""
        result = AIAnalysisResult.objects.create(
            user=self.user,
            analysis_type='emotion_analysis',
            status='completed',
            ai_model='ERNIE-Bot',
            summary='用户情绪状态良好'
        )
        self.assertEqual(result.user, self.user)
        self.assertEqual(result.analysis_type, 'emotion_analysis')
        self.assertEqual(result.status, 'completed')
        self.assertEqual(result.ai_model, 'ERNIE-Bot')
    
    def test_ai_analysis_result_str(self):
        """测试AI分析结果字符串表示"""
        result = AIAnalysisResult.objects.create(
            user=self.user,
            analysis_type='emotion_analysis',
            status='completed',
            ai_model='ERNIE-Bot'
        )
        expected = f'{self.user.username} - emotion_analysis (completed)'
        self.assertEqual(str(result), expected) 