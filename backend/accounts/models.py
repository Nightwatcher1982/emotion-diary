from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils import timezone
import datetime


class User(AbstractUser):
    """自定义用户模型 - 支持多种登录方式"""
    
    GENDER_CHOICES = [
        ('M', '男'),
        ('F', '女'),
        ('O', '其他'),
        ('N', '不愿透露'),
    ]
    
    LOGIN_TYPE_CHOICES = [
        ('password', '密码登录'),
        ('phone', '手机验证码'),
        ('wechat', '微信登录'),
    ]
    
    # 基本信息
    nickname = models.CharField('昵称', max_length=50, blank=True, default='')
    phone = models.CharField('手机号', max_length=11, unique=True, null=True, blank=True)
    avatar = models.URLField('头像', blank=True, default='')
    bio = models.TextField('个人简介', max_length=500, blank=True, default='')
    gender = models.CharField('性别', max_length=1, choices=GENDER_CHOICES, default='N')
    birth_date = models.DateField('出生日期', blank=True, null=True)
    
    # 第三方登录信息
    wechat_openid = models.CharField('微信OpenID', max_length=100, unique=True, null=True, blank=True)
    wechat_unionid = models.CharField('微信UnionID', max_length=100, unique=True, null=True, blank=True)
    
    # 登录方式和状态
    login_type = models.CharField('登录方式', max_length=20, choices=LOGIN_TYPE_CHOICES, default='password')
    is_phone_verified = models.BooleanField('手机号已验证', default=False)
    last_login_ip = models.GenericIPAddressField('最后登录IP', null=True, blank=True)
    
    # 设置选项
    timezone_setting = models.CharField('时区设置', max_length=50, default='Asia/Shanghai')
    notification_enabled = models.BooleanField('推送通知', default=True)
    daily_reminder_time = models.TimeField('每日提醒时间', default='21:00')
    theme_preference = models.CharField('主题偏好', max_length=20, default='auto')
    
    # 隐私设置
    data_sharing_consent = models.BooleanField('数据分享同意', default=False)
    analytics_consent = models.BooleanField('数据分析同意', default=True)
    
    # 统计信息
    total_records = models.PositiveIntegerField('总记录数', default=0)
    streak_days = models.PositiveIntegerField('连续记录天数', default=0)
    last_record_date = models.DateField('最后记录日期', blank=True, null=True)
    
    # 时间戳
    created_at = models.DateTimeField('创建时间', auto_now_add=True)
    updated_at = models.DateTimeField('更新时间', auto_now=True)
    
    class Meta:
        db_table = 'users'
        verbose_name = '用户'
        verbose_name_plural = '用户'
    
    def __str__(self):
        return self.nickname or self.username
    
    @property
    def age(self):
        """计算年龄"""
        if self.birth_date:
            today = timezone.now().date()
            return today.year - self.birth_date.year - ((today.month, today.day) < (self.birth_date.month, self.birth_date.day))
        return None
    
    def update_streak(self):
        """更新连续记录天数"""
        from emotions.models import EmotionRecord
        
        today = timezone.now().date()
        yesterday = today - datetime.timedelta(days=1)
        
        # 检查今天是否有记录
        today_records = EmotionRecord.objects.filter(
            user=self,
            emotion_time__date=today
        ).exists()
        
        # 检查昨天是否有记录
        yesterday_records = EmotionRecord.objects.filter(
            user=self,
            emotion_time__date=yesterday
        ).exists()
        
        if today_records:
            if yesterday_records or self.streak_days == 0:
                self.streak_days += 1
            self.last_record_date = today
        else:
            if not yesterday_records:
                self.streak_days = 0
        
        self.save(update_fields=['streak_days', 'last_record_date'])


