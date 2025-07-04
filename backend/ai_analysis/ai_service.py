import json
import random
import logging
import requests
from typing import Dict, List, Any
from datetime import datetime, timedelta
from emotions.models import EmotionRecord
from django.conf import settings

logger = logging.getLogger(__name__)


class AIAnalysisService:
    """AI情绪分析服务 - 测试模式版本（使用模拟结果，不调用真实API）"""
    
    def __init__(self):
        self.emotion_mappings = {
            'happy': {'name': '快乐', 'keywords': ['开心', '高兴', '愉快', '兴奋', '满足']},
            'sad': {'name': '悲伤', 'keywords': ['难过', '伤心', '沮丧', '失落', '痛苦']},
            'angry': {'name': '愤怒', 'keywords': ['生气', '愤怒', '恼火', '烦躁', '不满']},
            'anxious': {'name': '焦虑', 'keywords': ['紧张', '担心', '焦虑', '不安', '恐惧']},
            'calm': {'name': '平静', 'keywords': ['平静', '放松', '安详', '宁静', '舒适']},
            'fearful': {'name': '恐惧', 'keywords': ['害怕', '恐惧', '担忧', '惊慌', '不安']}
        }
        
        # 强制使用测试模式
        self.api_key = None
        self.auth_method = "TEST_MODE"
        
        logger.info("AI分析服务初始化成功 (测试模式 - 不调用真实API)")
    
    def get_auth_status(self):
        """获取认证状态信息 - 测试模式"""
        return {
            'status': 'test_mode',
            'message': '测试模式已启用 - 使用模拟AI分析结果',
            'auth_method': 'TEST_MODE',
            'ai_enabled': True  # 标记为启用，但使用模拟结果
        }
    
    def _call_qianfan_api(self, prompt: str, max_tokens: int = 1000) -> str:
        """模拟API调用（测试模式）"""
        logger.info("使用模拟AI分析 - 测试模式")
        return self._generate_enhanced_mock_response(prompt)
    
    def _generate_enhanced_mock_response(self, prompt: str) -> str:
        """生成增强的模拟回复（测试模式专用）"""
        # 根据提示词内容生成相应的模拟回复
        if "快乐" in prompt or "开心" in prompt:
            return json.dumps({
                "emotion_analysis": "您当前处于积极的情绪状态，快乐情绪有助于提升创造力和社交能力。这种正面情绪可能源于近期的成就感或良好的人际互动。",
                "psychological_state": "心理状态良好，情绪稳定，具有较强的抗压能力和适应性。",
                "coping_strategies": ["保持当前的积极状态", "分享快乐给身边的人", "记录美好时刻", "适度庆祝成就"],
                "prevention_advice": "继续保持积极的生活态度，建立支持性的社交网络，培养多样化的兴趣爱好。",
                "confidence_score": 92,
                "key_insights": ["积极情绪具有传染性", "快乐状态有助于问题解决能力"]
            }, ensure_ascii=False)
        
        elif "悲伤" in prompt or "难过" in prompt:
            return json.dumps({
                "emotion_analysis": "您正在经历悲伤情绪，这是对失落或挫折的正常反应。悲伤虽然不舒服，但它有助于处理情感创伤和适应变化。",
                "psychological_state": "当前情绪较为低落，需要时间和支持来处理内心的情感。建议寻求适当的社会支持。",
                "coping_strategies": ["允许自己感受悲伤", "寻求朋友或家人的陪伴", "进行轻度运动如散步", "写日记表达情感"],
                "prevention_advice": "建立情感支持网络，学习健康的情绪表达方式，保持规律的作息时间。",
                "confidence_score": 88,
                "key_insights": ["悲伤是情感愈合的必要过程", "适当的社会支持能够加速恢复"]
            }, ensure_ascii=False)
        
        elif "愤怒" in prompt or "生气" in prompt:
            return json.dumps({
                "emotion_analysis": "愤怒情绪通常源于感知到的不公或挫折。这种情绪提醒我们某些界限被越过，需要采取行动保护自己的利益。",
                "psychological_state": "情绪激活水平较高，可能影响理性思考。建议先冷静下来再做决定。",
                "coping_strategies": ["深呼吸10次", "暂时离开冲突现场", "进行体育锻炼释放能量", "与信任的人倾诉"],
                "prevention_advice": "学习愤怒管理技巧，识别愤怒的早期信号，培养耐心和宽容的品质。",
                "confidence_score": 85,
                "key_insights": ["愤怒往往掩盖着更深层的情感", "适当的愤怒表达是健康的"]
            }, ensure_ascii=False)
        
        elif "焦虑" in prompt or "紧张" in prompt:
            return json.dumps({
                "emotion_analysis": "焦虑反映了对未来不确定性的担忧。适度的焦虑有助于提高警觉性，但过度焦虑可能影响日常功能。",
                "psychological_state": "存在一定程度的心理紧张，可能影响睡眠和注意力。建议学习放松技巧。",
                "coping_strategies": ["练习正念冥想", "制定具体的行动计划", "进行渐进性肌肉放松", "限制咖啡因摄入"],
                "prevention_advice": "建立规律的作息，学习压力管理技巧，保持适度运动，培养乐观思维。",
                "confidence_score": 90,
                "key_insights": ["焦虑往往源于对控制感的缺失", "具体的行动计划能够减少不确定性"]
            }, ensure_ascii=False)
        
        elif "平静" in prompt or "放松" in prompt:
            return json.dumps({
                "emotion_analysis": "平静状态表明您具有良好的情绪调节能力。这种状态有利于清晰思考和做出理性决策。",
                "psychological_state": "心理状态平衡，具有较好的自我调节能力和内在稳定性。",
                "coping_strategies": ["保持当前的平静状态", "进行冥想或瑜伽", "享受宁静的时光", "培养感恩的心态"],
                "prevention_advice": "继续保持良好的生活习惯，定期进行自我反思，维护内心的平衡状态。",
                "confidence_score": 94,
                "key_insights": ["平静是内在智慧的体现", "稳定的情绪状态有助于整体健康"]
            }, ensure_ascii=False)
        
        else:
            # 通用模拟回复
            return json.dumps({
                "emotion_analysis": "根据您的情绪记录，我分析出您当前的情绪状态具有一定的复杂性。每种情绪都有其存在的意义和价值。",
                "psychological_state": "整体心理状态处于正常范围内，建议继续关注自己的情绪变化。",
                "coping_strategies": ["保持自我觉察", "定期进行情绪记录", "寻求适当的支持", "培养健康的生活习惯"],
                "prevention_advice": "建立稳定的日常routine，保持社交联系，定期进行自我关怀活动。",
                "confidence_score": 82,
                "key_insights": ["情绪是内心世界的重要信息", "自我觉察是情绪健康的基础"]
            }, ensure_ascii=False)
    
    def analyze_emotion_records(self, records: List[EmotionRecord], analysis_type: str = 'comprehensive') -> Dict[str, Any]:
        """分析情绪记录"""
        if not records:
            return self._generate_empty_analysis()
        
        primary_record = records[0]
        
        # 使用AI增强分析
        ai_enhanced_analysis = self._get_ai_enhanced_analysis(primary_record)
        
        analysis_result = {
            'record_id': primary_record.id,
            'timestamp': datetime.now().isoformat(),
            'analysis_type': analysis_type,
            'primary_emotion': self._analyze_primary_emotion(primary_record, ai_enhanced_analysis),
            'emotion_spectrum': self._generate_emotion_spectrum(primary_record, ai_enhanced_analysis),
            'confidence': self._calculate_confidence(primary_record, ai_enhanced_analysis),
            'insights': self._generate_insights(records, ai_enhanced_analysis),
            'suggestions': self._generate_suggestions(records, ai_enhanced_analysis),
            'trend': self._analyze_trend(records),
            'deep_analysis': self._perform_deep_analysis(records, ai_enhanced_analysis),
            'action_plan': self._create_action_plan(records, ai_enhanced_analysis),
            'ai_powered': True,  # 测试模式：标记为AI驱动但使用模拟结果
            'test_mode': True   # 明确标记为测试模式
        }
        
        return analysis_result
    
    def _get_ai_enhanced_analysis(self, record: EmotionRecord) -> Dict[str, Any]:
        """使用AI进行增强分析（测试模式使用模拟结果）"""
        # 构建分析提示词
        prompt = self._build_analysis_prompt(record)
        
        try:
            # 调用AI分析（测试模式会返回模拟结果）
            ai_response = self._call_qianfan_api(prompt, max_tokens=800)
            
            # 解析AI回复
            parsed_analysis = self._parse_ai_response(ai_response)
            
            logger.info(f"AI增强分析完成（测试模式），记录ID: {record.id}")
            return parsed_analysis
            
        except Exception as e:
            logger.error(f"AI增强分析失败: {e}")
            return {}
    
    def _build_analysis_prompt(self, record: EmotionRecord) -> str:
        """构建AI分析提示词"""
        emotion_name = self.emotion_mappings.get(record.emotion_type, {}).get('name', '未知')
        
        prompt = f"""
作为专业的心理健康AI助手，请分析以下情绪记录：

**情绪记录信息：**
- 情绪类型：{emotion_name}
- 强度等级：{record.intensity}/10
- 详细描述：{record.description or '无具体描述'}
- 记录时间：{record.created_at.strftime('%Y-%m-%d %H:%M')}
- 场景：{record.scenario or '未指定'}

**请从以下维度进行专业分析：**

1. **情绪深度分析**：分析这种情绪的根本原因和潜在影响
2. **心理状态评估**：评估用户当前的心理健康状态
3. **应对策略建议**：提供3-4个具体可行的应对方法
4. **预防性建议**：给出预防类似情绪问题的长期建议

请以JSON格式回复，包含以下字段：
{{
    "emotion_analysis": "情绪深度分析内容",
    "psychological_state": "心理状态评估",
    "coping_strategies": ["策略1", "策略2", "策略3"],
    "prevention_advice": "预防性建议",
    "confidence_score": 85,
    "key_insights": ["洞察1", "洞察2"]
}}
"""
        return prompt
    
    def _parse_ai_response(self, ai_response: str) -> Dict[str, Any]:
        """解析AI回复"""
        try:
            # 尝试提取JSON内容
            start_idx = ai_response.find('{')
            end_idx = ai_response.rfind('}') + 1
            
            if start_idx != -1 and end_idx != -1:
                json_str = ai_response[start_idx:end_idx]
                parsed = json.loads(json_str)
                return parsed
            else:
                # 如果没有JSON格式，解析文本内容
                return self._parse_text_response(ai_response)
                
        except json.JSONDecodeError:
            return self._parse_text_response(ai_response)
        except Exception as e:
            logger.error(f"AI回复解析失败: {e}")
            return {}
    
    def _parse_text_response(self, text_response: str) -> Dict[str, Any]:
        """解析文本格式的AI回复"""
        return {
            "emotion_analysis": text_response[:200] + "..." if len(text_response) > 200 else text_response,
            "psychological_state": "基于AI分析的心理状态评估",
            "coping_strategies": ["深呼吸练习", "适当休息", "寻求支持"],
            "prevention_advice": "保持规律作息，建立健康的生活习惯",
            "confidence_score": 75,
            "key_insights": ["AI分析提供的关键洞察"]
        }
    
    def _analyze_primary_emotion(self, record: EmotionRecord, ai_analysis: Dict[str, Any] = None) -> Dict[str, Any]:
        """分析主要情绪"""
        emotion_info = self.emotion_mappings.get(record.emotion_type, {})
        
        # 基础分析
        base_confidence = min(85 + record.intensity * 2, 98)
        description = f"检测到主要情绪为{emotion_info.get('name', '未知')}，强度为{record.intensity}/10"
        
        # AI增强分析
        if ai_analysis and 'confidence_score' in ai_analysis:
            ai_confidence = ai_analysis.get('confidence_score', base_confidence)
            # 结合AI置信度和基础置信度
            final_confidence = (base_confidence + ai_confidence) / 2
            
            if ai_analysis.get('emotion_analysis'):
                description += f"。AI分析：{ai_analysis['emotion_analysis'][:100]}..."
        else:
            final_confidence = base_confidence
        
        return {
            'type': record.emotion_type,
            'name': emotion_info.get('name', '未知'),
            'intensity': record.intensity,
            'confidence': min(final_confidence, 98),
            'description': description,
            'ai_enhanced': bool(ai_analysis)
        }
    
    def _generate_emotion_spectrum(self, record: EmotionRecord, ai_analysis: Dict[str, Any] = None) -> List[Dict[str, Any]]:
        """生成情绪光谱"""
        spectrum = []
        main_emotion = self.emotion_mappings.get(record.emotion_type, {})
        main_percentage = min(30 + record.intensity * 7, 90)
        
        spectrum.append({
            'emotion': record.emotion_type,
            'name': main_emotion.get('name', '未知'),
            'confidence': main_percentage / 100,
            'percentage': main_percentage
        })
        
        # 添加相关情绪
        related_emotions = self._get_related_emotions(record.emotion_type)
        remaining_percentage = 100 - main_percentage
        
        for i, related in enumerate(related_emotions[:2]):
            percentage = remaining_percentage * (0.6 if i == 0 else 0.4)
            spectrum.append({
                'emotion': related,
                'name': self.emotion_mappings.get(related, {}).get('name', '未知'),
                'confidence': percentage / 100,
                'percentage': round(percentage)
            })
        
        return spectrum
    
    def _get_related_emotions(self, emotion_type: str) -> List[str]:
        """获取相关情绪"""
        relations = {
            'happy': ['calm', 'excited'],
            'sad': ['anxious', 'lonely'],
            'angry': ['frustrated', 'annoyed'],
            'anxious': ['worried', 'nervous'],
            'calm': ['peaceful', 'relaxed'],
            'fearful': ['anxious', 'worried']
        }
        return relations.get(emotion_type, ['neutral', 'mixed'])
    
    def _calculate_confidence(self, record: EmotionRecord, ai_analysis: Dict[str, Any] = None) -> float:
        """计算分析置信度"""
        base_confidence = 75
        
        # 根据描述长度调整置信度
        if record.description:
            desc_length = len(record.description)
            if desc_length > 50:
                base_confidence += 10
            elif desc_length > 20:
                base_confidence += 5
        
        # 根据强度调整置信度
        if record.intensity >= 7:
            base_confidence += 8
        elif record.intensity >= 5:
            base_confidence += 5
        
        # 根据触发因素和症状调整
        if hasattr(record, 'triggers') and record.triggers:
            base_confidence += 3
        if hasattr(record, 'physical_symptoms') and record.physical_symptoms:
            base_confidence += 3
        
        return min(base_confidence, 95)
    
    def _generate_insights(self, records: List[EmotionRecord], ai_analysis: Dict[str, Any] = None) -> List[Dict[str, Any]]:
        """生成AI洞察"""
        insights = []
        primary_record = records[0]
        
        # AI增强洞察（优先使用）
        if ai_analysis and 'key_insights' in ai_analysis:
            for i, insight in enumerate(ai_analysis['key_insights'][:2]):  # 最多使用2个AI洞察
                insights.append({
                    'type': 'ai_insight',
                    'title': f'AI深度洞察 {i+1}',
                    'content': insight,
                    'confidence': ai_analysis.get('confidence_score', 85) / 100,
                    'actionable': True,
                    'source': 'ERNIE-Bot'
                })
        
        # 情绪模式识别
        pattern_insight = self._analyze_emotion_pattern(records)
        insights.append(pattern_insight)
        
        # 触发因素分析
        trigger_insight = self._analyze_triggers(primary_record, ai_analysis)
        insights.append(trigger_insight)
        
        # 应对策略评估
        coping_insight = self._analyze_coping_methods(primary_record, ai_analysis)
        insights.append(coping_insight)
        
        # 情绪强度分析
        intensity_insight = self._analyze_intensity(primary_record)
        insights.append(intensity_insight)
        
        return insights
    
    def _analyze_emotion_pattern(self, records: List[EmotionRecord]) -> Dict[str, Any]:
        """分析情绪模式"""
        if len(records) == 1:
            return {
                'type': 'pattern',
                'title': '情绪模式识别',
                'content': '这是您的第一次分析，随着记录的增加，我们将能够识别您的情绪模式和规律。',
                'confidence': 0.6,
                'actionable': False
            }
        
        # 分析多条记录的模式
        emotion_counts = {}
        for record in records:
            emotion_counts[record.emotion_type] = emotion_counts.get(record.emotion_type, 0) + 1
        
        most_common = max(emotion_counts, key=emotion_counts.get)
        emotion_name = self.emotion_mappings.get(most_common, {}).get('name', '未知')
        
        return {
            'type': 'pattern',
            'title': '情绪模式识别',
            'content': f'分析显示，您最常出现的情绪是{emotion_name}，这可能反映了您当前的生活状态和心理状态。建议关注引起这种情绪的具体情况。',
            'confidence': 0.8,
            'actionable': True
        }
    
    def _analyze_triggers(self, record: EmotionRecord, ai_analysis: Dict[str, Any] = None) -> Dict[str, Any]:
        """分析触发因素"""
        triggers = getattr(record, 'triggers', []) or []
        
        if not triggers:
            return {
                'type': 'trigger',
                'title': '触发因素分析',
                'content': '建议在今后的记录中更详细地描述引起情绪变化的具体事件或情况，这将帮助我们提供更精准的分析。',
                'confidence': 0.5,
                'actionable': True
            }
        
        main_trigger = triggers[0] if triggers else '未知因素'
        scenario_advice = {
            'work': '工作压力是常见的情绪触发因素，建议学习时间管理和压力缓解技巧。',
            'personal': '个人生活中的变化需要时间适应，保持耐心和自我关怀很重要。',
            'social': '人际关系的挑战是成长的机会，考虑提升沟通技巧。',
            'health': '身体健康直接影响情绪状态，建议关注身心健康的平衡。',
            'study': '学习压力需要合理管理，制定可行的学习计划很重要。',
            'other': '生活中的各种因素都可能影响情绪，保持觉察和适应能力。'
        }
        
        advice = scenario_advice.get(record.scenario, '识别触发因素是情绪管理的第一步。')
        
        return {
            'type': 'trigger',
            'title': '触发因素分析',
            'content': f'主要触发因素：{main_trigger}。{advice}',
            'confidence': 0.75,
            'actionable': True
        }
    
    def _analyze_coping_methods(self, record: EmotionRecord, ai_analysis: Dict[str, Any] = None) -> Dict[str, Any]:
        """分析应对方法"""
        coping_methods = getattr(record, 'coping_methods', []) or []
        
        if not coping_methods:
            return {
                'type': 'coping',
                'title': '应对策略评估',
                'content': '建议尝试一些情绪调节技巧，如深呼吸、运动、与人交流等，找到适合自己的应对方式。',
                'confidence': 0.6,
                'actionable': True
            }
        
        positive_methods = ['深呼吸', '运动', '冥想', '听音乐', '与人交流', '写日记']
        used_positive = [method for method in coping_methods if any(pm in method for pm in positive_methods)]
        
        if used_positive:
            return {
                'type': 'coping',
                'title': '应对策略评估',
                'content': f'很好！您使用了积极的应对方式：{", ".join(used_positive[:2])}。继续保持这些健康的应对策略。',
                'confidence': 0.85,
                'actionable': False
            }
        else:
            return {
                'type': 'coping',
                'title': '应对策略评估',
                'content': '建议尝试更多积极的应对策略，如深呼吸练习、适度运动、与信任的人交流等。',
                'confidence': 0.7,
                'actionable': True
            }
    
    def _analyze_intensity(self, record: EmotionRecord) -> Dict[str, Any]:
        """分析情绪强度"""
        intensity = record.intensity
        
        if intensity >= 8:
            content = '情绪强度较高，建议及时采取缓解措施，如深呼吸、暂停当前活动、寻求支持等。'
            confidence = 0.9
        elif intensity >= 6:
            content = '情绪强度中等偏高，这是正常的情绪反应，可以尝试一些放松技巧来调节。'
            confidence = 0.8
        elif intensity >= 4:
            content = '情绪强度适中，说明您有良好的情绪调节能力，可以继续保持当前的应对方式。'
            confidence = 0.7
        else:
            content = '情绪强度较低，说明您处理情绪的能力较好，或者当前情况对您影响不大。'
            confidence = 0.75
        
        return {
            'type': 'intensity',
            'title': '情绪强度分析',
            'content': content,
            'confidence': confidence,
            'actionable': intensity >= 6
        }
    
    def _generate_suggestions(self, records: List[EmotionRecord], ai_analysis: Dict[str, Any] = None) -> Dict[str, List[Dict[str, Any]]]:
        """生成个性化建议"""
        primary_record = records[0]
        emotion_type = primary_record.emotion_type
        intensity = primary_record.intensity
        
        # 基础建议
        suggestions = {
            'immediate': self._get_immediate_suggestions(emotion_type, intensity),
            'longterm': self._get_longterm_suggestions(emotion_type),
            'lifestyle': self._get_lifestyle_suggestions(emotion_type),
            'social': self._get_social_suggestions(emotion_type)
        }
        
        # AI增强建议
        if ai_analysis and 'coping_strategies' in ai_analysis:
            ai_suggestions = []
            for i, strategy in enumerate(ai_analysis['coping_strategies'][:3]):
                ai_suggestions.append({
                    'id': f'ai_{i}',
                    'title': f'AI建议 {i+1}',
                    'description': strategy,
                    'difficulty': 'ai_recommended',
                    'source': 'ERNIE-Bot'
                })
            
            # 将AI建议插入到即时建议的前面
            suggestions['immediate'] = ai_suggestions + suggestions['immediate'][:2]
        
        return suggestions
    
    def _get_immediate_suggestions(self, emotion_type: str, intensity: int) -> List[Dict[str, Any]]:
        """获取即时缓解建议"""
        base_suggestions = {
            'anxious': [
                {'id': 1, 'title': '4-7-8呼吸法', 'description': '吸气4秒，屏气7秒，呼气8秒，重复3-4次。', 'difficulty': 'easy'},
                {'id': 2, 'title': '5-4-3-2-1接地技巧', 'description': '说出5个看到的、4个听到的、3个摸到的、2个闻到的、1个尝到的。', 'difficulty': 'easy'}
            ],
            'angry': [
                {'id': 3, 'title': '数到十', 'description': '在心中慢慢数到十，给情绪一个缓冲的时间。', 'difficulty': 'easy'},
                {'id': 4, 'title': '离开现场', 'description': '暂时离开引起愤怒的环境，到安静的地方冷静。', 'difficulty': 'easy'}
            ],
            'sad': [
                {'id': 5, 'title': '允许自己哭泣', 'description': '哭泣是释放情绪的自然方式，不要压抑。', 'difficulty': 'easy'},
                {'id': 6, 'title': '听舒缓音乐', 'description': '选择一些能够安抚心情的音乐。', 'difficulty': 'easy'}
            ],
            'happy': [
                {'id': 7, 'title': '分享快乐', 'description': '与身边的人分享这份快乐，让好心情传递。', 'difficulty': 'easy'},
                {'id': 8, 'title': '记录美好时刻', 'description': '写下或拍下这个美好的时刻。', 'difficulty': 'easy'}
            ]
        }
        
        default_suggestions = [
            {'id': 9, 'title': '深呼吸练习', 'description': '进行5-10次深呼吸，专注于呼吸的节奏。', 'difficulty': 'easy'},
            {'id': 10, 'title': '短暂休息', 'description': '给自己几分钟的时间，暂停当前的活动。', 'difficulty': 'easy'}
        ]
        
        suggestions = base_suggestions.get(emotion_type, default_suggestions)
        
        # 根据强度调整建议
        if intensity >= 8:
            suggestions.insert(0, {
                'id': 0, 'title': '寻求即时支持', 
                'description': '情绪强度较高，建议立即联系信任的朋友或专业人士。', 
                'difficulty': 'medium'
            })
        
        return suggestions[:3]  # 返回最多3个建议
    
    def _get_longterm_suggestions(self, emotion_type: str) -> List[Dict[str, Any]]:
        """获取长期改善建议"""
        suggestions = [
            {'id': 11, 'title': '情绪日记', 'description': '坚持记录情绪变化，提高情绪觉察能力。', 'difficulty': 'medium'},
            {'id': 12, 'title': '正念练习', 'description': '每天10-15分钟的正念冥想，提高情绪调节能力。', 'difficulty': 'medium'},
            {'id': 13, 'title': '认知重构', 'description': '学习识别和改变消极的思维模式。', 'difficulty': 'hard'}
        ]
        
        if emotion_type == 'anxious':
            suggestions.append({
                'id': 14, 'title': '焦虑管理训练', 
                'description': '学习专门的焦虑管理技巧和放松训练。', 
                'difficulty': 'medium'
            })
        elif emotion_type == 'angry':
            suggestions.append({
                'id': 15, 'title': '愤怒管理课程', 
                'description': '参加愤怒管理培训，学习健康的表达方式。', 
                'difficulty': 'medium'
            })
        
        return suggestions[:3]
    
    def _get_lifestyle_suggestions(self, emotion_type: str) -> List[Dict[str, Any]]:
        """获取生活方式建议"""
        return [
            {'id': 16, 'title': '规律运动', 'description': '每周3-4次有氧运动，每次30分钟。', 'difficulty': 'medium'},
            {'id': 17, 'title': '睡眠优化', 'description': '保持规律的睡眠时间，创造良好的睡眠环境。', 'difficulty': 'medium'},
            {'id': 18, 'title': '健康饮食', 'description': '均衡饮食，减少咖啡因和糖分摄入。', 'difficulty': 'easy'}
        ]
    
    def _get_social_suggestions(self, emotion_type: str) -> List[Dict[str, Any]]:
        """获取社交支持建议"""
        return [
            {'id': 19, 'title': '寻求支持', 'description': '与信任的朋友或家人分享你的感受。', 'difficulty': 'medium'},
            {'id': 20, 'title': '加入支持小组', 'description': '寻找有相似经历的人群，获得理解和支持。', 'difficulty': 'medium'},
            {'id': 21, 'title': '专业咨询', 'description': '如果情绪持续困扰，考虑寻求专业心理咨询。', 'difficulty': 'hard'}
        ]
    
    def _analyze_trend(self, records: List[EmotionRecord]) -> Dict[str, Any]:
        """分析情绪趋势"""
        if len(records) < 2:
            return {
                'average': 5.0,
                'volatility': '无法评估',
                'direction': '需要更多数据',
                'period': '需要更多记录'
            }
        
        intensities = [record.intensity for record in records]
        average = sum(intensities) / len(intensities)
        
        # 计算波动性
        variance = sum((x - average) ** 2 for x in intensities) / len(intensities)
        if variance < 1:
            volatility = '低'
        elif variance < 4:
            volatility = '中等'
        else:
            volatility = '高'
        
        # 计算趋势方向
        if len(records) >= 3:
            recent_avg = sum(intensities[-3:]) / 3
            earlier_avg = sum(intensities[:-3]) / (len(intensities) - 3) if len(intensities) > 3 else intensities[0]
            
            if recent_avg > earlier_avg + 0.5:
                direction = '上升'
            elif recent_avg < earlier_avg - 0.5:
                direction = '下降'
            else:
                direction = '稳定'
        else:
            direction = '稳定'
        
        return {
            'average': round(average, 1),
            'volatility': volatility,
            'direction': direction,
            'period': f'基于{len(records)}条记录'
        }
    
    def _perform_deep_analysis(self, records: List[EmotionRecord], ai_analysis: Dict[str, Any] = None) -> Dict[str, Any]:
        """执行深度分析"""
        primary_record = records[0]
        
        # 计算各维度得分
        dimensions = [
            {
                'name': '情绪觉察',
                'score': min(7 + len(primary_record.description or '') // 20, 10),
                'description': '能够识别和描述自己的情绪状态'
            },
            {
                'name': '应对策略',
                'score': 5 + len(getattr(primary_record, 'coping_methods', []) or []),
                'description': '具备情绪调节和应对的技巧'
            },
            {
                'name': '社会支持',
                'score': 6 + (1 if primary_record.scenario == 'social' else 0),
                'description': '拥有良好的社会支持网络'
            },
            {
                'name': '生活平衡',
                'score': max(2, 10 - primary_record.intensity),
                'description': '工作与生活的平衡状态'
            }
        ]
        
        # 计算总分
        total_score = sum(d['score'] for d in dimensions) * 2.5  # 转换为100分制
        
        return {
            'score': min(int(total_score), 100),
            'dimensions': dimensions
        }
    
    def _create_action_plan(self, records: List[EmotionRecord], ai_analysis: Dict[str, Any] = None) -> List[Dict[str, Any]]:
        """创建行动计划"""
        primary_record = records[0]
        emotion_type = primary_record.emotion_type
        
        base_plans = {
            'anxious': [
                {'title': '练习深呼吸', 'description': '每天早晨练习5分钟深呼吸', 'completed': False},
                {'title': '记录焦虑触发因素', 'description': '观察并记录引起焦虑的具体情况', 'completed': False},
                {'title': '尝试正念练习', 'description': '下载冥想App，尝试10分钟正念练习', 'completed': False}
            ],
            'angry': [
                {'title': '识别愤怒信号', 'description': '学会识别愤怒产生前的身体信号', 'completed': False},
                {'title': '练习暂停技巧', 'description': '感到愤怒时先暂停10秒再反应', 'completed': False},
                {'title': '寻找健康发泄方式', 'description': '找到适合的运动或活动来释放情绪', 'completed': False}
            ],
            'sad': [
                {'title': '允许情绪存在', 'description': '接受悲伤情绪，不要强迫自己快乐', 'completed': False},
                {'title': '维持日常活动', 'description': '即使心情不好也要保持基本的日常活动', 'completed': False},
                {'title': '寻求社会支持', 'description': '主动与一位朋友分享你的感受', 'completed': False}
            ]
        }
        
        default_plan = [
            {'title': '记录情绪', 'description': '每天记录一次情绪状态', 'completed': False},
            {'title': '练习放松', 'description': '尝试深呼吸或其他放松技巧', 'completed': False},
            {'title': '评估进展', 'description': '一周后回顾情绪变化', 'completed': False}
        ]
        
        plan = base_plans.get(emotion_type, default_plan)
        
        # 添加通用的后续步骤
        plan.extend([
            {'title': '制定应对策略', 'description': '为类似情况制定具体的应对方案', 'completed': False},
            {'title': '建立支持网络', 'description': '确定可以寻求帮助的人或资源', 'completed': False},
            {'title': '定期自我评估', 'description': '每周评估情绪管理的效果', 'completed': False},
            {'title': '调整改善方案', 'description': '根据实践效果调整策略', 'completed': False}
        ])
        
        return plan[:7]  # 返回7天计划
    
    def _generate_empty_analysis(self) -> Dict[str, Any]:
        """生成空分析结果"""
        return {
            'timestamp': datetime.now().isoformat(),
            'analysis_type': 'empty',
            'primary_emotion': {
                'type': 'unknown',
                'name': '未知',
                'intensity': 0,
                'confidence': 0,
                'description': '没有可分析的数据'
            },
            'emotion_spectrum': [],
            'confidence': 0,
            'insights': [
                {
                    'type': 'empty',
                    'title': '开始记录',
                    'content': '还没有情绪记录数据，请先记录一些情绪信息以获得AI分析。',
                    'confidence': 1.0,
                    'actionable': True
                }
            ],
            'suggestions': {
                'immediate': [
                    {'id': 1, 'title': '开始记录', 'description': '记录您当前的情绪状态', 'difficulty': 'easy'}
                ],
                'longterm': [
                    {'id': 2, 'title': '养成习惯', 'description': '建立定期记录情绪的习惯', 'difficulty': 'medium'}
                ],
                'lifestyle': [
                    {'id': 3, 'title': '关注情绪健康', 'description': '开始关注自己的情绪变化', 'difficulty': 'easy'}
                ],
                'social': [
                    {'id': 4, 'title': '寻求支持', 'description': '与信任的人分享你的感受', 'difficulty': 'medium'}
                ]
            },
            'trend': {
                'average': 0,
                'volatility': '无数据',
                'direction': '无法评估',
                'period': '需要数据'
            },
            'deep_analysis': {
                'score': 0,
                'dimensions': []
            },
            'action_plan': [
                {'title': '开始记录', 'description': '记录第一条情绪数据', 'completed': False}
            ]
        } 