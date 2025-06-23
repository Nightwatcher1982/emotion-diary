"""
测试环境配置
"""

from .settings import *
import os

# 测试环境标识
DEBUG = True
TESTING = True

# 数据库配置 - 使用测试数据库
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.environ.get('DB_NAME', 'emotion_diary_test'),
        'USER': os.environ.get('DB_USER', 'root'),
        'PASSWORD': os.environ.get('DB_PASSWORD', 'root'),
        'HOST': os.environ.get('DB_HOST', '127.0.0.1'),
        'PORT': os.environ.get('DB_PORT', '3306'),
        'OPTIONS': {
            'charset': 'utf8mb4',
        },
        'TEST': {
            'NAME': 'test_emotion_diary',
        }
    }
}

# 缓存配置 - 使用内存缓存
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': 'test-cache',
    }
}

# 禁用不必要的中间件
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
]

# 密码验证器 - 测试环境简化
AUTH_PASSWORD_VALIDATORS = []

# 邮件后端 - 使用控制台输出
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# 静态文件配置
STATIC_URL = '/static/'
STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.StaticFilesStorage'

# 媒体文件配置
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'test_media'

# 日志配置 - 简化日志输出
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'WARNING',
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': 'WARNING',
            'propagate': False,
        },
    },
}

# 测试专用设置
SECRET_KEY = os.environ.get('SECRET_KEY', 'test-secret-key-for-ci-cd')

# CORS设置 - 测试环境允许所有源
CORS_ALLOW_ALL_ORIGINS = True

# 禁用HTTPS相关设置
SECURE_SSL_REDIRECT = False
SESSION_COOKIE_SECURE = False
CSRF_COOKIE_SECURE = False

# 百度千帆API配置 - 使用环境变量或默认值
QIANFAN_API_KEY = os.environ.get('QIANFAN_API_KEY', '')

# 测试时跳过某些验证
USE_TZ = True
TIME_ZONE = 'UTC'

# 文件上传限制
FILE_UPLOAD_MAX_MEMORY_SIZE = 1024 * 1024  # 1MB
DATA_UPLOAD_MAX_MEMORY_SIZE = 1024 * 1024  # 1MB 