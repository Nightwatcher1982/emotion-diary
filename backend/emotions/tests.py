"""
Emotions应用基础测试
"""

from django.test import TestCase
from django.contrib.auth import get_user_model
from .models import EmotionTag

User = get_user_model()


class BasicEmotionTest(TestCase):
    """基础情绪测试"""
    
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