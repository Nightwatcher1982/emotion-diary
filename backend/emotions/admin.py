from django.contrib import admin
from .models import EmotionRecord, EmotionTag, EmotionPattern, EmotionGoal


@admin.register(EmotionRecord)
class EmotionRecordAdmin(admin.ModelAdmin):
    list_display = ['user', 'emotion_type', 'intensity', 'scenario', 'emotion_time']
    list_filter = ['emotion_type', 'scenario', 'intensity']
    search_fields = ['user__username', 'description']
    ordering = ['-emotion_time']


@admin.register(EmotionTag)
class EmotionTagAdmin(admin.ModelAdmin):
    list_display = ['name', 'category', 'usage_count', 'is_active']
    list_filter = ['category', 'is_active']
    search_fields = ['name']


@admin.register(EmotionPattern)
class EmotionPatternAdmin(admin.ModelAdmin):
    list_display = ['user', 'pattern_type', 'confidence_score', 'created_at']
    list_filter = ['pattern_type']
    search_fields = ['user__username']


@admin.register(EmotionGoal)
class EmotionGoalAdmin(admin.ModelAdmin):
    list_display = ['user', 'title', 'goal_type', 'status', 'completion_rate']
    list_filter = ['goal_type', 'status']
    search_fields = ['user__username', 'title'] 