from rest_framework import generics, viewsets, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from drf_spectacular.utils import extend_schema
from django.shortcuts import get_object_or_404
from emotions.models import EmotionRecord
from .models import AIAnalysisResult, EmotionInsight, AIRecommendation, ActionPlan
from .serializers import (
    AIAnalysisResultSerializer, EmotionInsightSerializer, 
    AIRecommendationSerializer, ActionPlanSerializer
)
from .ai_service import AIAnalysisService


class AIAnalysisResultViewSet(viewsets.ModelViewSet):
    queryset = AIAnalysisResult.objects.all()
    serializer_class = AIAnalysisResultSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return AIAnalysisResult.objects.filter(user=self.request.user)


class EmotionInsightViewSet(viewsets.ModelViewSet):
    queryset = EmotionInsight.objects.all()
    serializer_class = EmotionInsightSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return EmotionInsight.objects.filter(user=self.request.user)


class AIRecommendationViewSet(viewsets.ModelViewSet):
    queryset = AIRecommendation.objects.all()
    serializer_class = AIRecommendationSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return AIRecommendation.objects.filter(user=self.request.user)


class ActionPlanViewSet(viewsets.ModelViewSet):
    queryset = ActionPlan.objects.all()
    serializer_class = ActionPlanSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return ActionPlan.objects.filter(user=self.request.user)


