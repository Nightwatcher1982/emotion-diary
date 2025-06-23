from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
import json

@csrf_exempt
@require_http_methods(["GET"])
def health_check(request):
    """健康检查端点"""
    return JsonResponse({
        'status': 'healthy',
        'message': 'AI情绪日记API服务运行正常',
        'version': '1.0.0'
    }) 