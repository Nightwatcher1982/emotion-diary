from rest_framework import generics, viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from django.db.models import Count, Avg, Q
from datetime import datetime, timedelta
from drf_spectacular.utils import extend_schema, OpenApiParameter
from .models import EmotionRecord, EmotionTag, EmotionPattern, EmotionGoal
from .serializers import (
    EmotionRecordSerializer, EmotionTagSerializer, EmotionPatternSerializer,
    EmotionGoalSerializer, QuickRecordSerializer, EmotionStatisticsSerializer
)


class EmotionRecordViewSet(viewsets.ModelViewSet):
    """情绪记录ViewSet"""
    queryset = EmotionRecord.objects.all()
    serializer_class = EmotionRecordSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return EmotionRecord.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
    
    @extend_schema(
        summary="获取情绪记录列表",
        description="获取当前用户的情绪记录列表",
        tags=["情绪记录"]
    )
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
    
    @extend_schema(
        summary="创建情绪记录",
        description="创建新的情绪记录",
        tags=["情绪记录"]
    )
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)
    
    @action(detail=False, methods=['get'])
    def today(self, request):
        """获取今日情绪记录"""
        today = timezone.now().date()
        records = self.get_queryset().filter(emotion_time__date=today)
        serializer = self.get_serializer(records, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def this_week(self, request):
        """获取本周情绪记录"""
        today = timezone.now().date()
        week_start = today - timedelta(days=today.weekday())
        records = self.get_queryset().filter(emotion_time__date__gte=week_start)
        serializer = self.get_serializer(records, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def recent(self, request):
        """获取最近记录"""
        records = self.get_queryset().order_by('-created_at')[:10]
        serializer = self.get_serializer(records, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def statistics(self, request):
        """获取情绪统计"""
        period = request.query_params.get('period', 'week')
        user = request.user
        
        # 计算时间范围
        end_date = timezone.now().date()
        if period == 'week':
            start_date = end_date - timedelta(days=7)
        elif period == 'month':
            start_date = end_date - timedelta(days=30)
        elif period == 'quarter':
            start_date = end_date - timedelta(days=90)
        elif period == 'year':
            start_date = end_date - timedelta(days=365)
        else:
            start_date = end_date - timedelta(days=7)
        
        # 获取记录
        records = self.get_queryset().filter(
            emotion_time__date__gte=start_date,
            emotion_time__date__lte=end_date
        )
        
        # 统计数据
        total_records = records.count()
        
        # 情绪分布
        emotion_distribution = records.values('emotion_type').annotate(
            count=Count('id')
        ).order_by('-count')
        
        # 场景分布
        scenario_distribution = records.values('scenario').annotate(
            count=Count('id')
        ).order_by('-count')
        
        # 平均强度
        avg_intensity = records.aggregate(avg=Avg('intensity'))['avg'] or 0
        
        statistics = {
            'period': period,
            'date_range': {
                'start_date': start_date,
                'end_date': end_date
            },
            'overview': {
                'total_records': total_records,
                'avg_intensity': round(avg_intensity, 2),
                'most_common_emotion': emotion_distribution[0]['emotion_type'] if emotion_distribution else None,
                'most_common_scenario': scenario_distribution[0]['scenario'] if scenario_distribution else None
            },
            'emotion_distribution': list(emotion_distribution),
            'scenario_distribution': list(scenario_distribution)
        }
        
        return Response(statistics)
    
    @action(detail=False, methods=['post'])
    def quick_record(self, request):
        """快速记录"""
        serializer = QuickRecordSerializer(data=request.data)
        if serializer.is_valid():
            record = serializer.save(user=request.user)
            return Response({
                'id': record.id,
                'message': '记录成功',
                'record': EmotionRecordSerializer(record).data
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class EmotionTagViewSet(viewsets.ModelViewSet):
    """情绪标签ViewSet"""
    queryset = EmotionTag.objects.filter(is_active=True)
    serializer_class = EmotionTagSerializer
    permission_classes = [IsAuthenticated]
    
    @extend_schema(
        summary="获取情绪标签列表",
        description="获取可用的情绪标签列表",
        tags=["情绪标签"]
    )
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
    
    @action(detail=False, methods=['get'])
    def popular(self, request):
        """获取热门标签"""
        tags = EmotionTag.objects.filter(is_active=True).order_by('-usage_count')[:20]
        serializer = self.get_serializer(tags, many=True)
        return Response(serializer.data)


class EmotionPatternViewSet(viewsets.ModelViewSet):
    """情绪模式ViewSet"""
    queryset = EmotionPattern.objects.all()
    serializer_class = EmotionPatternSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return EmotionPattern.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class EmotionGoalViewSet(viewsets.ModelViewSet):
    """情绪目标ViewSet"""
    queryset = EmotionGoal.objects.all()
    serializer_class = EmotionGoalSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return EmotionGoal.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
    
    @action(detail=False, methods=['get'])
    def active(self, request):
        """获取活跃目标"""
        goals = self.get_queryset().filter(status='active')
        serializer = self.get_serializer(goals, many=True)
        return Response(serializer.data)


class QuickRecordView(generics.CreateAPIView):
    """快速记录情绪"""
    serializer_class = QuickRecordSerializer
    permission_classes = [IsAuthenticated]
    
    @extend_schema(
        summary="快速记录情绪",
        description="快速创建情绪记录",
        tags=["情绪记录"]
    )
    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            record = serializer.save(user=request.user)
            return Response({
                'id': record.id,
                'message': '记录成功',
                'record': EmotionRecordSerializer(record).data
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class RecentRecordsView(generics.ListAPIView):
    """最近记录"""
    serializer_class = EmotionRecordSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return EmotionRecord.objects.filter(
            user=self.request.user
        ).order_by('-created_at')[:10]
    
    @extend_schema(
        summary="获取最近记录",
        description="获取用户最近的10条情绪记录",
        tags=["情绪记录"]
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)


class EmotionStatisticsView(generics.GenericAPIView):
    """情绪统计"""
    permission_classes = [IsAuthenticated]
    
    @extend_schema(
        summary="获取情绪统计",
        description="获取用户的情绪统计数据",
        tags=["统计分析"],
        parameters=[
            OpenApiParameter(
                name='period',
                type=str,
                location=OpenApiParameter.QUERY,
                description='统计周期: week/month/quarter/year',
                default='week'
            )
        ]
    )
    def get(self, request, *args, **kwargs):
        period = request.query_params.get('period', 'week')
        user = request.user
        
        # 计算时间范围
        end_date = timezone.now().date()
        if period == 'week':
            start_date = end_date - timedelta(days=7)
        elif period == 'month':
            start_date = end_date - timedelta(days=30)
        elif period == 'quarter':
            start_date = end_date - timedelta(days=90)
        elif period == 'year':
            start_date = end_date - timedelta(days=365)
        else:
            start_date = end_date - timedelta(days=7)
        
        # 获取记录
        records = EmotionRecord.objects.filter(
            user=user,
            emotion_time__date__gte=start_date,
            emotion_time__date__lte=end_date
        )
        
        # 统计数据
        total_records = records.count()
        
        # 情绪分布
        emotion_distribution = records.values('emotion_type').annotate(
            count=Count('id')
        ).order_by('-count')
        
        # 场景分布
        scenario_distribution = records.values('scenario').annotate(
            count=Count('id')
        ).order_by('-count')
        
        # 平均强度
        avg_intensity = records.aggregate(avg=Avg('intensity'))['avg'] or 0
        
        # 情绪趋势（按日期分组）
        emotion_trends = []
        current_date = start_date
        while current_date <= end_date:
            day_records = records.filter(emotion_time__date=current_date)
            emotion_trends.append({
                'date': current_date.strftime('%Y-%m-%d'),
                'count': day_records.count(),
                'avg_intensity': day_records.aggregate(avg=Avg('intensity'))['avg'] or 0
            })
            current_date += timedelta(days=1)
        
        # 时间模式分析
        hour_distribution = records.extra(
            select={'hour': 'EXTRACT(hour FROM emotion_time)'}
        ).values('hour').annotate(count=Count('id')).order_by('hour')
        
        weekday_distribution = records.extra(
            select={'weekday': 'EXTRACT(dow FROM emotion_time)'}
        ).values('weekday').annotate(count=Count('id')).order_by('weekday')
        
        statistics = {
            'period': period,
            'date_range': {
                'start_date': start_date,
                'end_date': end_date
            },
            'overview': {
                'total_records': total_records,
                'avg_intensity': round(avg_intensity, 2),
                'most_common_emotion': emotion_distribution[0]['emotion_type'] if emotion_distribution else None,
                'most_common_scenario': scenario_distribution[0]['scenario'] if scenario_distribution else None
            },
            'emotion_distribution': list(emotion_distribution),
            'scenario_distribution': list(scenario_distribution),
            'emotion_trends': emotion_trends,
            'time_patterns': {
                'hour_distribution': list(hour_distribution),
                'weekday_distribution': list(weekday_distribution)
            }
        }
        
        return Response(statistics)


class EmotionTrendsView(generics.GenericAPIView):
    """情绪趋势分析"""
    permission_classes = [IsAuthenticated]
    
    @extend_schema(
        summary="获取情绪趋势",
        description="获取用户的情绪趋势分析",
        tags=["统计分析"]
    )
    def get(self, request, *args, **kwargs):
        user = request.user
        
        # 获取最近30天的数据
        end_date = timezone.now().date()
        start_date = end_date - timedelta(days=30)
        
        records = EmotionRecord.objects.filter(
            user=user,
            emotion_time__date__gte=start_date
        )
        
        # 按日期分组统计
        daily_stats = []
        current_date = start_date
        while current_date <= end_date:
            day_records = records.filter(emotion_time__date=current_date)
            
            if day_records.exists():
                # 计算当日情绪分布
                emotions = day_records.values('emotion_type').annotate(
                    count=Count('id')
                )
                
                daily_stats.append({
                    'date': current_date.strftime('%Y-%m-%d'),
                    'total_records': day_records.count(),
                    'avg_intensity': day_records.aggregate(avg=Avg('intensity'))['avg'] or 0,
                    'emotions': list(emotions),
                    'dominant_emotion': max(emotions, key=lambda x: x['count'])['emotion_type'] if emotions else None
                })
            else:
                daily_stats.append({
                    'date': current_date.strftime('%Y-%m-%d'),
                    'total_records': 0,
                    'avg_intensity': 0,
                    'emotions': [],
                    'dominant_emotion': None
                })
            
            current_date += timedelta(days=1)
        
        return Response({
            'period': '30_days',
            'daily_stats': daily_stats
        })


class ExportDataView(generics.GenericAPIView):
    """导出数据"""
    permission_classes = [IsAuthenticated]
    
    @extend_schema(
        summary="导出数据",
        description="导出用户的情绪记录数据",
        tags=["数据管理"]
    )
    def get(self, request, *args, **kwargs):
        user = request.user
        
        # 获取所有记录
        records = EmotionRecord.objects.filter(user=user).order_by('-emotion_time')
        
        # 序列化数据
        serializer = EmotionRecordSerializer(records, many=True)
        
        export_data = {
            'user_info': {
                'username': user.username,
                'nickname': user.nickname,
                'export_date': timezone.now().isoformat(),
                'total_records': records.count()
            },
            'records': serializer.data
        }
        
        return Response(export_data)


# 新的详细统计API视图
class StatisticsOverviewView(generics.GenericAPIView):
    """统计概览"""
    permission_classes = [IsAuthenticated]
    
    def get(self, request, *args, **kwargs):
        time_range = request.query_params.get('time_range', 'week')
        user = request.user
        
        # 计算时间范围
        end_date = timezone.now().date()
        if time_range == 'week':
            start_date = end_date - timedelta(days=7)
        elif time_range == 'month':
            start_date = end_date - timedelta(days=30)
        elif time_range == 'quarter':
            start_date = end_date - timedelta(days=90)
        elif time_range == 'year':
            start_date = end_date - timedelta(days=365)
        else:
            start_date = end_date - timedelta(days=7)
        
        # 获取记录
        records = EmotionRecord.objects.filter(
            user=user,
            emotion_time__date__gte=start_date,
            emotion_time__date__lte=end_date
        )
        
        # 计算连续记录天数
        streak_days = 0
        check_date = end_date
        while check_date >= start_date:
            if records.filter(emotion_time__date=check_date).exists():
                streak_days += 1
                check_date -= timedelta(days=1)
            else:
                break
        
        # 计算改善率（本周vs上周）
        prev_start = start_date - timedelta(days=(end_date - start_date).days)
        prev_records = EmotionRecord.objects.filter(
            user=user,
            emotion_time__date__gte=prev_start,
            emotion_time__date__lt=start_date
        )
        
        current_avg = records.aggregate(avg=Avg('intensity'))['avg'] or 0
        prev_avg = prev_records.aggregate(avg=Avg('intensity'))['avg'] or 0
        improvement_rate = ((current_avg - prev_avg) / prev_avg * 100) if prev_avg > 0 else 0
        
        return Response({
            'success': True,
            'data': {
                'total_records': records.count(),
                'average_mood': round(current_avg, 1),
                'streak_days': streak_days,
                'improvement_rate': round(improvement_rate, 1)
            }
        })


class StatisticsTrendView(generics.GenericAPIView):
    """统计趋势"""
    permission_classes = [IsAuthenticated]
    
    def get(self, request, *args, **kwargs):
        time_range = request.query_params.get('time_range', 'week')
        user = request.user
        
        # 计算时间范围
        end_date = timezone.now().date()
        if time_range == 'week':
            start_date = end_date - timedelta(days=6)  # 7天数据
            days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
        elif time_range == 'month':
            start_date = end_date - timedelta(days=29)  # 30天数据
            days = []
        else:
            start_date = end_date - timedelta(days=6)
            days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
        
        # 获取记录
        records = EmotionRecord.objects.filter(
            user=user,
            emotion_time__date__gte=start_date,
            emotion_time__date__lte=end_date
        )
        
        # 按日期分组统计
        trend_data = []
        current_date = start_date
        day_index = 0
        
        while current_date <= end_date:
            day_records = records.filter(emotion_time__date=current_date)
            avg_mood = day_records.aggregate(avg=Avg('intensity'))['avg'] or 0
            
            if time_range == 'week' and day_index < len(days):
                name = days[day_index]
            else:
                name = current_date.strftime('%m-%d')
            
            trend_data.append({
                'name': name,
                'date': current_date.strftime('%Y-%m-%d'),
                'mood': round(avg_mood, 1),
                'value': round(avg_mood, 1)
            })
            
            current_date += timedelta(days=1)
            day_index += 1
        
        return Response({
            'success': True,
            'data': trend_data
        })


class StatisticsDistributionView(generics.GenericAPIView):
    """情绪分布统计"""
    permission_classes = [IsAuthenticated]
    
    def get(self, request, *args, **kwargs):
        time_range = request.query_params.get('time_range', 'week')
        user = request.user
        
        # 计算时间范围
        end_date = timezone.now().date()
        if time_range == 'week':
            start_date = end_date - timedelta(days=7)
        elif time_range == 'month':
            start_date = end_date - timedelta(days=30)
        else:
            start_date = end_date - timedelta(days=7)
        
        # 获取记录
        records = EmotionRecord.objects.filter(
            user=user,
            emotion_time__date__gte=start_date,
            emotion_time__date__lte=end_date
        )
        
        # 情绪分布统计
        emotion_distribution = records.values('emotion_type').annotate(
            count=Count('id')
        ).order_by('-count')
        
        total_count = records.count()
        
        # 情绪颜色映射
        emotion_colors = {
            '快乐': '#FFD700',
            '平静': '#87CEEB',
            '焦虑': '#FFA500',
            '悲伤': '#6495ED',
            '愤怒': '#FF6B6B',
            '兴奋': '#32CD32',
            '疲惫': '#696969'
        }
        
        distribution_data = []
        for item in emotion_distribution:
            percentage = (item['count'] / total_count * 100) if total_count > 0 else 0
            distribution_data.append({
                'name': item['emotion_type'],
                'count': item['count'],
                'percentage': round(percentage, 1),
                'value': round(percentage, 1),
                'color': emotion_colors.get(item['emotion_type'], '#4A90E2')
            })
        
        return Response({
            'success': True,
            'data': distribution_data
        })


class StatisticsScenesView(generics.GenericAPIView):
    """场景统计"""
    permission_classes = [IsAuthenticated]
    
    def get(self, request, *args, **kwargs):
        time_range = request.query_params.get('time_range', 'week')
        user = request.user
        
        # 计算时间范围
        end_date = timezone.now().date()
        if time_range == 'week':
            start_date = end_date - timedelta(days=7)
        elif time_range == 'month':
            start_date = end_date - timedelta(days=30)
        else:
            start_date = end_date - timedelta(days=7)
        
        # 获取记录
        records = EmotionRecord.objects.filter(
            user=user,
            emotion_time__date__gte=start_date,
            emotion_time__date__lte=end_date
        )
        
        # 场景统计
        scene_stats = records.values('scenario').annotate(
            count=Count('id'),
            avg_mood=Avg('intensity')
        ).order_by('-count')
        
        # 场景颜色映射
        scene_colors = {
            '工作': '#4A90E2',
            '学习': '#50C878',
            '生活': '#FFB347',
            '社交': '#DDA0DD',
            '健康': '#F0E68C',
            '娱乐': '#FF69B4',
            '运动': '#32CD32'
        }
        
        scene_data = []
        for item in scene_stats:
            scene_data.append({
                'name': item['scenario'] or '未分类',
                'count': item['count'],
                'value': item['count'],
                'average_mood': round(item['avg_mood'] or 0, 1),
                'color': scene_colors.get(item['scenario'], '#4A90E2')
            })
        
        return Response({
            'success': True,
            'data': scene_data
        })


class StatisticsTimePatternView(generics.GenericAPIView):
    """时间模式统计"""
    permission_classes = [IsAuthenticated]
    
    def get(self, request, *args, **kwargs):
        time_range = request.query_params.get('time_range', 'week')
        user = request.user
        
        # 计算时间范围
        end_date = timezone.now().date()
        if time_range == 'week':
            start_date = end_date - timedelta(days=7)
        elif time_range == 'month':
            start_date = end_date - timedelta(days=30)
        else:
            start_date = end_date - timedelta(days=7)
        
        # 获取记录
        records = EmotionRecord.objects.filter(
            user=user,
            emotion_time__date__gte=start_date,
            emotion_time__date__lte=end_date
        )
        
        # 时段分布统计
        hour_pattern = []
        hour_ranges = [
            ('6-8', 6, 8), ('8-10', 8, 10), ('10-12', 10, 12),
            ('12-14', 12, 14), ('14-16', 14, 16), ('16-18', 16, 18),
            ('18-20', 18, 20), ('20-22', 20, 22), ('22-24', 22, 24)
        ]
        
        total_records = records.count()
        
        for hour_range, start_hour, end_hour in hour_ranges:
            hour_records = records.filter(
                emotion_time__hour__gte=start_hour,
                emotion_time__hour__lt=end_hour
            )
            count = hour_records.count()
            intensity = count / total_records if total_records > 0 else 0
            
            hour_pattern.append({
                'hour': hour_range,
                'intensity': round(intensity, 2),
                'count': count
            })
        
        return Response({
            'success': True,
            'data': {
                'hour_pattern': hour_pattern
            }
        }) 