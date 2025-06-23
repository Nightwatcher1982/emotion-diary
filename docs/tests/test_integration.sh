#!/bin/bash

# AI情绪日记 - 前后端联调测试脚本
echo "🚀 AI情绪日记 - 前后端联调测试"
echo "=================================="

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 测试结果统计
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 测试函数
test_api() {
    local test_name="$1"
    local url="$2"
    local method="${3:-GET}"
    local data="$4"
    local expected_status="${5:-200}"
    local token="$6"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "\n${BLUE}测试: $test_name${NC}"
    
    # 构建curl命令
    local curl_cmd="curl -s -w '%{http_code}' -o /tmp/api_response"
    
    if [ "$method" != "GET" ]; then
        curl_cmd="$curl_cmd -X $method"
    fi
    
    if [ -n "$data" ]; then
        curl_cmd="$curl_cmd -H 'Content-Type: application/json' -d '$data'"
    fi
    
    if [ -n "$token" ]; then
        curl_cmd="$curl_cmd -H 'Authorization: Token $token'"
    fi
    
    curl_cmd="$curl_cmd $url"
    
    # 执行请求
    local status_code=$(eval $curl_cmd)
    local response=$(cat /tmp/api_response)
    
    # 检查结果
    if [ "$status_code" = "$expected_status" ]; then
        echo -e "${GREEN}✅ PASS${NC} - 状态码: $status_code"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}❌ FAIL${NC} - 期望: $expected_status, 实际: $status_code"
        echo -e "${RED}响应: $response${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# 检查服务状态
check_services() {
    echo -e "\n${YELLOW}📋 检查服务状态${NC}"
    
    # 检查后端服务
    if curl -s http://127.0.0.1:8000/api/docs/ > /dev/null; then
        echo -e "${GREEN}✅ 后端服务运行正常${NC} (http://127.0.0.1:8000)"
    else
        echo -e "${RED}❌ 后端服务未启动${NC}"
        echo "请先启动后端服务: cd backend && python manage.py runserver"
        exit 1
    fi
    
    # 检查前端服务
    if curl -s http://localhost:5173 > /dev/null; then
        echo -e "${GREEN}✅ 前端服务运行正常${NC} (http://localhost:5173)"
    else
        echo -e "${RED}❌ 前端服务未启动${NC}"
        echo "请先启动前端服务: cd frontend && npm run dev"
        exit 1
    fi
}

# 获取认证Token
get_auth_token() {
    echo -e "\n${YELLOW}🔐 获取认证Token${NC}"
    
    local login_response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d '{"username":"testuser","password":"testpass123"}' \
        http://127.0.0.1:8000/api/v1/auth/login/)
    
    # 提取token（简单的JSON解析）
    TOKEN=$(echo $login_response | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    
    if [ -n "$TOKEN" ]; then
        echo -e "${GREEN}✅ Token获取成功${NC}: ${TOKEN:0:10}..."
        return 0
    else
        echo -e "${RED}❌ Token获取失败${NC}"
        echo "响应: $login_response"
        exit 1
    fi
}

# 运行API测试
run_api_tests() {
    echo -e "\n${YELLOW}🧪 运行API测试${NC}"
    
    # 认证相关测试
    test_api "用户登录" \
        "http://127.0.0.1:8000/api/v1/auth/login/" \
        "POST" \
        '{"username":"testuser","password":"testpass123"}' \
        "200"
    
    test_api "获取用户资料" \
        "http://127.0.0.1:8000/api/v1/auth/profile/" \
        "GET" \
        "" \
        "200" \
        "$TOKEN"
    
    # 情绪记录相关测试
    test_api "获取情绪记录列表" \
        "http://127.0.0.1:8000/api/v1/emotions/records/" \
        "GET" \
        "" \
        "200" \
        "$TOKEN"
    
    test_api "获取今日记录" \
        "http://127.0.0.1:8000/api/v1/emotions/records/today/" \
        "GET" \
        "" \
        "200" \
        "$TOKEN"
    
    test_api "获取最近记录" \
        "http://127.0.0.1:8000/api/v1/emotions/records/recent/" \
        "GET" \
        "" \
        "200" \
        "$TOKEN"
    
    test_api "创建情绪记录" \
        "http://127.0.0.1:8000/api/v1/emotions/records/" \
        "POST" \
        '{"emotion_type":"happy","intensity":8,"scenario":"work","description":"联调测试记录","triggers":["测试"],"physical_symptoms":[],"coping_methods":[]}' \
        "201" \
        "$TOKEN"
    
    # 统计相关测试
    test_api "获取情绪统计" \
        "http://127.0.0.1:8000/api/v1/emotions/records/statistics/" \
        "GET" \
        "" \
        "200" \
        "$TOKEN"
    
    # AI分析相关测试（开发中状态）
    test_api "请求AI分析" \
        "http://127.0.0.1:8000/api/v1/ai/analyze/" \
        "POST" \
        '{"record_ids":[1]}' \
        "200" \
        "$TOKEN"
}

# 测试前端页面
test_frontend() {
    echo -e "\n${YELLOW}🌐 测试前端页面${NC}"
    
    # 测试主要页面是否可访问
    local pages=("" "pages/login/index" "pages/record/index" "pages/analysis/index" "pages/statistics/index" "pages/profile/index")
    
    for page in "${pages[@]}"; do
        local url="http://localhost:5173/$page"
        local page_name="${page:-首页}"
        
        if curl -s "$url" | grep -q "<!DOCTYPE html"; then
            echo -e "${GREEN}✅ $page_name 页面正常${NC}"
        else
            echo -e "${RED}❌ $page_name 页面异常${NC}"
        fi
    done
}

# 生成测试报告
generate_report() {
    echo -e "\n${YELLOW}📊 测试报告${NC}"
    echo "=================================="
    echo -e "总测试数: ${BLUE}$TOTAL_TESTS${NC}"
    echo -e "通过测试: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "失败测试: ${RED}$FAILED_TESTS${NC}"
    
    local success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo -e "成功率: ${BLUE}$success_rate%${NC}"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "\n${GREEN}🎉 所有测试通过！前后端联调成功！${NC}"
        echo -e "${GREEN}✅ 可以开始使用应用进行功能测试${NC}"
    else
        echo -e "\n${RED}⚠️  有测试失败，请检查相关问题${NC}"
        exit 1
    fi
}

# 清理临时文件
cleanup() {
    rm -f /tmp/api_response
}

# 主函数
main() {
    echo -e "${BLUE}开始前后端联调测试...${NC}"
    
    # 设置错误处理
    trap cleanup EXIT
    
    # 执行测试步骤
    check_services
    get_auth_token
    run_api_tests
    test_frontend
    generate_report
    
    echo -e "\n${GREEN}🚀 联调测试完成！${NC}"
    echo -e "${BLUE}前端地址: http://localhost:5173${NC}"
    echo -e "${BLUE}后端API: http://127.0.0.1:8000/api/docs/${NC}"
    echo -e "${BLUE}管理后台: http://127.0.0.1:8000/admin/${NC}"
}

# 运行主函数
main "$@" 