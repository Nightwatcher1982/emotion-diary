import random
import requests
import datetime
from django.utils import timezone
from django.conf import settings
from .models import PhoneVerificationCode, WechatUserInfo, User
import logging

logger = logging.getLogger(__name__)


class SMSService:
    """短信验证码服务"""
    
    @staticmethod
    def generate_code():
        """生成6位随机验证码"""
        return str(random.randint(100000, 999999))
    
    @staticmethod
    def send_verification_code(phone, purpose='login'):
        """发送验证码"""
        try:
            # 生成验证码
            code = SMSService.generate_code()
            
            # 设置过期时间 (5分钟后过期)
            expires_at = timezone.now() + datetime.timedelta(minutes=5)
            
            # 保存验证码到数据库
            verification_code = PhoneVerificationCode.objects.create(
                phone=phone,
                code=code,
                purpose=purpose,
                expires_at=expires_at
            )
            
            # 发送短信 (这里使用模拟发送)
            success = SMSService._send_sms(phone, code, purpose)
            
            if success:
                logger.info(f"验证码发送成功: {phone} - {code} ({purpose})")
                return {
                    'success': True,
                    'message': '验证码发送成功',
                    'code': code if settings.DEBUG else None  # 开发环境返回验证码
                }
            else:
                # 发送失败，删除验证码记录
                verification_code.delete()
                return {
                    'success': False,
                    'message': '验证码发送失败，请稍后重试'
                }
                
        except Exception as e:
            logger.error(f"发送验证码异常: {phone} - {str(e)}")
            return {
                'success': False,
                'message': '验证码发送失败，请稍后重试'
            }
    
    @staticmethod
    def _send_sms(phone, code, purpose):
        """实际发送短信 (这里是模拟实现)"""
        
        # 在开发环境中，我们模拟发送成功
        if settings.DEBUG:
            logger.info(f"[模拟短信] 手机号: {phone}, 验证码: {code}, 用途: {purpose}")
            return True
        
        # 生产环境中，这里应该调用真实的短信服务API
        # 例如阿里云短信、腾讯云短信等
        try:
            # 示例：调用短信服务API
            # response = requests.post(
            #     settings.SMS_API_URL,
            #     data={
            #         'phone': phone,
            #         'code': code,
            #         'template': get_sms_template(purpose),
            #         'api_key': settings.SMS_API_KEY
            #     },
            #     timeout=10
            # )
            # return response.status_code == 200
            
            # 目前返回True模拟发送成功
            return True
            
        except Exception as e:
            logger.error(f"短信发送API调用失败: {str(e)}")
            return False
    
    @staticmethod
    def verify_code(phone, code, purpose):
        """验证验证码"""
        try:
            verification_code = PhoneVerificationCode.objects.filter(
                phone=phone,
                code=code,
                purpose=purpose,
                is_used=False
            ).latest('created_at')
            
            if verification_code.is_expired():
                return {
                    'success': False,
                    'message': '验证码已过期'
                }
            
            # 标记为已使用
            verification_code.is_used = True
            verification_code.save()
            
            return {
                'success': True,
                'message': '验证码验证成功'
            }
            
        except PhoneVerificationCode.DoesNotExist:
            return {
                'success': False,
                'message': '验证码不存在或已失效'
            }


