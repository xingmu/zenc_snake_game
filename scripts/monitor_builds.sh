#!/bin/bash
# monitor_builds.sh - Zen-C贪吃蛇游戏编译状态监控脚本
# 定时检查GitHub Actions编译日志和状态

set -e

# 配置
CONFIG_FILE="$(dirname "$0")/../ci/config.json"
LOG_DIR="$(dirname "$0")/../logs"
REPORT_DIR="$(dirname "$0")/../reports"
MAX_RETRIES=3
RETRY_DELAY=5

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 加载配置
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        REPO_OWNER=$(jq -r '.repo.owner' "$CONFIG_FILE")
        REPO_NAME=$(jq -r '.repo.name' "$CONFIG_FILE")
        GITHUB_TOKEN=$(jq -r '.github.token' "$CONFIG_FILE")
        CHECK_INTERVAL=$(jq -r '.monitor.check_interval_minutes' "$CONFIG_FILE")
        MAX_BUILDS=$(jq -r '.monitor.max_builds_to_check' "$CONFIG_FILE")
        NOTIFY_ENABLED=$(jq -r '.notify.enabled' "$CONFIG_FILE")
    else
        # 默认配置
        REPO_OWNER="xingmu"
        REPO_NAME="zenc_snake_game"
        GITHUB_TOKEN=""
        CHECK_INTERVAL=30
        MAX_BUILDS=10
        NOTIFY_ENABLED=false
    fi
}

# 创建目录
create_dirs() {
    mkdir -p "$LOG_DIR"
    mkdir -p "$REPORT_DIR"
    mkdir -p "$(dirname "$0")/../ci"
}

# 初始化日志
init_log() {
    LOG_FILE="$LOG_DIR/monitor_$(date +%Y%m%d_%H%M%S).log"
    exec 3>&1 4>&2
    exec > >(tee -a "$LOG_FILE") 2>&1
    echo "=== 编译监控开始: $(date) ==="
}

# 检查GitHub API可用性
check_github_api() {
    echo -e "${BLUE}[INFO] 检查GitHub API连接...${NC}"
    
    if [ -z "$GITHUB_TOKEN" ]; then
        echo -e "${YELLOW}[WARN] GitHub Token未设置，使用匿名访问（可能受限）${NC}"
        AUTH_HEADER=""
    else
        AUTH_HEADER="-H 'Authorization: token $GITHUB_TOKEN'"
    fi
    
    # 测试API连接
    response=$(curl -s -H "Accept: application/vnd.github.v3+json" $AUTH_HEADER \
        "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME" || echo "ERROR")
    
    if [[ "$response" == *"ERROR"* ]] || [[ "$response" == *"Not Found"* ]]; then
        echo -e "${RED}[ERROR] GitHub API连接失败${NC}"
        return 1
    else
        echo -e "${GREEN}[OK] GitHub API连接成功${NC}"
        return 0
    fi
}

# 获取工作流运行列表
get_workflow_runs() {
    echo -e "${BLUE}[INFO] 获取最近的工作流运行...${NC}"
    
    local url="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runs"
    local params="?per_page=$MAX_BUILDS&status=completed"
    
    response=$(curl -s -H "Accept: application/vnd.github.v3+json" $AUTH_HEADER "$url$params")
    
    if [ $? -eq 0 ]; then
        echo "$response" | jq '.workflow_runs[] | {id, name, status, conclusion, created_at, updated_at, html_url}'
        return 0
    else
        echo -e "${RED}[ERROR] 获取工作流运行失败${NC}"
        return 1
    fi
}

# 获取特定工作流的运行
get_specific_workflow_runs() {
    local workflow_id="$1"
    echo -e "${BLUE}[INFO] 获取工作流 $workflow_id 的运行...${NC}"
    
    local url="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/workflows/$workflow_id/runs"
    local params="?per_page=$MAX_BUILDS"
    
    response=$(curl -s -H "Accept: application/vnd.github.v3+json" $AUTH_HEADER "$url$params")
    
    if [ $? -eq 0 ]; then
        echo "$response" | jq '.workflow_runs[] | {id, run_number, status, conclusion, created_at, updated_at, html_url}'
        return 0
    else
        echo -e "${RED}[ERROR] 获取工作流运行失败${NC}"
        return 1
    fi
}

# 获取工作流运行详情
get_workflow_run_details() {
    local run_id="$1"
    echo -e "${BLUE}[INFO] 获取运行 $run_id 的详情...${NC}"
    
    local url="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runs/$run_id"
    
    response=$(curl -s -H "Accept: application/vnd.github.v3+json" $AUTH_HEADER "$url")
    
    if [ $? -eq 0 ]; then
        echo "$response" | jq '. | {id, name, status, conclusion, created_at, updated_at, html_url, head_sha, head_branch, event}'
        return 0
    else
        echo -e "${RED}[ERROR] 获取运行详情失败${NC}"
        return 1
    fi
}

