from rest_framework import serializers
from .models import AIAnalysisResult, EmotionInsight, AIRecommendation, ActionPlan


class AIAnalysisResultSerializer(serializers.ModelSerializer):
    class Meta:
        model = AIAnalysisResult
        fields = '__all__'
        read_only_fields = ['user', 'created_at', 'started_at', 'completed_at']


class EmotionInsightSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmotionInsight
        fields = '__all__'
        read_only_fields = ['user', 'created_at', 'read_at']


class AIRecommendationSerializer(serializers.ModelSerializer):
    class Meta:
        model = AIRecommendation
        fields = '__all__'
        read_only_fields = ['user', 'created_at', 'applied_at']


class ActionPlanSerializer(serializers.ModelSerializer):
    class Meta:
        model = ActionPlan
        fields = '__all__'
        read_only_fields = ['user', 'created_at', 'updated_at', 'completed_at'] 