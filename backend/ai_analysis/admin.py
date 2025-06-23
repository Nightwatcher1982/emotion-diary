from django.contrib import admin
from .models import AIAnalysisResult, EmotionInsight, AIRecommendation, ActionPlan


@admin.register(AIAnalysisResult)
class AIAnalysisResultAdmin(admin.ModelAdmin):
    list_display = ['user', 'analysis_type', 'status', 'ai_model', 'created_at']
    list_filter = ['analysis_type', 'status', 'ai_model']
    search_fields = ['user__username']
    ordering = ['-created_at']


@admin.register(EmotionInsight)
class EmotionInsightAdmin(admin.ModelAdmin):
    list_display = ['user', 'title', 'insight_type', 'priority', 'is_read']
    list_filter = ['insight_type', 'priority', 'is_read']
    search_fields = ['user__username', 'title']


@admin.register(AIRecommendation)
class AIRecommendationAdmin(admin.ModelAdmin):
    list_display = ['user', 'title', 'recommendation_type', 'is_applied', 'created_at']
    list_filter = ['recommendation_type', 'is_applied']
    search_fields = ['user__username', 'title']


@admin.register(ActionPlan)
class ActionPlanAdmin(admin.ModelAdmin):
    list_display = ['user', 'title', 'status', 'progress_percentage', 'created_at']
    list_filter = ['status']
    search_fields = ['user__username', 'title'] 