# 获取工作流运行日志
get_workflow_run_logs() {
    local run_id="$1"
    echo -e "${BLUE}[INFO] 获取运行 $run_id 的日志...${NC}"
    
    local url="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runs/$run_id/logs"
    local log_file="$LOG_DIR/run_${run_id}_logs.zip"
    
    # 下载日志
    curl -s -L -H "Accept: application/vnd.github.v3+json" $AUTH_HEADER "$url" -o "$log_file"
    
    if [ $? -eq 0 ] && [ -f "$log_file" ]; then
        echo -e "${GREEN}[OK] 日志下载成功: $log_file${NC}"
        
        # 解压日志
        local extract_dir="$LOG_DIR/run_${run_id}_logs"
        mkdir -p "$extract_dir"
        unzip -q "$log_file" -d "$extract_dir"
        
        # 分析日志
        analyze_logs "$extract_dir"
        
        return 0
    else
        echo -e "${RED}[ERROR] 下载日志失败${NC}"
        return 1
    fi
}

# 分析日志文件
analyze_logs() {
    local log_dir="$1"
    echo -e "${BLUE}[INFO] 分析日志文件...${NC}"
    
    # 查找所有日志文件
    find "$log_dir" -name "*.txt" -o -name "*.log" | while read -r log_file; do
        echo -e "\n分析文件: $(basename "$log_file")"
        
        # 检查错误
        error_count=$(grep -i -c "error\|failed\|failure\|exception\|segmentation" "$log_file" || true)
        warning_count=$(grep -i -c "warning\|deprecated" "$log_file" || true)
        
        if [ "$error_count" -gt 0 ]; then
            echo -e "${RED}  发现 $error_count 个错误${NC}"
            grep -i "error\|failed\|failure" "$log_file" | head -5
        fi
        
        if [ "$warning_count" -gt 0 ]; then
            echo -e "${YELLOW}  发现 $warning_count 个警告${NC}"
            grep -i "warning\|deprecated" "$log_file" | head -3
        fi
        
        # 检查成功消息
        success_count=$(grep -i -c "success\|passed\|completed" "$log_file" || true)
        if [ "$success_count" -gt 0 ]; then
            echo -e "${GREEN}  发现 $success_count 个成功消息${NC}"
        fi
    done
}

# 获取工作流作业
get_workflow_jobs() {
    local run_id="$1"
    echo -e "${BLUE}[INFO] 获取运行 $run_id 的作业...${NC}"
    
    local url="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runs/$run_id/jobs"
    
    response=$(curl -s -H "Accept: application/vnd.github.v3+json" $AUTH_HEADER "$url")
    
    if [ $? -eq 0 ]; then
        echo "$response" | jq '.jobs[] | {id, name, status, conclusion, started_at, completed_at, html_url}'
        return 0
    else
        echo -e "${RED}[ERROR] 获取作业失败${NC}"
        return 1
    fi
}

# 生成监控报告
generate_monitor_report() {
    echo -e "${BLUE}[INFO] 生成监控报告...${NC}"
    
    local report_file="$REPORT_DIR/monitor_report_$(date +%Y%m%d_%H%M%S).md"
    
    cat > "$report_file" << EOF
# Zen-C贪吃蛇游戏编译监控报告

## 报告信息
- 生成时间: $(date)
- 仓库: $REPO_OWNER/$REPO_NAME
- 检查间隔: ${CHECK_INTERVAL}分钟
- 检查数量: 最近 $MAX_BUILDS 次构建

## GitHub API状态
- 连接状态: $(if check_github_api; then echo "✅ 正常"; else echo "❌ 异常"; fi)
- 认证方式: $(if [ -z "$GITHUB_TOKEN" ]; then echo "匿名"; else echo "Token认证"; fi)

## 最近工作流运行

EOF
    
    # 获取工作流运行并添加到报告
    runs=$(get_workflow_runs 2>/dev/null || echo "获取失败")
    if [ "$runs" != "获取失败" ]; then
        echo "$runs" | jq -r '.[] | "### \(.name)\n- ID: \(.id)\n- 状态: \(.status)\n- 结果: \(.conclusion)\n- 创建时间: \(.created_at)\n- 更新时间: \(.updated_at)\n- 链接: \(.html_url)\n"' >> "$report_file"
    else
        echo "获取工作流运行失败" >> "$report_file"
    fi
    
    # 添加统计信息
    cat >> "$report_file" << EOF

## 统计信息
- 成功构建: $(echo "$runs" | jq -r 'select(.conclusion == "success") | .id' | wc -l)
- 失败构建: $(echo "$runs" | jq -r 'select(.conclusion == "failure") | .id' | wc -l)
- 取消构建: $(echo "$runs" | jq -r 'select(.conclusion == "cancelled") | .id' | wc -l)
- 跳过构建: $(echo "$runs" | jq -r 'select(.conclusion == "skipped") | .id' | wc -l)

## 建议
1. 定期检查构建失败的原因
2. 优化构建缓存策略
3. 设置构建失败通知
4. 监控构建时间和资源使用

## 日志文件
- 监控日志: $LOG_FILE
- 报告文件: $report_file

---

*报告生成时间: $(date)*
EOF
    
    echo -e "${GREEN}[OK] 报告生成完成: $report_file${NC}"
    cat "$report_file"
}

