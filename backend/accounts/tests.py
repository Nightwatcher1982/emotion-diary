"""
Accounts应用基础测试
"""

from django.test import TestCase


class BasicTest(TestCase):
    """最基础的测试"""
    
    def test_basic_math(self):
        """测试基础数学运算"""
        self.assertEqual(1 + 1, 2)
        self.assertTrue(True)
        self.assertFalse(False)
    
    def test_django_settings(self):
        """测试Django设置"""
        from django.conf import settings
        self.assertIsNotNone(settings.SECRET_KEY)
        self.assertIn('accounts', settings.INSTALLED_APPS) 