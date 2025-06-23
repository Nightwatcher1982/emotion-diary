#!/bin/bash

# AI分析页面功能测试脚本
echo "========================================="
echo "🤖 AI分析页面功能测试"
echo "========================================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 测试结果统计
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 测试函数
test_api() {
    local test_name="$1"
    local method="$2"
    local url="$3"
    local data="$4"
    local expected_status="$5"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "${BLUE}测试 $TOTAL_TESTS: $test_name${NC}"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" -H "Authorization: Token $TOKEN" "$url")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" -H "Content-Type: application/json" -H "Authorization: Token $TOKEN" -d "$data" "$url")
    fi
    
    status_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$status_code" = "$expected_status" ]; then
        echo -e "${GREEN}✅ 通过 (状态码: $status_code)${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}❌ 失败 (期望: $expected_status, 实际: $status_code)${NC}"
        echo -e "${RED}响应内容: $body${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# 1. 检查服务状态
echo -e "${YELLOW}1. 检查服务状态...${NC}"
if curl -s http://127.0.0.1:8000/api/v1/auth/login/ > /dev/null; then
    echo -e "${GREEN}✅ 后端服务正常运行${NC}"
else
    echo -e "${RED}❌ 后端服务未启动，请先启动后端服务${NC}"
    exit 1
fi

if curl -s http://localhost:5173/ > /dev/null; then
    echo -e "${GREEN}✅ 前端服务正常运行${NC}"
else
    echo -e "${RED}❌ 前端服务未启动，请先启动前端服务${NC}"
    exit 1
fi

# 2. 获取认证Token
echo -e "${YELLOW}2. 获取认证Token...${NC}"
login_response=$(curl -s -X POST -H "Content-Type: application/json" \
    -d '{"username":"testuser","password":"testpass123"}' \
    http://127.0.0.1:8000/api/v1/auth/login/)

TOKEN=$(echo $login_response | grep -o '"token":"[^"]*"' | sed 's/"token":"\([^"]*\)"/\1/')

if [ -n "$TOKEN" ]; then
    echo -e "${GREEN}✅ Token获取成功: ${TOKEN:0:20}...${NC}"
else
    echo -e "${RED}❌ Token获取失败${NC}"
    echo "响应: $login_response"
    exit 1
fi

# 3. 准备测试数据 - 创建一些情绪记录
echo -e "${YELLOW}3. 准备测试数据...${NC}"

# 创建多条测试记录用于AI分析
test_records=(
    '{"emotion_type":"happy","intensity":8,"scenario":"work","description":"今天工作很顺利，完成了重要项目，感觉很有成就感","triggers":["项目完成","团队合作"],"physical_symptoms":["精力充沛"],"coping_methods":["庆祝成功"]}'
    '{"emotion_type":"anxious","intensity":6,"scenario":"personal","description":"明天有重要面试，有些紧张和担心","triggers":["面试压力","未知结果"],"physical_symptoms":["心跳加速","紧张"],"coping_methods":["深呼吸","准备充分"]}'
    '{"emotion_type":"calm","intensity":7,"scenario":"personal","description":"晚上散步时感到很平静，心情放松","triggers":["自然环境","运动"],"physical_symptoms":["身心放松"],"coping_methods":["户外运动","冥想"]}'
    '{"emotion_type":"sad","intensity":5,"scenario":"social","description":"和朋友发生了一些误会，感到有些难过","triggers":["人际冲突","沟通问题"],"physical_symptoms":["情绪低落"],"coping_methods":["反思沟通","寻求理解"]}'
)

record_ids=()
for record_data in "${test_records[@]}"; do
    echo -e "${BLUE}创建测试记录...${NC}"
    response=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Token $TOKEN" -d "$record_data" "http://127.0.0.1:8000/api/v1/emotions/records/")
    record_id=$(echo $response | grep -o '"id":[0-9]*' | sed 's/"id"://')
    if [ -n "$record_id" ]; then
        record_ids+=($record_id)
        echo -e "${GREEN}✅ 记录创建成功 (ID: $record_id)${NC}"
    else
        echo -e "${RED}❌ 记录创建失败${NC}"
    fi
done

# 4. 测试AI分析API
echo -e "${YELLOW}4. 测试AI分析API...${NC}"

# 测试基础AI分析
analysis_data='{
    "emotion_records": ['$(IFS=,; echo "${record_ids[*]}")'],
    "analysis_type": "comprehensive",
    "include_suggestions": true,
    "include_trend": true
}'