# 发送通知
send_notification() {
    if [ "$NOTIFY_ENABLED" = "true" ]; then
        echo -e "${BLUE}[INFO] 发送通知...${NC}"
        
        # 这里可以添加Telegram、Email、Slack等通知逻辑
        # 例如:
        # send_telegram_notification "$message"
        # send_email_notification "$subject" "$body"
        
        echo -e "${GREEN}[OK] 通知发送完成${NC}"
    fi
}

# 主监控循环
monitor_loop() {
    echo -e "${BLUE}[INFO] 开始监控循环，间隔 ${CHECK_INTERVAL} 分钟${NC}"
    
    while true; do
        echo -e "\n${BLUE}=== 监控检查: $(date) ===${NC}"
        
        # 检查API连接
        if ! check_github_api; then
            echo -e "${RED}[ERROR] API连接失败，等待重试...${NC}"
            sleep 60
            continue
        fi
        
        # 获取工作流运行
        echo -e "${BLUE}[INFO] 获取工作流运行状态...${NC}"
        get_workflow_runs
        
        # 获取特定工作流（build.yml）的运行
        echo -e "${BLUE}[INFO] 获取构建工作流状态...${NC}"
        get_specific_workflow_runs "build.yml"
        
        # 生成报告
        generate_monitor_report
        
        # 发送通知
        send_notification
        
        echo -e "${GREEN}[OK] 监控检查完成，等待 ${CHECK_INTERVAL} 分钟...${NC}"
        sleep $((CHECK_INTERVAL * 60))
    done
}

# 单次检查模式
single_check() {
    echo -e "${BLUE}[INFO] 执行单次检查...${NC}"
    
    load_config
    create_dirs
    init_log
    
    if check_github_api; then
        get_workflow_runs
        generate_monitor_report
        echo -e "${GREEN}[OK] 单次检查完成${NC}"
    else
        echo -e "${RED}[ERROR] 单次检查失败${NC}"
        return 1
    fi
}

# 详细检查特定运行
detailed_check() {
    local run_id="$1"
    
    if [ -z "$run_id" ]; then
        echo -e "${RED}[ERROR] 请提供运行ID${NC}"
        return 1
    fi
    
    echo -e "${BLUE}[INFO] 详细检查运行 $run_id ...${NC}"
    
    load_config
    create_dirs
    init_log
    
    if check_github_api; then
        get_workflow_run_details "$run_id"
        get_workflow_jobs "$run_id"
        get_workflow_run_logs "$run_id"
        echo -e "${GREEN}[OK] 详细检查完成${NC}"
    else
        echo -e "${RED}[ERROR] 详细检查失败${NC}"
        return 1
    fi
}

# 显示帮助
show_help() {
    cat << EOF
Zen-C贪吃蛇游戏编译监控脚本

用法: $0 [选项]

选项:
  -h, --help          显示此帮助信息
  -c, --check         执行单次检查
  -d, --detailed ID   详细检查特定运行ID
  -m, --monitor       启动监控循环
  -r, --report        生成监控报告
  --config FILE       指定配置文件路径

示例:
  $0 -c               执行单次检查
  $0 -d 1234567890    详细检查运行ID 1234567890
  $0 -m               启动监控循环
  $0 --config /path/to/config.json 使用指定配置文件

配置文件格式 (JSON):
{
  "repo": {
    "owner": "xingmu",
    "name": "zenc_snake_game"
  },
  "github": {
    "token": "your_github_token"
  },
  "monitor": {
    "check_interval_minutes": 30,
    "max_builds_to_check": 10
  },
  "notify": {
    "enabled": false,
    "telegram": {
      "bot_token": "",
      "chat_id": ""
    }
  }
}
EOF
}

# 主函数
main() {
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--check)
                MODE="check"
                shift
                ;;
            -d|--detailed)
                MODE="detailed"
                RUN_ID="$2"
                shift 2
                ;;
            -m|--monitor)
                MODE="monitor"
                shift
                ;;
            -r|--report)
                MODE="report"
                shift
                ;;
            --config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            *)
                echo -e "${RED}[ERROR] 未知选项: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 默认模式
    if [ -z "$MODE" ]; then
        MODE="check"
    fi
    
    # 执行对应模式
    case "$MODE" in
        check)
            single_check
            ;;
        detailed)
            detailed_check "$RUN_ID"
            ;;
        monitor)
            load_config
            create_dirs
            init_log
            monitor_loop
            ;;
        report)
            load_config
            create_dirs
            init_log
            generate_monitor_report
            ;;
    esac
}

# 运行主函数
main "$@"