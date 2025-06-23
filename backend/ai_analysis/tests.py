"""
AI分析应用基础测试
"""

from django.test import TestCase


class BasicAITest(TestCase):
    """基础测试"""
    
    def test_basic_math(self):
        """测试基础数学运算"""
        self.assertEqual(3 + 3, 6)
        self.assertTrue(True)
    
    def test_django_settings(self):
        """测试Django设置"""
        from django.conf import settings
        self.assertIn('ai_analysis', settings.INSTALLED_APPS)


class BasicAITest(TestCase):
    """基础测试"""
    
    def test_basic_math(self):
        """测试基础数学运算"""
        self.assertEqual(3 + 3, 6)
        self.assertTrue(True)
    
    def test_django_settings(self):
        """测试Django设置"""
        from django.conf import settings
        self.assertIn('ai_analysis', settings.INSTALLED_APPS) 