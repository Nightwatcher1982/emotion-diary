from django.db import models
from django.contrib.auth import get_user_model
from django.core.validators import MinValueValidator, MaxValueValidator
from django.utils import timezone
from emotions.models import EmotionRecord

User = get_user_model()


class AIAnalysisResult(models.Model):
    """AI分析结果"""
    
    ANALYSIS_TYPES = [
        ('basic', '基础分析'),
        ('deep', '深度分析'),
        ('pattern', '模式分析'),
        ('prediction', '趋势预测'),
        ('recommendation', '建议生成'),
    ]
    
    STATUS_CHOICES = [
        ('pending', '等待中'),
        ('processing', '分析中'),
        ('completed', '已完成'),
        ('failed', '失败'),
        ('cancelled', '已取消'),
    ]
    
    # 关联信息
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='ai_analyses')
    emotion_record = models.ForeignKey(EmotionRecord, on_delete=models.CASCADE, 
                                     related_name='ai_analyses', null=True, blank=True)
    
    # 分析设置
    analysis_type = models.CharField('分析类型', max_length=20, choices=ANALYSIS_TYPES)
    status = models.CharField('状态', max_length=20, choices=STATUS_CHOICES, default='pending')
    
    # AI服务信息
    ai_model = models.CharField('AI模型', max_length=50, default='ERNIE-Bot')
    model_version = models.CharField('模型版本', max_length=20, blank=True)
    request_id = models.CharField('请求ID', max_length=100, blank=True)
    
    # 分析结果
    analysis_result = models.JSONField('分析结果', default=dict, blank=True)
    confidence_score = models.FloatField('置信度', validators=[MinValueValidator(0.0), MaxValueValidator(1.0)], 
                                       null=True, blank=True)
    
    # 处理信息
    processing_time = models.FloatField('处理时间(秒)', null=True, blank=True)
    error_message = models.TextField('错误信息', blank=True)
    retry_count = models.PositiveIntegerField('重试次数', default=0)
    
    # 时间戳
    created_at = models.DateTimeField('创建时间', auto_now_add=True)
    started_at = models.DateTimeField('开始时间', null=True, blank=True)
    completed_at = models.DateTimeField('完成时间', null=True, blank=True)
    
    class Meta:
        db_table = 'ai_analysis_results'
        verbose_name = 'AI分析结果'
        verbose_name_plural = 'AI分析结果'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['status']),
            models.Index(fields=['analysis_type']),
        ]
    
    def __str__(self):
        return f"{self.user.nickname} - {self.get_analysis_type_display()} ({self.status})"


