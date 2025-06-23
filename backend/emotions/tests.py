"""
Emotions应用测试
"""

from django.test import TestCase
from django.contrib.auth import get_user_model
from django.utils import timezone
from .models import EmotionRecord, EmotionTag, RecordTag
from datetime import timedelta

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


class RecordTagModelTest(TestCase):
    """记录标签关联测试"""
    
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
        self.emotion_record = EmotionRecord.objects.create(
            user=self.user,
            emotion_type='happy',
            intensity=8,
            scenario='work'
        )
    
    def test_create_record_tag(self):
        """测试创建记录标签关联"""
        record_tag = RecordTag.objects.create(
            record=self.emotion_record,
            tag=self.emotion_tag
        )
        self.assertEqual(record_tag.record, self.emotion_record)
        self.assertEqual(record_tag.tag, self.emotion_tag) 