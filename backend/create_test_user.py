#!/usr/bin/env python
import os
import sys
import django

# 设置Django环境
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'emotion_diary_api.settings')
django.setup()

from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token

User = get_user_model()

def create_test_user():
    """创建测试用户"""
    
    # 检查是否已存在测试用户
    if User.objects.filter(username='testuser').exists():
        print("测试用户已存在")
        user = User.objects.get(username='testuser')
    else:
        # 创建测试用户
        user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123',
            first_name='测试',
            last_name='用户'
        )
        print("测试用户创建成功")
    
    # 创建或获取Token
    token, created = Token.objects.get_or_create(user=user)
    
    print(f"用户名: {user.username}")
    print(f"邮箱: {user.email}")
    print(f"密码: testpass123")
    print(f"Token: {token.key}")
    print(f"用户ID: {user.id}")
    
    return user, token

if __name__ == '__main__':
    create_test_user() 