from rest_framework import serializers
from .models import EmotionRecord, EmotionTag, EmotionPattern, EmotionGoal


class EmotionRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmotionRecord
        fields = '__all__'
        read_only_fields = ['user', 'created_at', 'updated_at']


class EmotionTagSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmotionTag
        fields = '__all__'


class EmotionPatternSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmotionPattern
        fields = '__all__'
        read_only_fields = ['user', 'created_at', 'updated_at']


class EmotionGoalSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmotionGoal
        fields = '__all__'
        read_only_fields = ['user', 'created_at', 'updated_at']


class QuickRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmotionRecord
        fields = ['description', 'emotion_type', 'intensity', 'scenario']


class EmotionStatisticsSerializer(serializers.Serializer):
    period = serializers.CharField()
    total_records = serializers.IntegerField()
    avg_intensity = serializers.FloatField() 