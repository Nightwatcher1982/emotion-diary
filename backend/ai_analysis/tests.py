"""
AI分析应用测试
"""

from django.test import TestCase
from django.contrib.auth import get_user_model
from .models import AIAnalysisResult, EmotionInsight, AIRecommendation, ActionPlan

User = get_user_model()


class AIAnalysisResultModelTest(TestCase):
    """AI分析结果模型测试"""
    
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
            summary='用户情绪状态良好',
            detailed_analysis={'mood': 'positive', 'intensity': 8}
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
            status='completed'
        )
        expected = f'{self.user.username} - emotion_analysis (completed)'
        self.assertEqual(str(result), expected)


class EmotionInsightModelTest(TestCase):
    """情绪洞察模型测试"""
    
    def setUp(self):
        """设置测试数据"""
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        self.analysis_result = AIAnalysisResult.objects.create(
            user=self.user,
            analysis_type='emotion_analysis',
            status='completed'
        )
    
    def test_create_emotion_insight(self):
        """测试创建情绪洞察"""
        insight = EmotionInsight.objects.create(
            analysis_result=self.analysis_result,
            insight_type='pattern',
            title='情绪模式分析',
            content='用户在工作日情绪较低，周末情绪较高',
            confidence_score=0.85
        )
        self.assertEqual(insight.analysis_result, self.analysis_result)
        self.assertEqual(insight.insight_type, 'pattern')
        self.assertEqual(insight.title, '情绪模式分析')
        self.assertEqual(insight.confidence_score, 0.85)
    
    def test_emotion_insight_str(self):
        """测试情绪洞察字符串表示"""
        insight = EmotionInsight.objects.create(
            analysis_result=self.analysis_result,
            insight_type='pattern',
            title='情绪模式分析'
        )
        self.assertEqual(str(insight), '情绪模式分析')


class AIRecommendationModelTest(TestCase):
    """AI建议模型测试"""
    
    def setUp(self):
        """设置测试数据"""
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        self.analysis_result = AIAnalysisResult.objects.create(
            user=self.user,
            analysis_type='emotion_analysis',
            status='completed'
        )
    
    def test_create_ai_recommendation(self):
        """测试创建AI建议"""
        recommendation = AIRecommendation.objects.create(
            analysis_result=self.analysis_result,
            category='mental_health',
            title='建议增加运动',
            content='建议每天进行30分钟的有氧运动',
            priority='high',
            confidence_score=0.9
        )
        self.assertEqual(recommendation.analysis_result, self.analysis_result)
        self.assertEqual(recommendation.category, 'mental_health')
        self.assertEqual(recommendation.title, '建议增加运动')
        self.assertEqual(recommendation.priority, 'high')
    
    def test_ai_recommendation_str(self):
        """测试AI建议字符串表示"""
        recommendation = AIRecommendation.objects.create(
            analysis_result=self.analysis_result,
            category='mental_health',
            title='建议增加运动'
        )
        self.assertEqual(str(recommendation), '建议增加运动') 