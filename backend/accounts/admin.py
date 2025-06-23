from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.utils.translation import gettext_lazy as _
from .models import User, UserProfile


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    """自定义用户管理"""
    
    list_display = ('username', 'nickname', 'email', 'is_staff', 'is_active', 'created_at')
    list_filter = ('is_staff', 'is_superuser', 'is_active', 'gender', 'created_at')
    search_fields = ('username', 'nickname', 'email')
    ordering = ('-created_at',)
    
    fieldsets = (
        (None, {'fields': ('username', 'password')}),
        (_('Personal info'), {'fields': ('nickname', 'email', 'avatar', 'bio', 'gender', 'birth_date')}),
        (_('Settings'), {'fields': ('timezone_setting', 'notification_enabled', 'daily_reminder_time', 'theme_preference')}),
        (_('Privacy'), {'fields': ('data_sharing_consent', 'analytics_consent')}),
        (_('Statistics'), {'fields': ('total_records', 'streak_days', 'last_record_date')}),
        (_('Permissions'), {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        (_('Important dates'), {'fields': ('last_login', 'date_joined')}),
    )
    
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('username', 'email', 'password1', 'password2'),
        }),
    )
    
    readonly_fields = ('total_records', 'streak_days', 'last_record_date', 'created_at')


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    """用户档案管理"""
    
    list_display = ('user', 'occupation', 'work_stress_level', 'anxiety_tendency', 'created_at')
    list_filter = ('occupation', 'work_stress_level', 'anxiety_tendency', 'depression_tendency')
    search_fields = ('user__username', 'user__nickname')
    ordering = ('-created_at',)
    
    fieldsets = (
        (_('User'), {'fields': ('user',)}),
        (_('Occupation'), {'fields': ('occupation', 'work_stress_level')}),
        (_('Life Habits'), {'fields': ('sleep_time', 'wake_time', 'exercise_frequency')}),
        (_('Mental Health'), {'fields': ('anxiety_tendency', 'depression_tendency', 'stress_coping_ability')}),
        (_('Preferences'), {'fields': ('preferred_analysis_depth', 'favorite_emotions', 'favorite_scenarios')}),
    )
    
    readonly_fields = ('created_at', 'updated_at') 