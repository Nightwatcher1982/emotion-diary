#!/usr/bin/env python
"""
测试数据生成脚本
用于前后端联调时创建模拟数据
"""
import os
import sys
import django
from datetime import datetime, timedelta
from django.utils import timezone

# 设置Django环境
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'emotion_diary_api.settings')
django.setup()

from django.contrib.auth import get_user_model
from emotions.models import EmotionRecord, EmotionTag, RecordTag
from accounts.models import UserProfile

User = get_user_model()

def create_test_user():
    """创建测试用户"""
    # 创建测试用户
    if not User.objects.filter(username='testuser').exists():
        from datetime import date
        user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123',
            nickname='测试用户',
            birth_date=date(1999, 1, 1),  # 设置出生日期而不是年龄
            gender='O'  # 使用正确的性别选项
        )
        
        # 创建用户档案
        from datetime import time
        UserProfile.objects.create(
            user=user,
            occupation='student',
            sleep_time=time(23, 0),
            wake_time=time(7, 0),
            exercise_frequency=3,  # 运动频率改为数字
            work_stress_level=3,
            anxiety_tendency=2,
            depression_tendency=2,
            stress_coping_ability=4,
            favorite_emotions=['开心', '平静'],
            favorite_scenarios=['学习', '独处']
        )
        
        print(f"✅ 创建测试用户: {user.username}")
        return user
    else:
        user = User.objects.get(username='testuser')
        print(f"✅ 测试用户已存在: {user.username}")
        return user

def create_emotion_tags():
    """创建情绪标签"""
    tags_data = [
        # 情绪类型标签
        {'name': '开心', 'category': 'emotion', 'color': '#FFD700'},
        {'name': '难过', 'category': 'emotion', 'color': '#4169E1'},
        {'name': '愤怒', 'category': 'emotion', 'color': '#DC143C'},
        {'name': '焦虑', 'category': 'emotion', 'color': '#FF6347'},
        {'name': '平静', 'category': 'emotion', 'color': '#20B2AA'},
        {'name': '兴奋', 'category': 'emotion', 'color': '#FF69B4'},
        
        # 场景标签
        {'name': '工作', 'category': 'scene', 'color': '#696969'},
        {'name': '学习', 'category': 'scene', 'color': '#4682B4'},
        {'name': '家庭', 'category': 'scene', 'color': '#8B4513'},
        {'name': '朋友', 'category': 'scene', 'color': '#32CD32'},
        {'name': '独处', 'category': 'scene', 'color': '#9370DB'},
        {'name': '运动', 'category': 'scene', 'color': '#FF4500'},
        
        # 触发因素标签
        {'name': '压力', 'category': 'trigger', 'color': '#B22222'},
        {'name': '成就', 'category': 'trigger', 'color': '#FFD700'},
        {'name': '人际关系', 'category': 'trigger', 'color': '#FF1493'},
        {'name': '健康', 'category': 'trigger', 'color': '#00CED1'},
    ]
    
    created_tags = []
    for tag_data in tags_data:
        tag, created = EmotionTag.objects.get_or_create(
            name=tag_data['name'],
            defaults={
                'category': tag_data['category'],
                'color': tag_data['color'],
                'description': f"{tag_data['name']}相关的情绪标签"
            }
        )
        if created:
            print(f"✅ 创建标签: {tag.name}")
        created_tags.append(tag)
    
    return created_tags