class AnalyzeEmotionView(generics.GenericAPIView):
    permission_classes = [IsAuthenticated]
    
    @extend_schema(
        summary="分析情绪",
        description="对情绪记录进行AI分析",
        tags=["AI分析"]
    )
    def post(self, request, *args, **kwargs):
        try:
            # 获取请求参数
            emotion_records = request.data.get('emotion_records', [])
            analysis_type = request.data.get('analysis_type', 'comprehensive')
            
            # 验证参数
            if not emotion_records:
                # 如果没有指定记录，获取用户最近的记录
                recent_records = EmotionRecord.objects.filter(
                    user=request.user
                ).order_by('-created_at')[:5]
                
                if not recent_records:
                    return Response({
                        'error': '没有找到情绪记录数据',
                        'message': '请先创建一些情绪记录'
                    }, status=status.HTTP_400_BAD_REQUEST)
                
                records = list(recent_records)
            else:
                # 获取指定的记录
                records = []
                for record_id in emotion_records:
                    try:
                        record = EmotionRecord.objects.get(
                            id=record_id, 
                            user=request.user
                        )
                        records.append(record)
                    except EmotionRecord.DoesNotExist:
                        continue
                
                if not records:
                    return Response({
                        'error': '没有找到有效的情绪记录',
                        'message': '请检查记录ID是否正确'
                    }, status=status.HTTP_400_BAD_REQUEST)
            
            # 执行AI分析
            ai_service = AIAnalysisService()
            analysis_result = ai_service.analyze_emotion_records(records, analysis_type)
            
            # 保存分析结果（可选）
            try:
                ai_analysis = AIAnalysisResult.objects.create(
                    user=request.user,
                    emotion_record=records[0],
                    analysis_type=analysis_type,
                    analysis_result=analysis_result,
                    confidence_score=analysis_result.get('confidence', 0)
                )
                analysis_result['analysis_id'] = ai_analysis.id
            except Exception as e:
                # 如果保存失败，不影响返回结果
                print(f"保存分析结果失败: {e}")
            
            return Response(analysis_result, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response({
                'error': '分析过程中发生错误',
                'message': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class BatchAnalyzeView(generics.GenericAPIView):
    permission_classes = [IsAuthenticated]
    
    def post(self, request, *args, **kwargs):
        try:
            # 获取用户所有记录进行批量分析
            records = EmotionRecord.objects.filter(
                user=request.user
            ).order_by('-created_at')[:20]  # 最多分析最近20条记录
            
            if not records:
                return Response({
                    'error': '没有找到情绪记录数据',
                    'message': '请先创建一些情绪记录'
                }, status=status.HTTP_400_BAD_REQUEST)
            
            ai_service = AIAnalysisService()
            analysis_result = ai_service.analyze_emotion_records(
                list(records), 
                'batch'
            )
            
            return Response(analysis_result, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response({
                'error': '批量分析过程中发生错误',
                'message': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class GenerateInsightsView(generics.GenericAPIView):
    permission_classes = [IsAuthenticated]
    
    def post(self, request, *args, **kwargs):
        try:
            emotion_records = request.data.get('emotion_records', [])
            focus_areas = request.data.get('focus_areas', ['patterns', 'triggers', 'coping'])
            
            # 获取记录
            if emotion_records:
                records = []
                for record_id in emotion_records:
                    try:
                        record = EmotionRecord.objects.get(id=record_id, user=request.user)
                        records.append(record)
                    except EmotionRecord.DoesNotExist:
                        continue
            else:
                records = list(EmotionRecord.objects.filter(
                    user=request.user
                ).order_by('-created_at')[:10])
            
            if not records:
                return Response({
                    'error': '没有找到情绪记录数据'
                }, status=status.HTTP_400_BAD_REQUEST)
            
            ai_service = AIAnalysisService()
            analysis_result = ai_service.analyze_emotion_records(records, 'insights')
            
            # 只返回洞察部分
            insights_result = {
                'insights': analysis_result.get('insights', []),
                'confidence': analysis_result.get('confidence', 0),
                'timestamp': analysis_result.get('timestamp')
            }
            
            return Response(insights_result, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response({
                'error': '洞察生成过程中发生错误',
                'message': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class GetRecommendationsView(generics.GenericAPIView):
    permission_classes = [IsAuthenticated]
    
    def post(self, request, *args, **kwargs):
        try:
            emotion_records = request.data.get('emotion_records', [])
            suggestion_types = request.data.get('suggestion_types', ['immediate', 'longterm', 'lifestyle', 'social'])
            
            # 获取记录
            if emotion_records:
                records = []
                for record_id in emotion_records:
                    try:
                        record = EmotionRecord.objects.get(id=record_id, user=request.user)
                        records.append(record)
                    except EmotionRecord.DoesNotExist:
                        continue
            else:
                records = list(EmotionRecord.objects.filter(
                    user=request.user
                ).order_by('-created_at')[:5])
            
            if not records:
                return Response({
                    'error': '没有找到情绪记录数据'
                }, status=status.HTTP_400_BAD_REQUEST)
            
            ai_service = AIAnalysisService()
            analysis_result = ai_service.analyze_emotion_records(records, 'suggestions')
            
            # 只返回建议部分
            suggestions_result = {
                'suggestions': analysis_result.get('suggestions', {}),
                'confidence': analysis_result.get('confidence', 0),
                'timestamp': analysis_result.get('timestamp')
            }
            
            # 根据请求的类型过滤建议
            filtered_suggestions = {}
            for suggestion_type in suggestion_types:
                if suggestion_type in suggestions_result['suggestions']:
                    filtered_suggestions[suggestion_type] = suggestions_result['suggestions'][suggestion_type]
            
            suggestions_result['suggestions'] = filtered_suggestions
            
            return Response(suggestions_result, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response({
                'error': '建议生成过程中发生错误',
                'message': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class CreateActionPlanView(generics.GenericAPIView):
    permission_classes = [IsAuthenticated]
    
    def post(self, request, *args, **kwargs):
        return Response({'message': '行动计划创建功能正在开发中'})


class PlanProgressView(generics.GenericAPIView):
    permission_classes = [IsAuthenticated]
    
    def get(self, request, *args, **kwargs):
        return Response({'message': '计划进度查看功能正在开发中'})


class UsageStatsView(generics.GenericAPIView):
    permission_classes = [IsAuthenticated]
    
    def get(self, request, *args, **kwargs):
        return Response({'message': '使用统计功能正在开发中'}) 