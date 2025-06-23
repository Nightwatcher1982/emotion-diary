#!/usr/bin/env python3
"""
千帆AI服务配置验证脚本 (支持V2版本)
用于验证百度千帆AI服务的配置和连接状态
"""

import os
import sys
import django
from pathlib import Path

# 添加项目路径
project_root = Path(__file__).parent / "backend"
sys.path.insert(0, str(project_root))

# 设置Django环境
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'emotion_diary_api.settings')
django.setup()

def check_environment_variables():
    """检查环境变量配置"""
    print("🔍 检查环境变量配置...")
    
    # 新的API Key认证 (当前唯一支持的方式)
    api_key = os.getenv('QIANFAN_API_KEY')
    
    # 旧的配置方式（已过时）
    ak = os.getenv('QIANFAN_AK')
    sk = os.getenv('QIANFAN_SK')
    access_key = os.getenv('QIANFAN_ACCESS_KEY')
    secret_key = os.getenv('QIANFAN_SECRET_KEY')
    app_id = os.getenv('QIANFAN_APP_ID')
    
    auth_methods = []
    
    if api_key and api_key.strip():
        auth_methods.append("✅ API Key Bearer Token认证 (当前支持)")
        print(f"   API Key: {api_key[:20]}***{api_key[-4:] if len(api_key) > 24 else '***'}")
    
    # 检查旧配置并提示升级
    deprecated_configs = []
    if ak and sk:
        deprecated_configs.append("AK/SK配置")
    if access_key and secret_key:
        deprecated_configs.append("IAM认证配置")
    if app_id:
        deprecated_configs.append("应用ID配置")
    
    if deprecated_configs:
        print(f"\n⚠️  检测到已过时的配置: {', '.join(deprecated_configs)}")
        print("   千帆平台已不支持这些认证方式，请升级到API Key认证")
    
    if not auth_methods:
        print("❌ 未找到有效的认证配置")
        print("\n📋 请配置以下环境变量：")
        print("   QIANFAN_API_KEY=your-api-key")
        print("\n💡 获取方式：")
        print("   1. 访问百度智能云控制台")
        print("   2. 进入安全认证 → API Key")
        print("   3. 创建API Key并配置资源")
        return False
    
    print(f"\n✅ 找到 {len(auth_methods)} 种有效认证配置:")
    for method in auth_methods:
        print(f"   {method}")
    
    return True

def check_qianfan_sdk():
    """检查千帆SDK"""
    print("\n🔍 检查千帆SDK...")
    
    try:
        import qianfan
        print(f"✅ 千帆SDK已安装，版本: {getattr(qianfan, '__version__', '未知')}")
        return True
    except ImportError as e:
        print(f"❌ 千帆SDK未安装: {e}")
        print("📦 请运行以下命令安装:")
        print("   pip install qianfan")
        return False

def test_ai_service_initialization():
    """测试AI服务初始化"""
    print("\n🔍 测试AI服务初始化...")
    
    try:
        from ai_analysis.ai_service import AIAnalysisService
        
        # 创建AI服务实例
        ai_service = AIAnalysisService()
        
        # 获取认证状态
        auth_status = ai_service.get_auth_status()
        
        print(f"📊 认证状态: {auth_status['status']}")
        print(f"📝 详细信息: {auth_status['message']}")
        print(f"🔐 认证方式: {auth_status['auth_method'] or '无'}")
        print(f"🤖 AI启用: {'是' if auth_status['ai_enabled'] else '否'}")
        
        if auth_status['ai_enabled']:
            print("✅ AI服务初始化成功")
            return True
        else:
            print("⚠️  AI服务使用模拟模式")
            return False
            
    except Exception as e:
        print(f"❌ AI服务初始化失败: {e}")
        return False

def test_api_call():
    """测试API调用"""
    print("\n🔍 测试API调用...")
    
    try:
        from ai_analysis.ai_service import AIAnalysisService
        
        ai_service = AIAnalysisService()
        auth_status = ai_service.get_auth_status()
        
        if not auth_status['ai_enabled']:
            print("⚠️  跳过API测试 - AI服务未启用")
            return False
        
        # 测试简单的API调用
        test_prompt = "你好，请简单介绍一下你自己。"
        print(f"📤 发送测试请求: {test_prompt}")
        
        response = ai_service._call_qianfan_api(test_prompt, max_tokens=100)
        
        if response and len(response.strip()) > 0:
            print(f"📥 收到响应: {response[:100]}{'...' if len(response) > 100 else ''}")
            print("✅ API调用成功")
            return True
        else:
            print("❌ API调用失败 - 无响应")
            return False
            
    except Exception as e:
        print(f"❌ API调用测试失败: {e}")
        return False

def print_configuration_guide():
    """打印配置指南"""
    print("\n" + "="*60)
    print("📚 百度千帆API Key配置指南")
    print("="*60)
    
    print("\n🎯 配置步骤:")
    print("1. 访问百度智能云控制台: https://console.bce.baidu.com/")
    print("2. 进入安全认证 → API Key")
    print("3. 点击创建API Key，选择千帆ModelBuilder")
    print("4. 配置资源（选择所有资源或特定应用）")
    print("5. 获取API Key值")
    
    print("\n🔐 认证方式:")
    print("当前支持: API Key Bearer Token认证")
    print("   - 在.env文件中设置:")
    print("   - QIANFAN_API_KEY=your-api-key")
    
    print("\n📝 API调用示例:")
    print("   curl -X POST 'https://qianfan.baidubce.com/v2/chat/completions' \\")
    print("     -H 'Content-Type: application/json' \\")
    print("     -H 'Authorization: Bearer your-api-key' \\")
    print("     -d '{\"model\": \"ernie-3.5-8k\", \"messages\": [{\"role\": \"user\", \"content\": \"你好\"}]}'")
    
    print("\n💡 重要提醒:")
    print("- 千帆平台已升级，不再支持AK/SK、IAM认证、应用ID等方式")
    print("- 只支持API Key Bearer Token认证")
    print("- API Key值永久有效")
    print("- 配置后需要重启Django服务")
    print("- 请妥善保管API Key，不要泄露")

def main():
    """主函数"""
    print("🚀 千帆AI服务配置验证 (V2版本支持)")
    print("="*50)
    
    # 检查步骤
    checks = [
        ("环境变量", check_environment_variables),
        ("千帆SDK", check_qianfan_sdk),
        ("AI服务初始化", test_ai_service_initialization),
        ("API调用测试", test_api_call),
    ]
    
    results = []
    for name, check_func in checks:
        try:
            result = check_func()
            results.append((name, result))
        except Exception as e:
            print(f"❌ {name}检查失败: {e}")
            results.append((name, False))
    
    # 总结
    print("\n" + "="*50)
    print("📊 检查结果总结")
    print("="*50)
    
    for name, result in results:
        status = "✅ 通过" if result else "❌ 失败"
        print(f"{name}: {status}")
    
    success_count = sum(1 for _, result in results if result)
    total_count = len(results)
    
    print(f"\n🎯 总体状态: {success_count}/{total_count} 项检查通过")
    
    if success_count == total_count:
        print("🎉 恭喜！千帆AI服务配置完全正常")
    elif success_count >= 2:
        print("⚠️  基本配置正常，部分功能可能受限")
    else:
        print("❌ 配置存在问题，请检查配置")
    
    # 显示配置指南
    if success_count < total_count:
        print_configuration_guide()

if __name__ == "__main__":
    main() 