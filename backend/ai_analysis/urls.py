from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'analyses', views.AIAnalysisResultViewSet)
router.register(r'insights', views.EmotionInsightViewSet)
router.register(r'recommendations', views.AIRecommendationViewSet)
router.register(r'action-plans', views.ActionPlanViewSet)

urlpatterns = [
    # AI分析相关
    path('analyze/', views.AnalyzeEmotionView.as_view(), name='analyze-emotion'),
    path('batch-analyze/', views.BatchAnalyzeView.as_view(), name='batch-analyze'),
    path('generate-insights/', views.GenerateInsightsView.as_view(), name='generate-insights'),
    path('get-recommendations/', views.GetRecommendationsView.as_view(), name='get-recommendations'),
    
    # 行动计划
    path('create-plan/', views.CreateActionPlanView.as_view(), name='create-action-plan'),
    path('plan-progress/', views.PlanProgressView.as_view(), name='plan-progress'),
    
    # 使用统计
    path('usage-stats/', views.UsageStatsView.as_view(), name='usage-stats'),
    
    # RESTful API
    path('', include(router.urls)),
] 