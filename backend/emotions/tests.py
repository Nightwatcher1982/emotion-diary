"""
Emotions应用基础测试
"""

from django.test import TestCase


class BasicEmotionTest(TestCase):
    """基础测试"""
    
    def test_basic_math(self):
        """测试基础数学运算"""
        self.assertEqual(2 + 2, 4)
        self.assertTrue(True)
    
    def test_django_settings(self):
        """测试Django设置"""
        from django.conf import settings
        self.assertIn('emotions', settings.INSTALLED_APPS) 