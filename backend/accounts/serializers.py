from rest_framework import serializers
from django.contrib.auth import authenticate
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from django.utils import timezone
from .models import User, UserProfile, PhoneVerificationCode, WechatUserInfo
import random
import datetime
import re


class UserSerializer(serializers.ModelSerializer):
    """用户信息序列化器"""
    
    age = serializers.ReadOnlyField()
    
    class Meta:
        model = User
        fields = [
            'id', 'username', 'nickname', 'email', 'phone', 'avatar', 'bio',
            'gender', 'birth_date', 'age', 'login_type', 'is_phone_verified',
            'notification_enabled', 'daily_reminder_time', 'theme_preference',
            'analytics_consent', 'total_records', 'streak_days', 'created_at'
        ]
        read_only_fields = ['id', 'username', 'total_records', 'streak_days', 'created_at']


class UserProfileSerializer(serializers.ModelSerializer):
    """用户档案序列化器"""
    
    class Meta:
        model = UserProfile
        fields = '__all__'
        read_only_fields = ['user', 'created_at', 'updated_at']


class SendSMSSerializer(serializers.Serializer):
    """发送短信验证码序列化器"""
    
    phone = serializers.CharField(max_length=11)
    purpose = serializers.ChoiceField(choices=PhoneVerificationCode.PURPOSE_CHOICES)
    
    def validate_phone(self, value):
        """验证手机号格式"""
        if not re.match(r'^1[3-9]\d{9}$', value):
            raise serializers.ValidationError("手机号格式不正确")
        return value
    
    def validate(self, attrs):
        phone = attrs['phone']
        purpose = attrs['purpose']
        
        # 检查发送频率限制 (1分钟内只能发送一次)
        one_minute_ago = timezone.now() - datetime.timedelta(minutes=1)
        recent_code = PhoneVerificationCode.objects.filter(
            phone=phone,
            purpose=purpose,
            created_at__gte=one_minute_ago
        ).exists()
        
        if recent_code:
            raise serializers.ValidationError("发送过于频繁，请稍后再试")
        
        # 检查每日发送次数限制 (每天最多10次)
        today_start = timezone.now().replace(hour=0, minute=0, second=0, microsecond=0)
        today_count = PhoneVerificationCode.objects.filter(
            phone=phone,
            created_at__gte=today_start
        ).count()
        
        if today_count >= 10:
            raise serializers.ValidationError("今日发送次数已达上限")
        
        return attrs


class PhoneLoginSerializer(serializers.Serializer):
    """手机验证码登录序列化器"""
    
    phone = serializers.CharField(max_length=11)
    code = serializers.CharField(max_length=6)
    nickname = serializers.CharField(max_length=50, required=False, allow_blank=True)
    
    def validate_phone(self, value):
        """验证手机号格式"""
        if not re.match(r'^1[3-9]\d{9}$', value):
            raise serializers.ValidationError("手机号格式不正确")
        return value
    
    def validate(self, attrs):
        phone = attrs['phone']
        code = attrs['code']
        
        # 查找有效的验证码
        try:
            verification_code = PhoneVerificationCode.objects.filter(
                phone=phone,
                code=code,
                purpose__in=['login', 'register'],
                is_used=False
            ).latest('created_at')
        except PhoneVerificationCode.DoesNotExist:
            raise serializers.ValidationError("验证码不存在或已失效")
        
        if verification_code.is_expired():
            raise serializers.ValidationError("验证码已过期")
        
        # 标记验证码为已使用
        verification_code.is_used = True
        verification_code.save()
        
        attrs['verification_code'] = verification_code
        return attrs


class WechatLoginSerializer(serializers.Serializer):
    """微信登录序列化器"""
    
    code = serializers.CharField(max_length=100, help_text="微信授权码")
    nickname = serializers.CharField(max_length=50, required=False, allow_blank=True)
    avatar_url = serializers.URLField(required=False, allow_blank=True)
    gender = serializers.ChoiceField(
        choices=[('unknown', '未知'), ('male', '男'), ('female', '女')],
        required=False,
        default='unknown'
    )
    
    def validate_code(self, value):
        """验证微信授权码"""
        if not value:
            raise serializers.ValidationError("微信授权码不能为空")
        return value