test_api "请求AI综合分析" "POST" "http://127.0.0.1:8000/api/v1/ai/analyze/" "$analysis_data" "200"

# 测试单条记录分析
if [ ${#record_ids[@]} -gt 0 ]; then
    single_analysis="{\"emotion_records\":[${record_ids[0]}],\"analysis_type\":\"single\",\"include_suggestions\":true}"
    test_api "单条记录AI分析" "POST" "http://127.0.0.1:8000/api/v1/ai/analyze/" "$single_analysis" "200"
fi

# 测试情绪洞察
insight_data='{
    "emotion_records": ['$(IFS=,; echo "${record_ids[*]}")'],
    "analysis_type": "insights",
    "focus_areas": ["patterns", "triggers", "coping"]
}'

test_api "情绪洞察分析" "POST" "http://127.0.0.1:8000/api/v1/ai/analyze/" "$insight_data" "200"

# 测试建议生成
suggestion_data='{
    "emotion_records": ['$(IFS=,; echo "${record_ids[*]}")'],
    "analysis_type": "suggestions",
    "suggestion_types": ["immediate", "longterm", "lifestyle", "social"]
}'

test_api "个性化建议生成" "POST" "http://127.0.0.1:8000/api/v1/ai/analyze/" "$suggestion_data" "200"

# 5. 测试情绪记录相关API
echo -e "${YELLOW}5. 测试情绪记录API...${NC}"

test_api "获取最近记录" "GET" "http://127.0.0.1:8000/api/v1/emotions/records/recent/" "" "200"
test_api "获取情绪统计" "GET" "http://127.0.0.1:8000/api/v1/emotions/records/statistics/" "" "200"

