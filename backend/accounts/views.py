from rest_framework import generics, viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from django.utils import timezone
from drf_spectacular.utils import extend_schema, OpenApiParameter
from .models import User, UserProfile, PhoneVerificationCode, WechatUserInfo
from .serializers import (
    UserSerializer, UserProfileSerializer, RegisterSerializer,
    LoginSerializer, ChangePasswordSerializer, ProfileUpdateSerializer,
    SendSMSSerializer, PhoneLoginSerializer, WechatLoginSerializer,
    PhoneRegisterSerializer
)
from .services import SMSService, WechatService, AuthService
import logging

logger = logging.getLogger(__name__)


class SendSMSView(generics.GenericAPIView):
    """发送短信验证码"""
    serializer_class = SendSMSSerializer
    permission_classes = [AllowAny]
    
    @extend_schema(
        summary="发送短信验证码",
        description="发送手机验证码，支持登录、注册等用途",
        tags=["认证"]
    )
    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            phone = serializer.validated_data['phone']
            purpose = serializer.validated_data['purpose']
            
            # 发送验证码
            result = SMSService.send_verification_code(phone, purpose)
            
            if result['success']:
                response_data = {
                    'message': result['message'],
                    'phone': phone,
                    'expires_in': 300  # 5分钟
                }
                
                # 开发环境返回验证码
                if result.get('code'):
                    response_data['code'] = result['code']
                
                return Response(response_data, status=status.HTTP_200_OK)
            else:
                return Response({
                    'error': result['message']
                }, status=status.HTTP_400_BAD_REQUEST)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class PhoneLoginView(generics.GenericAPIView):
    """手机验证码登录"""
    serializer_class = PhoneLoginSerializer
    permission_classes = [AllowAny]
    
    @extend_schema(
        summary="手机验证码登录",
        description="使用手机号和验证码登录，如果用户不存在则自动注册",
        tags=["认证"]
    )
    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            phone = serializer.validated_data['phone']
            nickname = serializer.validated_data.get('nickname', '')
            
            # 查找或创建用户
            user_result = AuthService.get_user_by_phone(phone)
            
            if not user_result['success']:
                # 用户不存在，创建新用户
                create_result = AuthService.create_user_by_phone(phone, nickname)
                if not create_result['success']:
                    return Response({
                        'error': create_result['message']
                    }, status=status.HTTP_400_BAD_REQUEST)
                
                user = create_result['user']
                is_new_user = True
            else:
                user = user_result['user']
                is_new_user = False
                
                # 更新昵称（如果提供）
                if nickname and not user.nickname:
                    user.nickname = nickname
                    user.save()
            
            # 更新登录信息
            user.last_login = timezone.now()
            user.last_login_ip = self.get_client_ip(request)
            user.save()
            
            # 生成token
            token, created = Token.objects.get_or_create(user=user)
            
            return Response({
                'user': UserSerializer(user).data,
                'token': token.key,
                'is_new_user': is_new_user,
                'message': '登录成功'
            }, status=status.HTTP_200_OK)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def get_client_ip(self, request):
        """获取客户端IP"""
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip


class WechatLoginView(generics.GenericAPIView):
    """微信登录"""
    serializer_class = WechatLoginSerializer
    permission_classes = [AllowAny]
    
    @extend_schema(
        summary="微信登录",
        description="使用微信授权码登录，如果用户不存在则自动注册",
        tags=["认证"]
    )
    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            code = serializer.validated_data['code']
            nickname = serializer.validated_data.get('nickname', '')
            avatar_url = serializer.validated_data.get('avatar_url', '')
            gender = serializer.validated_data.get('gender', 'unknown')
            
            # 通过微信授权码获取openid
            wechat_result = WechatService.get_openid_by_code(code)
            
            if not wechat_result['success']:
                return Response({
                    'error': wechat_result['message']
                }, status=status.HTTP_400_BAD_REQUEST)
            
            openid = wechat_result['openid']
            unionid = wechat_result.get('unionid', '')
            
            # 构建用户信息
            user_info = {
                'nickname': nickname,
                'avatar_url': avatar_url,
                'gender': gender
            }
            
            # 获取或创建用户
            user_result = WechatService.get_or_create_user(openid, unionid, user_info)
            
            if not user_result['success']:
                return Response({
                    'error': user_result['message']
                }, status=status.HTTP_400_BAD_REQUEST)
            
            user = user_result['user']
            is_new_user = user_result['is_new_user']
            
            # 更新登录信息
            user.last_login = timezone.now()
            user.last_login_ip = self.get_client_ip(request)
            user.save()
            
            # 生成token
            token, created = Token.objects.get_or_create(user=user)
            
            return Response({
                'user': UserSerializer(user).data,
                'token': token.key,
                'is_new_user': is_new_user,
                'message': '登录成功'
            }, status=status.HTTP_200_OK)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def get_client_ip(self, request):
        """获取客户端IP"""
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip


class PhoneRegisterView(generics.CreateAPIView):
    """手机号注册"""
    queryset = User.objects.all()
    serializer_class = PhoneRegisterSerializer
    permission_classes = [AllowAny]
    
    @extend_schema(
        summary="手机号注册",
        description="使用手机号和验证码注册新账户",
        tags=["认证"]
    )
    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            
            # 更新登录信息
            user.last_login = timezone.now()
            user.last_login_ip = self.get_client_ip(request)
            user.save()
            
            # 生成token
            token, created = Token.objects.get_or_create(user=user)
            
            return Response({
                'user': UserSerializer(user).data,
                'token': token.key,
                'message': '注册成功'
            }, status=status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def get_client_ip(self, request):
        """获取客户端IP"""
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip


# 原有视图保持兼容
class RegisterView(generics.CreateAPIView):
    """传统密码注册 (兼容)"""
    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [AllowAny]
    
    @extend_schema(
        summary="用户注册 (密码方式)",
        description="使用用户名、邮箱、密码注册账户",
        tags=["认证"]
    )
    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            token, created = Token.objects.get_or_create(user=user)
            return Response({
                'user': UserSerializer(user).data,
                'token': token.key,
                'message': '注册成功'
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LoginView(generics.GenericAPIView):
    """传统密码登录 (兼容)"""
    serializer_class = LoginSerializer
    permission_classes = [AllowAny]
    
    @extend_schema(
        summary="用户登录 (密码方式)",
        description="使用用户名和密码登录",
        tags=["认证"]
    )
    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            username = serializer.validated_data['username']
            password = serializer.validated_data['password']
            
            user = authenticate(username=username, password=password)
            if user:
                if user.is_active:
                    login(request, user)
                    token, created = Token.objects.get_or_create(user=user)
                    return Response({
                        'user': UserSerializer(user).data,
                        'token': token.key,
                        'message': '登录成功'
                    })
                else:
                    return Response({
                        'error': '账户已被禁用'
                    }, status=status.HTTP_400_BAD_REQUEST)
            else:
                return Response({
                    'error': '用户名或密码错误'
                }, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LogoutView(generics.GenericAPIView):
    """用户登出"""
    permission_classes = [IsAuthenticated]
    
    @extend_schema(
        summary="用户登出",
        description="删除用户token，登出系统",
        tags=["认证"]
    )
    def post(self, request, *args, **kwargs):
        try:
            # 删除用户的token
            request.user.auth_token.delete()
            logout(request)
            return Response({
                'message': '登出成功'
            }, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({
                'error': '登出失败'
            }, status=status.HTTP_400_BAD_REQUEST)


class ProfileView(generics.RetrieveUpdateAPIView):
    """用户资料管理"""
    serializer_class = ProfileUpdateSerializer
    permission_classes = [IsAuthenticated]
    
    def get_object(self):
        return self.request.user
    
    @extend_schema(
        summary="获取用户资料",
        description="获取当前登录用户的详细资料",
        tags=["用户管理"]
    )
    def get(self, request, *args, **kwargs):
        user = self.get_object()
        return Response(UserSerializer(user).data)
    
    @extend_schema(
        summary="更新用户资料",
        description="更新当前登录用户的资料信息",
        tags=["用户管理"]
    )
    def patch(self, request, *args, **kwargs):
        return self.partial_update(request, *args, **kwargs)


class ChangePasswordView(generics.GenericAPIView):
    """修改密码"""
    serializer_class = ChangePasswordSerializer
    permission_classes = [IsAuthenticated]
    
    @extend_schema(
        summary="修改密码",
        description="修改当前用户的登录密码",
        tags=["用户管理"]
    )
    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            user = request.user
            old_password = serializer.validated_data['old_password']
            new_password = serializer.validated_data['new_password']
            
            if not user.check_password(old_password):
                return Response({
                    'error': '原密码错误'
                }, status=status.HTTP_400_BAD_REQUEST)
            
            user.set_password(new_password)
            user.save()
            
            return Response({
                'message': '密码修改成功'
            }, status=status.HTTP_200_OK)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UserViewSet(viewsets.ModelViewSet):
    """用户管理ViewSet"""
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        # 普通用户只能查看自己的信息
        if not self.request.user.is_staff:
            return User.objects.filter(id=self.request.user.id)
        return User.objects.all()
    
    @action(detail=False, methods=['get'])
    def me(self, request):
        """获取当前用户信息"""
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)
    
    @action(detail=False, methods=['post'])
    def update_streak(self, request):
        """更新连续记录天数"""
        request.user.update_streak()
        return Response({
            'streak_days': request.user.streak_days,
            'message': '连续天数已更新'
        })


class UserProfileViewSet(viewsets.ModelViewSet):
    """用户档案管理ViewSet"""
    queryset = UserProfile.objects.all()
    serializer_class = UserProfileSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        # 用户只能访问自己的档案
        return UserProfile.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user) 