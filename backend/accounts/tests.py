"""
Accounts应用测试
"""

from django.test import TestCase
from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from rest_framework.authtoken.models import Token
from .models import UserProfile, PhoneVerificationCode

User = get_user_model()


class UserModelTest(TestCase):
    """用户模型测试"""
    
    def setUp(self):
        """设置测试数据"""
        self.user_data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'testpass123'
        }
    
    def test_create_user(self):
        """测试创建用户"""
        user = User.objects.create_user(**self.user_data)
        self.assertEqual(user.username, 'testuser')
        self.assertEqual(user.email, 'test@example.com')
        self.assertTrue(user.check_password('testpass123'))
    
    def test_user_str_method(self):
        """测试用户字符串表示"""
        user = User.objects.create_user(**self.user_data)
        self.assertEqual(str(user), 'testuser')


class UserProfileModelTest(TestCase):
    """用户档案模型测试"""
    
    def setUp(self):
        """设置测试数据"""
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
    
    def test_create_user_profile(self):
        """测试创建用户档案"""
        profile = UserProfile.objects.create(
            user=self.user,
            occupation='student',
            exercise_frequency=3,
            work_stress_level=3
        )
        self.assertEqual(profile.user, self.user)
        self.assertEqual(profile.occupation, 'student')
        self.assertEqual(profile.exercise_frequency, 3)


class AuthAPITest(APITestCase):
    """认证API测试"""
    
    def setUp(self):
        """设置测试数据"""
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        self.login_url = reverse('accounts:login')
        self.register_url = reverse('accounts:register')
    
    def test_login_success(self):
        """测试登录成功"""
        data = {
            'username': 'testuser',
            'password': 'testpass123'
        }
        response = self.client.post(self.login_url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)
        self.assertIn('refresh', response.data)
    
    def test_login_invalid_credentials(self):
        """测试登录失败"""
        data = {
            'username': 'testuser',
            'password': 'wrongpassword'
        }
        response = self.client.post(self.login_url, data)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
    
    def test_register_success(self):
        """测试注册成功"""
        data = {
            'username': 'newuser',
            'email': 'new@example.com',
            'password': 'newpass123',
            'password_confirm': 'newpass123'
        }
        response = self.client.post(self.register_url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(User.objects.filter(username='newuser').exists())


class PhoneVerificationTest(TestCase):
    """手机验证测试"""
    
    def test_create_verification_code(self):
        """测试创建验证码"""
        phone = '13800138000'
        code = PhoneVerificationCode.objects.create(
            phone=phone,
            code='123456',
            purpose='login'
        )
        self.assertEqual(code.phone, phone)
        self.assertEqual(code.code, '123456')
        self.assertEqual(code.purpose, 'login')
        self.assertFalse(code.is_used)
    
    def test_verification_code_str(self):
        """测试验证码字符串表示"""
        code = PhoneVerificationCode.objects.create(
            phone='13800138000',
            code='123456',
            purpose='login'
        )
        expected = '13800138000 - 123456 (login)'
        self.assertEqual(str(code), expected)


class UserAPITest(APITestCase):
    """用户API测试"""
    
    def setUp(self):
        """设置测试数据"""
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        self.token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + self.token.key)
    
    def test_get_user_profile(self):
        """测试获取用户档案"""
        url = reverse('accounts:profile')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['username'], 'testuser')
    
    def test_update_user_profile(self):
        """测试更新用户档案"""
        url = reverse('accounts:profile')
        data = {
            'nickname': '测试用户',
            'gender': 'M'
        }
        response = self.client.patch(url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # 刷新用户对象
        self.user.refresh_from_db()
        self.assertEqual(self.user.nickname, '测试用户')
        self.assertEqual(self.user.gender, 'M') 