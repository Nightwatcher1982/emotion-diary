from django.db import models
from django.contrib.auth import get_user_model
from django.core.validators import MinValueValidator, MaxValueValidator
from django.utils import timezone

User = get_user_model()


class EmotionRecord(models.Model):
    """情绪记录主表"""
    
    EMOTION_TYPES = [
        ('happy', '快乐'),
        ('sad', '悲伤'),
        ('angry', '愤怒'),
        ('anxious', '焦虑'),
        ('calm', '平静'),
        ('fearful', '恐惧'),
        ('excited', '兴奋'),
        ('frustrated', '沮丧'),
        ('grateful', '感激'),
        ('lonely', '孤独'),
        ('confident', '自信'),
        ('overwhelmed', '不知所措'),
    ]
    
    SCENARIO_TYPES = [
        ('work', '工作'),
        ('study', '学习'),
        ('family', '家庭'),
        ('social', '社交'),
        ('health', '健康'),
        ('finance', '财务'),
        ('relationship', '感情'),
        ('personal', '个人成长'),
        ('entertainment', '娱乐'),
        ('travel', '旅行'),
        ('other', '其他'),
    ]
    
    # 基本信息
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='emotion_records', verbose_name='用户')
    
    # 情绪描述
    description = models.TextField('情绪描述', max_length=1000, help_text='用户对当前情绪的文字描述')
    emotion_type = models.CharField('主要情绪', max_length=20, choices=EMOTION_TYPES)
    intensity = models.IntegerField('情绪强度', validators=[MinValueValidator(1), MaxValueValidator(10)], help_text='1-10级')
    
    # 场景信息
    scenario = models.CharField('发生场景', max_length=20, choices=SCENARIO_TYPES)
    location = models.CharField('地点', max_length=100, blank=True)
    weather = models.CharField('天气', max_length=50, blank=True)
    
    # 触发因素
    triggers = models.JSONField('触发因素', default=list, blank=True, help_text='导致该情绪的具体事件或因素')
    people_involved = models.JSONField('相关人员', default=list, blank=True, help_text='涉及的人员关系')
    
    # 身体反应
    physical_symptoms = models.JSONField('身体症状', default=list, blank=True, help_text='伴随的身体反应')
    
    # 应对方式
    coping_methods = models.JSONField('应对方式', default=list, blank=True, help_text='用户采取的应对措施')
    effectiveness_rating = models.IntegerField('应对效果', validators=[MinValueValidator(1), MaxValueValidator(5)], 
                                             null=True, blank=True, help_text='应对方式的效果评分1-5')
    
    # 记录设置
    is_private = models.BooleanField('私密记录', default=False)
    enable_ai_analysis = models.BooleanField('启用AI分析', default=True)
    
    # 时间信息
    emotion_time = models.DateTimeField('情绪发生时间', default=timezone.now)
    created_at = models.DateTimeField('记录时间', auto_now_add=True)
    updated_at = models.DateTimeField('更新时间', auto_now=True)
    
    # 状态
    is_analyzed = models.BooleanField('已分析', default=False)
    analysis_requested_at = models.DateTimeField('请求分析时间', null=True, blank=True)
    
    class Meta:
        db_table = 'emotion_records'
        verbose_name = '情绪记录'
        verbose_name_plural = '情绪记录'
        ordering = ['-emotion_time']
        indexes = [
            models.Index(fields=['user', '-emotion_time']),
            models.Index(fields=['emotion_type']),
            models.Index(fields=['scenario']),
            models.Index(fields=['is_analyzed']),
        ]
    
    def __str__(self):
        return f"{self.user.nickname} - {self.get_emotion_type_display()} ({self.emotion_time.strftime('%Y-%m-%d %H:%M')})"
    
    def save(self, *args, **kwargs):
        # 保存时更新用户的记录统计
        is_new = self.pk is None
        super().save(*args, **kwargs)
        
        if is_new:
            self.user.update_streak()


class EmotionTag(models.Model):
    """情绪标签"""
    
    TAG_CATEGORIES = [
        ('emotion', '情绪类型'),
        ('intensity', '强度描述'),
        ('trigger', '触发因素'),
        ('symptom', '症状表现'),
        ('coping', '应对方式'),
        ('outcome', '结果状态'),
    ]
    
    name = models.CharField('标签名称', max_length=50, unique=True)
    category = models.CharField('标签分类', max_length=20, choices=TAG_CATEGORIES)
    color = models.CharField('显示颜色', max_length=7, default='#007AFF', help_text='十六进制颜色值')
    icon = models.CharField('图标', max_length=50, blank=True)
    description = models.TextField('描述', max_length=200, blank=True)
    
    # 使用统计
    usage_count = models.PositiveIntegerField('使用次数', default=0)
    is_system = models.BooleanField('系统标签', default=False, help_text='系统预设标签不可删除')
    is_active = models.BooleanField('启用状态', default=True)
    
    created_at = models.DateTimeField('创建时间', auto_now_add=True)
    updated_at = models.DateTimeField('更新时间', auto_now=True)
    
    class Meta:
        db_table = 'emotion_tags'
        verbose_name = '情绪标签'
        verbose_name_plural = '情绪标签'
        ordering = ['-usage_count', 'name']
    
    def __str__(self):
        return self.name


