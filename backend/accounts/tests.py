"""
Accounts应用测试
"""

from django.test import TestCase
from django.contrib.auth import get_user_model
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