class WechatService:
    """微信登录服务"""
    
    # 微信小程序配置
    WECHAT_APPID = getattr(settings, 'WECHAT_APPID', '')
    WECHAT_SECRET = getattr(settings, 'WECHAT_SECRET', '')
    
    @staticmethod
    def get_openid_by_code(code):
        """通过微信授权码获取openid"""
        try:
            # 调用微信API获取openid
            url = "https://api.weixin.qq.com/sns/jscode2session"
            params = {
                'appid': WechatService.WECHAT_APPID,
                'secret': WechatService.WECHAT_SECRET,
                'js_code': code,
                'grant_type': 'authorization_code'
            }
            
            if settings.DEBUG:
                # 开发环境模拟返回
                logger.info(f"[模拟微信登录] 授权码: {code}")
                return {
                    'success': True,
                    'openid': f'mock_openid_{code}',
                    'unionid': f'mock_unionid_{code}',
                    'session_key': 'mock_session_key'
                }
            
            response = requests.get(url, params=params, timeout=10)
            data = response.json()
            
            if 'openid' in data:
                return {
                    'success': True,
                    'openid': data['openid'],
                    'unionid': data.get('unionid', ''),
                    'session_key': data.get('session_key', '')
                }
            else:
                logger.error(f"微信登录失败: {data}")
                return {
                    'success': False,
                    'message': data.get('errmsg', '微信登录失败')
                }
                
        except Exception as e:
            logger.error(f"微信登录异常: {str(e)}")
            return {
                'success': False,
                'message': '微信登录失败，请重试'
            }
    
    @staticmethod
    def get_or_create_user(openid, unionid='', user_info=None):
        """根据openid获取或创建用户"""
        try:
            # 首先尝试通过openid查找用户
            try:
                user = User.objects.get(wechat_openid=openid)
                return {
                    'success': True,
                    'user': user,
                    'is_new_user': False
                }
            except User.DoesNotExist:
                pass
            
            # 如果有unionid，尝试通过unionid查找
            if unionid:
                try:
                    user = User.objects.get(wechat_unionid=unionid)
                    # 更新openid
                    user.wechat_openid = openid
                    user.save()
                    return {
                        'success': True,
                        'user': user,
                        'is_new_user': False
                    }
                except User.DoesNotExist:
                    pass
            
            # 创建新用户
            if not user_info:
                user_info = {}
            
            # 生成唯一用户名，避免重复
            base_username = f"wx_{openid[:8]}"
            username = base_username
            counter = 1
            while User.objects.filter(username=username).exists():
                username = f"{base_username}_{counter}"
                counter += 1
            
            nickname = user_info.get('nickname', f'微信用户{openid[-4:]}')
            
            user = User.objects.create(
                username=username,
                nickname=nickname,
                wechat_openid=openid,
                wechat_unionid=unionid,
                login_type='wechat',
                avatar=user_info.get('avatar_url', '')
            )
            
            # 创建微信用户信息
            WechatUserInfo.objects.create(
                user=user,
                openid=openid,
                unionid=unionid,
                nickname=user_info.get('nickname', ''),
                avatar_url=user_info.get('avatar_url', ''),
                gender=user_info.get('gender', 'unknown'),
                city=user_info.get('city', ''),
                province=user_info.get('province', ''),
                country=user_info.get('country', '')
            )
            
            # 创建用户档案
            from .models import UserProfile
            UserProfile.objects.create(user=user)
            
            return {
                'success': True,
                'user': user,
                'is_new_user': True
            }
            
        except Exception as e:
            logger.error(f"微信用户创建失败: {str(e)}")
            return {
                'success': False,
                'message': '用户创建失败'
            }


class AuthService:
    """认证服务"""
    
    @staticmethod
    def create_user_by_phone(phone, nickname=''):
        """通过手机号创建用户"""
        try:
            # 检查手机号是否已注册
            if User.objects.filter(phone=phone).exists():
                return {
                    'success': False,
                    'message': '该手机号已被注册'
                }
            
            # 生成唯一用户名，避免重复
            base_username = f"user_{phone}"
            username = base_username
            counter = 1
            while User.objects.filter(username=username).exists():
                username = f"{base_username}_{counter}"
                counter += 1
            
            # 创建用户
            user = User.objects.create(
                username=username,
                phone=phone,
                nickname=nickname or f"用户{phone[-4:]}",
                login_type='phone',
                is_phone_verified=True
            )
            
            # 创建用户档案
            from .models import UserProfile
            UserProfile.objects.create(user=user)
            
            return {
                'success': True,
                'user': user
            }
            
        except Exception as e:
            logger.error(f"手机号用户创建失败: {str(e)}")
            return {
                'success': False,
                'message': '用户创建失败'
            }
    
    @staticmethod
    def get_user_by_phone(phone):
        """通过手机号获取用户"""
        try:
            user = User.objects.get(phone=phone, is_phone_verified=True)
            return {
                'success': True,
                'user': user
            }
        except User.DoesNotExist:
            return {
                'success': False,
                'message': '用户不存在'
            } 