class PhoneRegisterSerializer(serializers.Serializer):
    """手机号注册序列化器"""
    
    phone = serializers.CharField(max_length=11)
    code = serializers.CharField(max_length=6)
    nickname = serializers.CharField(max_length=50, required=False, allow_blank=True)
    
    def validate_phone(self, value):
        """验证手机号"""
        if not re.match(r'^1[3-9]\d{9}$', value):
            raise serializers.ValidationError("手机号格式不正确")
        
        if User.objects.filter(phone=value).exists():
            raise serializers.ValidationError("该手机号已被注册")
        
        return value
    
    def validate(self, attrs):
        phone = attrs['phone']
        code = attrs['code']
        
        # 验证验证码
        try:
            verification_code = PhoneVerificationCode.objects.filter(
                phone=phone,
                code=code,
                purpose='register',
                is_used=False
            ).latest('created_at')
        except PhoneVerificationCode.DoesNotExist:
            raise serializers.ValidationError("验证码不存在或已失效")
        
        if verification_code.is_expired():
            raise serializers.ValidationError("验证码已过期")
        
        # 标记验证码为已使用
        verification_code.is_used = True
        verification_code.save()
        
        attrs['verification_code'] = verification_code
        return attrs
    
    def create(self, validated_data):
        """创建用户"""
        phone = validated_data['phone']
        nickname = validated_data.get('nickname', '')
        
        # 生成唯一用户名，避免重复
        base_username = f"user_{phone}"
        username = base_username
        counter = 1
        while User.objects.filter(username=username).exists():
            username = f"{base_username}_{counter}"
            counter += 1
        
        # 创建用户
        user = User.objects.create(
            username=username,
            phone=phone,
            nickname=nickname or f"用户{phone[-4:]}",
            login_type='phone',
            is_phone_verified=True
        )
        
        # 创建用户档案
        UserProfile.objects.create(user=user)
        
        return user


# 原有的序列化器保持兼容
class RegisterSerializer(serializers.ModelSerializer):
    """传统密码注册序列化器 (兼容)"""
    
    password = serializers.CharField(write_only=True, min_length=8)
    password_confirm = serializers.CharField(write_only=True)
    
    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'password_confirm', 'nickname']
        
    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError("两次输入的密码不一致")
        return attrs
    
    def validate_password(self, value):
        try:
            validate_password(value)
        except ValidationError as e:
            raise serializers.ValidationError(list(e.messages))
        return value
    
    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("该邮箱已被注册")
        return value
    
    def validate_username(self, value):
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError("该用户名已被注册")
        return value
    
    def create(self, validated_data):
        # 移除确认密码字段
        validated_data.pop('password_confirm')
        
        # 创建用户
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
            nickname=validated_data.get('nickname', ''),
            login_type='password'
        )
        
        # 创建用户档案
        UserProfile.objects.create(user=user)
        
        return user


class LoginSerializer(serializers.Serializer):
    """传统密码登录序列化器 (兼容)"""
    
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)
    
    def validate_username(self, value):
        if not value:
            raise serializers.ValidationError("用户名不能为空")
        return value
    
    def validate_password(self, value):
        if not value:
            raise serializers.ValidationError("密码不能为空")
        return value


class ChangePasswordSerializer(serializers.Serializer):
    """修改密码序列化器"""
    
    old_password = serializers.CharField(write_only=True)
    new_password = serializers.CharField(write_only=True, min_length=8)
    new_password_confirm = serializers.CharField(write_only=True)
    
    def validate_new_password(self, value):
        try:
            validate_password(value)
        except ValidationError as e:
            raise serializers.ValidationError(list(e.messages))
        return value
    
    def validate(self, attrs):
        if attrs['new_password'] != attrs['new_password_confirm']:
            raise serializers.ValidationError("两次输入的新密码不一致")
        return attrs


class ProfileUpdateSerializer(serializers.ModelSerializer):
    """用户资料更新序列化器"""
    
    class Meta:
        model = User
        fields = [
            'nickname', 'bio', 'gender', 'birth_date', 'avatar',
            'notification_enabled', 'daily_reminder_time', 'theme_preference',
            'analytics_consent'
        ]
    
    def validate_nickname(self, value):
        if len(value) > 50:
            raise serializers.ValidationError("昵称长度不能超过50个字符")
        return value
    
    def validate_bio(self, value):
        if len(value) > 500:
            raise serializers.ValidationError("个人简介长度不能超过500个字符")
        return value 