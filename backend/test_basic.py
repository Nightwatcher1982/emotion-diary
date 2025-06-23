"""
基本健康检查测试
用于验证Django项目基础配置是否正确
"""

import os
import django
from django.test import TestCase
from django.conf import settings
from django.contrib.auth import get_user_model

# 确保Django设置已加载
if not settings.configured:
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'emotion_diary_api.settings_test')
    django.setup()

User = get_user_model()


class BasicHealthTest(TestCase):
    """基础健康检查测试"""
    
    def test_django_settings(self):
        """测试Django设置是否正确加载"""
        self.assertTrue(settings.DEBUG)
        self.assertTrue(settings.TESTING)
        self.assertIsNotNone(settings.SECRET_KEY)
    
    def test_database_connection(self):
        """测试数据库连接"""
        from django.db import connection
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            result = cursor.fetchone()
            self.assertEqual(result[0], 1)
    
    def test_user_model(self):
        """测试用户模型基本功能"""
        # 测试创建用户
        user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        self.assertEqual(user.username, 'testuser')
        self.assertTrue(user.check_password('testpass123'))
        
        # 测试用户计数
        user_count = User.objects.count()
        self.assertEqual(user_count, 1)
    
    def test_installed_apps(self):
        """测试应用是否正确安装"""
        installed_apps = settings.INSTALLED_APPS
        
        # 检查Django核心应用
        self.assertIn('django.contrib.auth', installed_apps)
        self.assertIn('django.contrib.contenttypes', installed_apps)
        
        # 检查第三方应用
        self.assertIn('rest_framework', installed_apps)
        self.assertIn('corsheaders', installed_apps)
        
        # 检查本地应用
        self.assertIn('accounts', installed_apps)
        self.assertIn('emotions', installed_apps)
        self.assertIn('ai_analysis', installed_apps)
    
    def test_middleware(self):
        """测试中间件配置"""
        middleware = settings.MIDDLEWARE
        self.assertIn('django.middleware.security.SecurityMiddleware', middleware)
        self.assertIn('corsheaders.middleware.CorsMiddleware', middleware)
        self.assertIn('django.contrib.auth.middleware.AuthenticationMiddleware', middleware)


class ModelImportTest(TestCase):
    """模型导入测试"""
    
    def test_import_accounts_models(self):
        """测试导入accounts模型"""
        try:
            from accounts.models import User, UserProfile, PhoneVerificationCode
            self.assertTrue(True)
        except ImportError as e:
            self.fail(f"Failed to import accounts models: {e}")
    
    def test_import_emotions_models(self):
        """测试导入emotions模型"""
        try:
            from emotions.models import EmotionRecord, EmotionTag, RecordTag
            self.assertTrue(True)
        except ImportError as e:
            self.fail(f"Failed to import emotions models: {e}")
    
    def test_import_ai_analysis_models(self):
        """测试导入ai_analysis模型"""
        try:
            from ai_analysis.models import AIAnalysisResult, EmotionInsight, AIRecommendation
            self.assertTrue(True)
        except ImportError as e:
            self.fail(f"Failed to import ai_analysis models: {e}")


if __name__ == '__main__':
    import unittest
    unittest.main() 