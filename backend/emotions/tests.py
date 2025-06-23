"""
Emotions应用测试
"""

from django.test import TestCase
from django.contrib.auth import get_user_model
from django.urls import reverse
from django.utils import timezone
from rest_framework.test import APITestCase
from rest_framework import status
from rest_framework.authtoken.models import Token
from .models import EmotionRecord, EmotionTag, RecordTag
from datetime import datetime, timedelta

User = get_user_model()


class EmotionTagModelTest(TestCase):
    """情绪标签模型测试"""
    
    def test_create_emotion_tag(self):
        """测试创建情绪标签"""
        tag = EmotionTag.objects.create(
            name='开心',
            category='emotion',
            color='#FF6B6B'
        )
        self.assertEqual(tag.name, '开心')
        self.assertEqual(tag.category, 'emotion')
        self.assertEqual(tag.color, '#FF6B6B')
    
    def test_emotion_tag_str(self):
        """测试情绪标签字符串表示"""
        tag = EmotionTag.objects.create(
            name='开心',
            category='emotion'
        )
        self.assertEqual(str(tag), '开心')


class EmotionRecordModelTest(TestCase):
    """情绪记录模型测试"""
    
    def setUp(self):
        """设置测试数据"""
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        self.emotion_tag = EmotionTag.objects.create(
            name='开心',
            category='emotion'
        )
    
    def test_create_emotion_record(self):
        """测试创建情绪记录"""
        record = EmotionRecord.objects.create(
            user=self.user,
            emotion_type='happy',
            intensity=8,
            scenario='work',
            description='今天工作很顺利，心情很好！'
        )
        self.assertEqual(record.user, self.user)
        self.assertEqual(record.emotion_type, 'happy')
        self.assertEqual(record.intensity, 8)
        self.assertEqual(record.scenario, 'work')
    
    def test_emotion_record_str(self):
        """测试情绪记录字符串表示"""
        record = EmotionRecord.objects.create(
            user=self.user,
            emotion_type='happy',
            intensity=8,
            scenario='work'
        )
        expected = f'{self.user.username} - happy (8/10)'
        self.assertEqual(str(record), expected)


class EmotionRecordAPITest(APITestCase):
    """情绪记录API测试"""
    
    def setUp(self):
        """设置测试数据"""
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        self.token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + self.token.key)
        
        self.emotion_tag = EmotionTag.objects.create(
            name='开心',
            category='emotion'
        )
    
    def test_create_emotion_record(self):
        """测试创建情绪记录"""
        url = reverse('emotions:emotion-records-list')
        data = {
            'emotion_type': 'happy',
            'intensity': 8,
            'scenario': 'work',
            'description': '今天工作很顺利！',
            'tags': [self.emotion_tag.id]
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(EmotionRecord.objects.filter(user=self.user).exists())
    
    def test_get_emotion_records(self):
        """测试获取情绪记录列表"""
        # 创建测试记录
        EmotionRecord.objects.create(
            user=self.user,
            emotion_type='happy',
            intensity=8,
            scenario='work'
        )
        
        url = reverse('emotions:emotion-records-list')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)
    
    def test_get_emotion_record_detail(self):
        """测试获取情绪记录详情"""
        record = EmotionRecord.objects.create(
            user=self.user,
            emotion_type='happy',
            intensity=8,
            scenario='work'
        )
        
        url = reverse('emotions:emotion-records-detail', kwargs={'pk': record.pk})
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['emotion_type'], 'happy')
    
    def test_update_emotion_record(self):
        """测试更新情绪记录"""
        record = EmotionRecord.objects.create(
            user=self.user,
            emotion_type='happy',
            intensity=8,
            scenario='work'
        )
        
        url = reverse('emotions:emotion-records-detail', kwargs={'pk': record.pk})
        data = {
            'intensity': 9,
            'description': '更新后的描述'
        }
        response = self.client.patch(url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        record.refresh_from_db()
        self.assertEqual(record.intensity, 9)
        self.assertEqual(record.description, '更新后的描述')
    
    def test_delete_emotion_record(self):
        """测试删除情绪记录"""
        record = EmotionRecord.objects.create(
            user=self.user,
            emotion_type='happy',
            intensity=8,
            scenario='work'
        )
        
        url = reverse('emotions:emotion-records-detail', kwargs={'pk': record.pk})
        response = self.client.delete(url)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(EmotionRecord.objects.filter(pk=record.pk).exists())


class EmotionStatisticsAPITest(APITestCase):
    """情绪统计API测试"""
    
    def setUp(self):
        """设置测试数据"""
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        self.token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + self.token.key)
        
        # 创建测试记录
        for i in range(5):
            EmotionRecord.objects.create(
                user=self.user,
                emotion_type='happy',
                intensity=7 + i % 3,
                scenario='work',
                emotion_time=timezone.now() - timedelta(days=i)
            )
    
    def test_get_emotion_overview(self):
        """测试获取情绪概览"""
        url = reverse('emotions:statistics-overview')
        response = self.client.get(url, {'time_range': 'week'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('total_records', response.data)
        self.assertIn('avg_intensity', response.data)
    
    def test_get_emotion_distribution(self):
        """测试获取情绪分布"""
        url = reverse('emotions:statistics-distribution')
        response = self.client.get(url, {'time_range': 'week'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIsInstance(response.data, list)
    
    def test_get_emotion_trend(self):
        """测试获取情绪趋势"""
        url = reverse('emotions:statistics-trend')
        response = self.client.get(url, {'time_range': 'week'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIsInstance(response.data, list)


class EmotionTagAPITest(APITestCase):
    """情绪标签API测试"""
    
    def setUp(self):
        """设置测试数据"""
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        self.token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + self.token.key)
    
    def test_get_emotion_tags(self):
        """测试获取情绪标签列表"""
        EmotionTag.objects.create(name='开心', category='emotion')
        EmotionTag.objects.create(name='工作', category='scene')
        
        url = reverse('emotions:emotion-tags-list')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 2)
    
    def test_filter_emotion_tags_by_category(self):
        """测试按类别筛选情绪标签"""
        EmotionTag.objects.create(name='开心', category='emotion')
        EmotionTag.objects.create(name='工作', category='scene')
        
        url = reverse('emotions:emotion-tags-list')
        response = self.client.get(url, {'category': 'emotion'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)
        self.assertEqual(response.data['results'][0]['name'], '开心') 