class PhoneVerificationCode(models.Model):
    """手机验证码"""
    
    PURPOSE_CHOICES = [
        ('login', '登录'),
        ('register', '注册'),
        ('reset_password', '重置密码'),
        ('bind_phone', '绑定手机'),
    ]
    
    phone = models.CharField('手机号', max_length=11)
    code = models.CharField('验证码', max_length=6)
    purpose = models.CharField('用途', max_length=20, choices=PURPOSE_CHOICES)
    is_used = models.BooleanField('是否已使用', default=False)
    created_at = models.DateTimeField('创建时间', auto_now_add=True)
    expires_at = models.DateTimeField('过期时间')
    
    class Meta:
        db_table = 'phone_verification_codes'
        verbose_name = '手机验证码'
        verbose_name_plural = '手机验证码'
        ordering = ['-created_at']
    
    def is_expired(self):
        """检查是否过期"""
        return timezone.now() > self.expires_at
    
    def is_valid(self):
        """检查验证码是否有效"""
        return not self.is_used and not self.is_expired()
    
    def __str__(self):
        return f'{self.phone} - {self.code} ({self.purpose})'


class WechatUserInfo(models.Model):
    """微信用户信息"""
    
    GENDER_CHOICES = [
        ('unknown', '未知'),
        ('male', '男'),
        ('female', '女'),
    ]
    
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='wechat_info')
    openid = models.CharField('OpenID', max_length=100, unique=True)
    unionid = models.CharField('UnionID', max_length=100, unique=True, null=True, blank=True)
    nickname = models.CharField('微信昵称', max_length=100, blank=True)
    avatar_url = models.URLField('微信头像', blank=True)
    gender = models.CharField('性别', max_length=10, choices=GENDER_CHOICES, default='unknown')
    city = models.CharField('城市', max_length=50, blank=True)
    province = models.CharField('省份', max_length=50, blank=True)
    country = models.CharField('国家', max_length=50, blank=True)
    created_at = models.DateTimeField('绑定时间', auto_now_add=True)
    updated_at = models.DateTimeField('更新时间', auto_now=True)
    
    class Meta:
        db_table = 'wechat_user_info'
        verbose_name = '微信用户信息'
        verbose_name_plural = '微信用户信息'
    
    def __str__(self):
        return f'{self.user.username} - {self.nickname}'


class UserProfile(models.Model):
    """用户扩展档案"""
    
    OCCUPATION_CHOICES = [
        ('student', '学生'),
        ('employee', '职员'),
        ('freelancer', '自由职业者'),
        ('entrepreneur', '创业者'),
        ('retired', '退休'),
        ('unemployed', '待业'),
        ('other', '其他'),
    ]
    
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    
    # 职业信息
    occupation = models.CharField('职业', max_length=20, choices=OCCUPATION_CHOICES, blank=True)
    work_stress_level = models.IntegerField('工作压力等级', default=3, help_text='1-5级')
    
    # 生活习惯
    sleep_time = models.TimeField('平均睡觉时间', blank=True, null=True)
    wake_time = models.TimeField('平均起床时间', blank=True, null=True)
    exercise_frequency = models.IntegerField('运动频率(次/周)', default=0)
    
    # 心理健康相关
    anxiety_tendency = models.IntegerField('焦虑倾向', default=3, help_text='1-5级')
    depression_tendency = models.IntegerField('抑郁倾向', default=3, help_text='1-5级')
    stress_coping_ability = models.IntegerField('压力应对能力', default=3, help_text='1-5级')
    
    # 应用使用偏好
    preferred_analysis_depth = models.CharField('偏好分析深度', max_length=20, default='moderate')
    favorite_emotions = models.JSONField('常用情绪标签', default=list, blank=True)
    favorite_scenarios = models.JSONField('常用场景标签', default=list, blank=True)
    
    created_at = models.DateTimeField('创建时间', auto_now_add=True)
    updated_at = models.DateTimeField('更新时间', auto_now=True)
    
    class Meta:
        db_table = 'user_profiles'
        verbose_name = '用户档案'
        verbose_name_plural = '用户档案'
    
    def __str__(self):
        return f'{self.user.username}的档案' 