def create_emotion_records(user, tags):
    """创建情绪记录"""
    # 获取不同类型的标签
    emotion_tags = [tag for tag in tags if tag.category == 'emotion']
    scene_tags = [tag for tag in tags if tag.category == 'scene']
    trigger_tags = [tag for tag in tags if tag.category == 'trigger']
    
    # 创建最近7天的情绪记录
    records_data = [
        {
            'date_offset': 0,  # 今天
            'emotion_type': 'happy',
            'intensity': 8,
            'scene': 'work',
            'content': '今天完成了一个重要的项目，感觉很有成就感！',
            'emotion_tag': '开心',
            'scene_tag': '工作',
            'trigger_tag': '成就'
        },
        {
            'date_offset': 1,  # 昨天
            'emotion_type': 'anxious',
            'intensity': 6,
            'scene': 'study',
            'content': '明天要考试了，有点紧张，但还是要保持冷静。',
            'emotion_tag': '焦虑',
            'scene_tag': '学习',
            'trigger_tag': '压力'
        },
        {
            'date_offset': 2,  # 前天
            'emotion_type': 'calm',
            'intensity': 7,
            'scene': 'personal',
            'content': '晚上散步，看到美丽的夕阳，心情很平静。',
            'emotion_tag': '平静',
            'scene_tag': '独处',
            'trigger_tag': '健康'
        },
        {
            'date_offset': 3,
            'emotion_type': 'sad',
            'intensity': 4,
            'scene': 'family',
            'content': '和家人有点小争执，感觉有些难过。',
            'emotion_tag': '难过',
            'scene_tag': '家庭',
            'trigger_tag': '人际关系'
        },
        {
            'date_offset': 4,
            'emotion_type': 'excited',
            'intensity': 9,
            'scene': 'social',
            'content': '和朋友们聚会，玩得很开心！',
            'emotion_tag': '兴奋',
            'scene_tag': '朋友',
            'trigger_tag': '人际关系'
        },
        {
            'date_offset': 5,
            'emotion_type': 'angry',
            'intensity': 5,
            'scene': 'work',
            'content': '工作中遇到了一些不公平的事情，有点生气。',
            'emotion_tag': '愤怒',
            'scene_tag': '工作',
            'trigger_tag': '压力'
        },
        {
            'date_offset': 6,
            'emotion_type': 'happy',
            'intensity': 7,
            'scene': 'health',
            'content': '今天跑步了5公里，感觉身体很棒！',
            'emotion_tag': '开心',
            'scene_tag': '运动',
            'trigger_tag': '健康'
        }
    ]
    
    created_records = []
    for record_data in records_data:
        # 计算记录时间
        record_time = timezone.now() - timedelta(days=record_data['date_offset'])
        
        # 创建情绪记录
        record = EmotionRecord.objects.create(
            user=user,
            emotion_type=record_data['emotion_type'],
            intensity=record_data['intensity'],
            scenario=record_data['scene'],  # 使用正确的字段名
            description=record_data['content'],  # 使用正确的字段名
            triggers=['情绪波动'],
            physical_symptoms=['无明显症状'],
            coping_methods=['深呼吸', '积极思考'],  # 使用正确的字段名
            emotion_time=record_time,  # 使用正确的字段名
        )
        
        # 添加标签关联
        emotion_tag = next((tag for tag in emotion_tags if tag.name == record_data['emotion_tag']), None)
        scene_tag = next((tag for tag in scene_tags if tag.name == record_data['scene_tag']), None)
        trigger_tag = next((tag for tag in trigger_tags if tag.name == record_data['trigger_tag']), None)
        
        for tag in [emotion_tag, scene_tag, trigger_tag]:
            if tag:
                RecordTag.objects.create(record=record, tag=tag)
        
        created_records.append(record)
        print(f"✅ 创建情绪记录: {record.emotion_type} - {record.description[:20]}...")
    
    return created_records

def main():
    """主函数"""
    print("🚀 开始创建测试数据...")
    
    # 创建测试用户
    user = create_test_user()
    
    # 创建情绪标签
    tags = create_emotion_tags()
    
    # 创建情绪记录
    records = create_emotion_records(user, tags)
    
    print(f"\n✅ 测试数据创建完成!")
    print(f"   - 用户: 1个")
    print(f"   - 标签: {len(tags)}个")
    print(f"   - 情绪记录: {len(records)}个")
    print(f"\n🔐 测试用户登录信息:")
    print(f"   用户名: testuser")
    print(f"   密码: testpass123")
    print(f"   邮箱: test@example.com")

if __name__ == '__main__':
    main() 