class RecordTag(models.Model):
    """记录与标签的关联"""
    
    record = models.ForeignKey(EmotionRecord, on_delete=models.CASCADE, related_name='tags')
    tag = models.ForeignKey(EmotionTag, on_delete=models.CASCADE, related_name='records')
    created_at = models.DateTimeField('添加时间', auto_now_add=True)
    
    class Meta:
        db_table = 'record_tags'
        verbose_name = '记录标签'
        verbose_name_plural = '记录标签'
        unique_together = ['record', 'tag']
    
    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)
        # 更新标签使用次数
        self.tag.usage_count += 1
        self.tag.save(update_fields=['usage_count'])


class EmotionPattern(models.Model):
    """情绪模式分析"""
    
    PATTERN_TYPES = [
        ('daily', '日常模式'),
        ('weekly', '周期模式'),
        ('seasonal', '季节模式'),
        ('trigger', '触发模式'),
        ('social', '社交模式'),
        ('work', '工作模式'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='emotion_patterns')
    pattern_type = models.CharField('模式类型', max_length=20, choices=PATTERN_TYPES)
    
    # 模式数据
    pattern_data = models.JSONField('模式数据', help_text='具体的模式分析结果')
    confidence_score = models.FloatField('置信度', validators=[MinValueValidator(0.0), MaxValueValidator(1.0)])
    
    # 时间范围
    start_date = models.DateField('开始日期')
    end_date = models.DateField('结束日期')
    
    # 统计信息
    record_count = models.PositiveIntegerField('记录数量')
    dominant_emotion = models.CharField('主导情绪', max_length=20)
    average_intensity = models.FloatField('平均强度')
    
    created_at = models.DateTimeField('创建时间', auto_now_add=True)
    updated_at = models.DateTimeField('更新时间', auto_now=True)
    
    class Meta:
        db_table = 'emotion_patterns'
        verbose_name = '情绪模式'
        verbose_name_plural = '情绪模式'
        ordering = ['-created_at']
        unique_together = ['user', 'pattern_type', 'start_date', 'end_date']
    
    def __str__(self):
        return f"{self.user.nickname} - {self.get_pattern_type_display()} ({self.start_date} ~ {self.end_date})"


class EmotionGoal(models.Model):
    """情绪管理目标"""
    
    GOAL_TYPES = [
        ('reduce_negative', '减少负面情绪'),
        ('increase_positive', '增加正面情绪'),
        ('improve_stability', '提高情绪稳定性'),
        ('enhance_awareness', '增强情绪觉察'),
        ('better_coping', '改善应对方式'),
        ('custom', '自定义目标'),
    ]
    
    STATUS_CHOICES = [
        ('active', '进行中'),
        ('completed', '已完成'),
        ('paused', '已暂停'),
        ('cancelled', '已取消'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='emotion_goals')
    goal_type = models.CharField('目标类型', max_length=20, choices=GOAL_TYPES)
    title = models.CharField('目标标题', max_length=100)
    description = models.TextField('目标描述', max_length=500)
    
    # 目标设置
    target_value = models.FloatField('目标值', help_text='根据目标类型设定的数值目标')
    current_value = models.FloatField('当前值', default=0.0)
    unit = models.CharField('单位', max_length=20, default='次')
    
    # 时间设置
    start_date = models.DateField('开始日期')
    target_date = models.DateField('目标日期')
    reminder_frequency = models.CharField('提醒频率', max_length=20, default='daily')
    
    # 状态
    status = models.CharField('状态', max_length=20, choices=STATUS_CHOICES, default='active')
    completion_rate = models.FloatField('完成率', default=0.0, validators=[MinValueValidator(0.0), MaxValueValidator(100.0)])
    
    created_at = models.DateTimeField('创建时间', auto_now_add=True)
    updated_at = models.DateTimeField('更新时间', auto_now=True)
    completed_at = models.DateTimeField('完成时间', null=True, blank=True)
    
    class Meta:
        db_table = 'emotion_goals'
        verbose_name = '情绪目标'
        verbose_name_plural = '情绪目标'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.user.nickname} - {self.title}"
    
    def update_progress(self):
        """更新目标进度"""
        if self.target_value > 0:
            self.completion_rate = min(100.0, (self.current_value / self.target_value) * 100)
            if self.completion_rate >= 100.0 and self.status == 'active':
                self.status = 'completed'
                self.completed_at = timezone.now()
        self.save() 