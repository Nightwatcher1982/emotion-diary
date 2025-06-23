from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    RegisterView, LoginView, LogoutView, ProfileView, ChangePasswordView,
    SendSMSView, PhoneLoginView, WechatLoginView, PhoneRegisterView,
    UserViewSet, UserProfileViewSet
)

# 创建路由器
router = DefaultRouter()
router.register(r'users', UserViewSet)
router.register(r'profiles', UserProfileViewSet)

app_name = 'accounts'

urlpatterns = [
    # 传统认证方式 (兼容)
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('logout/', LogoutView.as_view(), name='logout'),
    
    # 手机验证码认证
    path('sms/send/', SendSMSView.as_view(), name='send_sms'),
    path('phone/login/', PhoneLoginView.as_view(), name='phone_login'),
    path('phone/register/', PhoneRegisterView.as_view(), name='phone_register'),
    
    # 微信登录
    path('wechat/login/', WechatLoginView.as_view(), name='wechat_login'),
    
    # 用户管理
    path('profile/', ProfileView.as_view(), name='profile'),
    path('change-password/', ChangePasswordView.as_view(), name='change_password'),
    
    # ViewSet路由
    path('', include(router.urls)),
] 