class EmotionInsight(models.Model):
    """情绪洞察"""
    
    INSIGHT_TYPES = [
        ('emotion_pattern', '情绪模式'),
        ('trigger_analysis', '触发因素分析'),
        ('coping_effectiveness', '应对方式效果'),
        ('emotional_growth', '情绪成长'),
        ('risk_assessment', '风险评估'),
        ('strength_identification', '优势识别'),
    ]
    
    PRIORITY_LEVELS = [
        ('low', '低'),
        ('medium', '中'),
        ('high', '高'),
        ('urgent', '紧急'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='emotion_insights')
    analysis_result = models.ForeignKey(AIAnalysisResult, on_delete=models.CASCADE, 
                                      related_name='insights', null=True, blank=True)
    
    # 洞察信息
    insight_type = models.CharField('洞察类型', max_length=30, choices=INSIGHT_TYPES)
    title = models.CharField('标题', max_length=200)
    description = models.TextField('描述', max_length=1000)
    
    # 重要性和可信度
    priority = models.CharField('优先级', max_length=10, choices=PRIORITY_LEVELS, default='medium')
    confidence = models.FloatField('可信度', validators=[MinValueValidator(0.0), MaxValueValidator(1.0)])
    
    # 相关数据
    supporting_data = models.JSONField('支撑数据', default=dict, blank=True)
    time_range = models.JSONField('时间范围', default=dict, blank=True)
    
    # 状态
    is_read = models.BooleanField('已读', default=False)
    is_archived = models.BooleanField('已归档', default=False)
    user_feedback = models.CharField('用户反馈', max_length=20, blank=True, 
                                   choices=[('helpful', '有帮助'), ('not_helpful', '没帮助'), ('inaccurate', '不准确')])
    
    created_at = models.DateTimeField('创建时间', auto_now_add=True)
    read_at = models.DateTimeField('阅读时间', null=True, blank=True)
    
    class Meta:
        db_table = 'emotion_insights'
        verbose_name = '情绪洞察'
        verbose_name_plural = '情绪洞察'
        ordering = ['-priority', '-created_at']
    
    def __str__(self):
        return f"{self.user.nickname} - {self.title}"


class AIRecommendation(models.Model):
    """AI建议"""
    
    RECOMMENDATION_TYPES = [
        ('immediate_coping', '即时应对'),
        ('long_term_strategy', '长期策略'),
        ('lifestyle_change', '生活方式'),
        ('social_support', '社交支持'),
        ('professional_help', '专业帮助'),
        ('self_care', '自我关怀'),
        ('skill_development', '技能发展'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='ai_recommendations')
    analysis_result = models.ForeignKey(AIAnalysisResult, on_delete=models.CASCADE, 
                                      related_name='recommendations', null=True, blank=True)
    
    # 建议信息
    recommendation_type = models.CharField('建议类型', max_length=30, choices=RECOMMENDATION_TYPES)
    title = models.CharField('标题', max_length=200)
    content = models.TextField('内容', max_length=2000)
    
    # 实施指导
    action_steps = models.JSONField('行动步骤', default=list, blank=True)
    difficulty_level = models.IntegerField('难度等级', validators=[MinValueValidator(1), MaxValueValidator(5)], default=3)
    estimated_time = models.CharField('预估时间', max_length=50, blank=True)
    
    # 个性化程度
    personalization_score = models.FloatField('个性化程度', validators=[MinValueValidator(0.0), MaxValueValidator(1.0)])
    relevance_score = models.FloatField('相关度', validators=[MinValueValidator(0.0), MaxValueValidator(1.0)])
    
    # 用户互动
    is_applied = models.BooleanField('已应用', default=False)
    effectiveness_rating = models.IntegerField('效果评分', validators=[MinValueValidator(1), MaxValueValidator(5)], 
                                             null=True, blank=True)
    user_notes = models.TextField('用户笔记', max_length=500, blank=True)
    
    created_at = models.DateTimeField('创建时间', auto_now_add=True)
    applied_at = models.DateTimeField('应用时间', null=True, blank=True)
    
    class Meta:
        db_table = 'ai_recommendations'
        verbose_name = 'AI建议'
        verbose_name_plural = 'AI建议'
        ordering = ['-relevance_score', '-created_at']
    
    def __str__(self):
        return f"{self.user.nickname} - {self.title}"


class ActionPlan(models.Model):
    """行动计划"""
    
    STATUS_CHOICES = [
        ('draft', '草稿'),
        ('active', '进行中'),
        ('completed', '已完成'),
        ('paused', '已暂停'),
        ('cancelled', '已取消'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='action_plans')
    recommendations = models.ManyToManyField(AIRecommendation, related_name='action_plans', blank=True)
    
    # 计划信息
    title = models.CharField('计划标题', max_length=200)
    description = models.TextField('计划描述', max_length=1000, blank=True)
    
    # 时间设置
    start_date = models.DateField('开始日期')
    end_date = models.DateField('结束日期', null=True, blank=True)
    duration_days = models.PositiveIntegerField('持续天数', default=7)
    
    # 状态跟踪
    status = models.CharField('状态', max_length=20, choices=STATUS_CHOICES, default='draft')
    progress_percentage = models.FloatField('进度百分比', default=0.0, 
                                          validators=[MinValueValidator(0.0), MaxValueValidator(100.0)])
    
    # 提醒设置
    daily_reminder = models.BooleanField('每日提醒', default=True)
    reminder_time = models.TimeField('提醒时间', default='09:00')
    
    created_at = models.DateTimeField('创建时间', auto_now_add=True)
    updated_at = models.DateTimeField('更新时间', auto_now=True)
    completed_at = models.DateTimeField('完成时间', null=True, blank=True)
    
    class Meta:
        db_table = 'action_plans'
        verbose_name = '行动计划'
        verbose_name_plural = '行动计划'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.user.nickname} - {self.title}"


class PlanTask(models.Model):
    """计划任务"""
    
    STATUS_CHOICES = [
        ('pending', '待办'),
        ('in_progress', '进行中'),
        ('completed', '已完成'),
        ('skipped', '已跳过'),
    ]
    
    action_plan = models.ForeignKey(ActionPlan, on_delete=models.CASCADE, related_name='tasks')
    
    # 任务信息
    title = models.CharField('任务标题', max_length=200)
    description = models.TextField('任务描述', max_length=500, blank=True)
    order = models.PositiveIntegerField('排序', default=0)
    
    # 时间设置
    scheduled_date = models.DateField('计划日期', null=True, blank=True)
    estimated_duration = models.PositiveIntegerField('预估时长(分钟)', default=30)
    
    # 状态
    status = models.CharField('状态', max_length=20, choices=STATUS_CHOICES, default='pending')
    completion_notes = models.TextField('完成备注', max_length=300, blank=True)
    
    created_at = models.DateTimeField('创建时间', auto_now_add=True)
    completed_at = models.DateTimeField('完成时间', null=True, blank=True)
    
    class Meta:
        db_table = 'plan_tasks'
        verbose_name = '计划任务'
        verbose_name_plural = '计划任务'
        ordering = ['action_plan', 'order', 'scheduled_date']
    
    def __str__(self):
        return f"{self.action_plan.title} - {self.title}"


class AIModelUsage(models.Model):
    """AI模型使用统计"""
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='ai_usage_stats')
    
    # 使用统计
    date = models.DateField('日期', default=timezone.now)
    total_requests = models.PositiveIntegerField('总请求数', default=0)
    successful_requests = models.PositiveIntegerField('成功请求数', default=0)
    failed_requests = models.PositiveIntegerField('失败请求数', default=0)
    
    # 类型统计
    basic_analysis_count = models.PositiveIntegerField('基础分析次数', default=0)
    deep_analysis_count = models.PositiveIntegerField('深度分析次数', default=0)
    recommendation_count = models.PositiveIntegerField('建议生成次数', default=0)
    
    # 性能统计
    total_processing_time = models.FloatField('总处理时间(秒)', default=0.0)
    average_processing_time = models.FloatField('平均处理时间(秒)', default=0.0)
    
    # 成本统计
    token_usage = models.PositiveIntegerField('Token使用量', default=0)
    estimated_cost = models.DecimalField('预估成本(元)', max_digits=10, decimal_places=4, default=0.0000)
    
    created_at = models.DateTimeField('创建时间', auto_now_add=True)
    updated_at = models.DateTimeField('更新时间', auto_now=True)
    
    class Meta:
        db_table = 'ai_model_usage'
        verbose_name = 'AI模型使用统计'
        verbose_name_plural = 'AI模型使用统计'
        ordering = ['-date']
        unique_together = ['user', 'date']
    
    def __str__(self):
        return f"{self.user.nickname} - {self.date} ({self.total_requests}次请求)" 