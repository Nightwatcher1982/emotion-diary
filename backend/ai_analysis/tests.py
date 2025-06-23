"""
AI分析应用测试
"""

from django.test import TestCase
from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from rest_framework.authtoken.models import Token
from unittest.mock import patch, MagicMock
from .models import AIAnalysisResult, EmotionInsight, AIRecommendation, ActionPlan
from emotions.models import EmotionRecord

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


class AIAnalysisAPITest(APITestCase):
    """AI分析API测试"""
    
    def setUp(self):
        """设置测试数据"""
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        self.token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + self.token.key)
        
        # 创建测试情绪记录
        self.emotion_record = EmotionRecord.objects.create(
            user=self.user,
            emotion_type='happy',
            intensity=8,
            scenario='work',
            description='今天工作很顺利！'
        )
    
    @patch('ai_analysis.ai_service.QianfanAIService.analyze_emotion')
    def test_create_emotion_analysis(self, mock_analyze):
        """测试创建情绪分析"""
        # 模拟AI分析返回结果
        mock_analyze.return_value = {
            'summary': '用户情绪状态良好',
            'insights': [
                {
                    'type': 'pattern',
                    'title': '情绪模式',
                    'content': '工作时情绪积极',
                    'confidence': 0.8
                }
            ],
            'recommendations': [
                {
                    'category': 'mental_health',
                    'title': '保持积极心态',
                    'content': '继续保持当前的积极状态',
                    'priority': 'medium'
                }
            ]
        }
        
        url = reverse('ai_analysis:analyze')
        data = {
            'analysis_type': 'emotion_analysis',
            'emotion_records': [self.emotion_record.id]
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('analysis_id', response.data)
        
        # 验证分析结果是否保存
        self.assertTrue(AIAnalysisResult.objects.filter(user=self.user).exists())
    
    def test_get_analysis_history(self):
        """测试获取分析历史"""
        # 创建测试分析结果
        AIAnalysisResult.objects.create(
            user=self.user,
            analysis_type='emotion_analysis',
            status='completed',
            summary='测试分析结果'
        )
        
        url = reverse('ai_analysis:analyses-list')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)
    
    def test_get_analysis_detail(self):
        """测试获取分析详情"""
        analysis = AIAnalysisResult.objects.create(
            user=self.user,
            analysis_type='emotion_analysis',
            status='completed',
            summary='测试分析结果'
        )
        
        url = reverse('ai_analysis:analyses-detail', kwargs={'pk': analysis.pk})
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['summary'], '测试分析结果')
    
    @patch('ai_analysis.ai_service.QianfanAIService.generate_suggestions')
    def test_get_suggestions(self, mock_suggestions):
        """测试获取AI建议"""
        # 模拟AI建议返回结果
        mock_suggestions.return_value = [
            {
                'category': 'mental_health',
                'title': '建议运动',
                'content': '每天运动30分钟',
                'priority': 'high'
            }
        ]
        
        url = reverse('ai_analysis:suggestions')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIsInstance(response.data, list)
        if response.data:
            self.assertIn('title', response.data[0])


class AIServiceTest(TestCase):
    """AI服务测试"""
    
    def setUp(self):
        """设置测试数据"""
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
    
    @patch('ai_analysis.ai_service.QianfanAIService._call_qianfan_api')
    def test_ai_service_analyze_emotion(self, mock_api_call):
        """测试AI服务情绪分析"""
        from ai_analysis.ai_service import QianfanAIService
        
        # 模拟API返回结果
        mock_api_call.return_value = {
            'result': '用户情绪状态良好，建议保持积极心态。'
        }
        
        service = QianfanAIService()
        emotion_records = [
            {
                'emotion_type': 'happy',
                'intensity': 8,
                'description': '今天很开心'
            }
        ]
        
        result = service.analyze_emotion(emotion_records)
        self.assertIn('summary', result)
        self.assertIn('insights', result)
        self.assertIn('recommendations', result)
    
    def test_ai_service_format_emotion_data(self):
        """测试AI服务格式化情绪数据"""
        from ai_analysis.ai_service import QianfanAIService
        
        service = QianfanAIService()
        emotion_records = [
            EmotionRecord.objects.create(
                user=self.user,
                emotion_type='happy',
                intensity=8,
                scenario='work',
                description='工作顺利'
            )
        ]
        
        formatted_data = service._format_emotion_data(emotion_records)
        self.assertIsInstance(formatted_data, str)
        self.assertIn('happy', formatted_data)
        self.assertIn('工作顺利', formatted_data) 