# 如果有记录ID，测试获取特定记录
if [ ${#record_ids[@]} -gt 0 ]; then
    test_api "获取特定记录" "GET" "http://127.0.0.1:8000/api/v1/emotions/records/${record_ids[0]}/" "" "200"
fi

# 6. 测试前端页面功能
echo -e "${YELLOW}6. 测试前端页面访问...${NC}"

pages=(
    "http://localhost:5173/pages/analysis/index"
    "http://localhost:5173/pages/record/index" 
    "http://localhost:5173/"
)

for page in "${pages[@]}"; do
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    page_name=$(echo $page | sed 's/.*pages\///' | sed 's/\/index//' | sed 's/.*5173\//首页/')
    
    echo -e "${BLUE}测试 $TOTAL_TESTS: 访问${page_name}页面${NC}"
    
    if curl -s "$page" > /dev/null; then
        echo -e "${GREEN}✅ 通过${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}❌ 失败${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
done

# 7. 测试AI分析数据处理
echo -e "${YELLOW}7. 测试AI分析数据处理...${NC}"

# 测试不同情绪类型的分析
emotion_types=("happy" "sad" "angry" "anxious" "calm" "fearful")
for emotion in "${emotion_types[@]}"; do
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "${BLUE}测试 $TOTAL_TESTS: ${emotion}情绪分析${NC}"
    
    test_data="{\"emotion_type\":\"$emotion\",\"intensity\":6,\"scenario\":\"personal\",\"description\":\"测试${emotion}情绪的AI分析\"}"
    
    # 创建测试记录
    response=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Token $TOKEN" -d "$test_data" "http://127.0.0.1:8000/api/v1/emotions/records/")
    test_record_id=$(echo $response | grep -o '"id":[0-9]*' | sed 's/"id"://')
    
    if [ -n "$test_record_id" ]; then
        # 测试AI分析
        analysis_request="{\"emotion_records\":[$test_record_id],\"analysis_type\":\"comprehensive\"}"
        analysis_response=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Token $TOKEN" -d "$analysis_request" "http://127.0.0.1:8000/api/v1/ai/analyze/")
        
        if echo "$analysis_response" | grep -q "insights\|suggestions\|analysis"; then
            echo -e "${GREEN}✅ $emotion 情绪分析成功${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "${RED}❌ $emotion 情绪分析失败${NC}"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        echo -e "${RED}❌ $emotion 测试记录创建失败${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
done

# 8. 测试AI分析页面特定功能
echo -e "${YELLOW}8. 测试AI分析页面特定功能...${NC}"

# 测试带recordId参数的页面访问
if [ ${#record_ids[@]} -gt 0 ]; then
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "${BLUE}测试 $TOTAL_TESTS: 带recordId的分析页面${NC}"
    
    analysis_page_url="http://localhost:5173/pages/analysis/index?recordId=${record_ids[0]}"
    if curl -s "$analysis_page_url" > /dev/null; then
        echo -e "${GREEN}✅ 特定记录分析页面访问成功${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}❌ 特定记录分析页面访问失败${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
fi

# 测试AI分析结果的完整性
echo -e "${PURPLE}9. 验证AI分析结果完整性...${NC}"

if [ ${#record_ids[@]} -gt 0 ]; then
    comprehensive_analysis="{\"emotion_records\":[${record_ids[0]}],\"analysis_type\":\"comprehensive\",\"include_suggestions\":true,\"include_trend\":true}"
    
    analysis_result=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Token $TOKEN" -d "$comprehensive_analysis" "http://127.0.0.1:8000/api/v1/ai/analyze/")
    
    # 检查分析结果的关键字段
    required_fields=("insights" "suggestions" "confidence")
    for field in "${required_fields[@]}"; do
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        echo -e "${BLUE}测试 $TOTAL_TESTS: 检查分析结果包含${field}字段${NC}"
        
        if echo "$analysis_result" | grep -q "\"$field\""; then
            echo -e "${GREEN}✅ $field 字段存在${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "${RED}❌ $field 字段缺失${NC}"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    done
fi

# 输出测试结果
echo ""
echo "========================================="
echo "📊 AI分析页面测试结果统计"
echo "========================================="
echo -e "总测试数: ${BLUE}$TOTAL_TESTS${NC}"
echo -e "通过数: ${GREEN}$PASSED_TESTS${NC}"
echo -e "失败数: ${RED}$FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 所有测试通过！AI分析页面功能正常${NC}"
    echo ""
    echo -e "${PURPLE}🤖 AI分析功能验证完成：${NC}"
    echo -e "${GREEN}✅ AI分析API集成正常${NC}"
    echo -e "${GREEN}✅ 情绪数据处理正确${NC}"
    echo -e "${GREEN}✅ 分析结果格式完整${NC}"
    echo -e "${GREEN}✅ 前端页面访问正常${NC}"
    echo -e "${GREEN}✅ 多种情绪类型支持${NC}"
    exit 0
else
    success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo -e "${YELLOW}⚠️  成功率: $success_rate%${NC}"
    if [ $success_rate -ge 80 ]; then
        echo -e "${YELLOW}✨ 大部分功能正常，建议修复失败的测试项${NC}"
        echo ""
        echo -e "${YELLOW}🔧 需要关注的问题：${NC}"
        echo -e "${YELLOW}- 检查AI分析API的响应格式${NC}"
        echo -e "${YELLOW}- 验证前端与后端的数据映射${NC}"
        echo -e "${YELLOW}- 确认所有情绪类型的处理逻辑${NC}"
    else
        echo -e "${RED}❌ 存在较多问题，需要检查和修复${NC}"
        echo ""
        echo -e "${RED}🚨 主要问题：${NC}"
        echo -e "${RED}- AI分析API可能未正确实现${NC}"
        echo -e "${RED}- 前端页面可能存在访问问题${NC}"
        echo -e "${RED}- 数据处理逻辑需要检查${NC}"
    fi
    exit 1
fi 