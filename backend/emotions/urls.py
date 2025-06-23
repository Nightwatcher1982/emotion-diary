from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'records', views.EmotionRecordViewSet)
router.register(r'tags', views.EmotionTagViewSet)
router.register(r'patterns', views.EmotionPatternViewSet)
router.register(r'goals', views.EmotionGoalViewSet)

urlpatterns = [
    # 统计分析 - 详细API
    path('statistics/overview/', views.StatisticsOverviewView.as_view(), name='statistics-overview'),
    path('statistics/trend/', views.StatisticsTrendView.as_view(), name='statistics-trend'),
    path('statistics/distribution/', views.StatisticsDistributionView.as_view(), name='statistics-distribution'),
    path('statistics/scenes/', views.StatisticsScenesView.as_view(), name='statistics-scenes'),
    path('statistics/time-pattern/', views.StatisticsTimePatternView.as_view(), name='statistics-time-pattern'),
    
    # 原有统计API
    path('statistics/', views.EmotionStatisticsView.as_view(), name='emotion-statistics'),
    path('trends/', views.EmotionTrendsView.as_view(), name='emotion-trends'),
    path('export/', views.ExportDataView.as_view(), name='export-data'),
    
    # 快捷操作
    path('quick-record/', views.QuickRecordView.as_view(), name='quick-record'),
    path('recent/', views.RecentRecordsView.as_view(), name='recent-records'),
    
    # RESTful API
    path('', include(router.urls)),
] 