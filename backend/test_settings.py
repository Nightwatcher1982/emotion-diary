"""
基础Django设置测试
用于验证Django项目配置是否正确
"""

import os
import django
from django.test import TestCase
from django.conf import settings
from django.db import connection

# 确保Django设置已加载
if not settings.configured:
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'emotion_diary_api.settings_test')
    django.setup()


class DjangoSettingsTest(TestCase):
    """Django基础设置测试"""
    
    def test_settings_loaded(self):
        """测试Django设置是否正确加载"""
        self.assertTrue(settings.DEBUG)
        self.assertTrue(settings.TESTING)
        self.assertIsNotNone(settings.SECRET_KEY)
        self.assertEqual(settings.LANGUAGE_CODE, 'zh-hans')
        self.assertEqual(settings.TIME_ZONE, 'Asia/Shanghai')
    
    def test_installed_apps(self):
        """测试应用是否正确安装"""
        required_apps = [
            'django.contrib.admin',
            'django.contrib.auth',
            'django.contrib.contenttypes',
            'rest_framework',
            'accounts',
            'emotions',
            'ai_analysis',
        ]
        
        for app in required_apps:
            self.assertIn(app, settings.INSTALLED_APPS, f"应用 {app} 未正确安装")
    
    def test_database_connection(self):
        """测试数据库连接"""
        try:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
                result = cursor.fetchone()
                self.assertEqual(result[0], 1)
        except Exception as e:
            self.fail(f"数据库连接失败: {e}")
    
    def test_database_settings(self):
        """测试数据库设置"""
        db_config = settings.DATABASES['default']
        self.assertEqual(db_config['ENGINE'], 'django.db.backends.mysql')
        self.assertIsNotNone(db_config['NAME'])
        self.assertIsNotNone(db_config['USER'])
