#!/bin/bash
# check_ci_status.sh - CI/CD状态定时检查脚本
# 集成到心跳系统，定时检查线上编译状态

set -e

# 配置
SCRIPT_DIR="$(dirname "$0")"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$PROJECT_DIR/ci/config.json"
LOG_DIR="$PROJECT_DIR/logs"
STATUS_FILE="$PROJECT_DIR/ci/last_status.json"
HEARTBEAT_LOG="$PROJECT_DIR/../heartbeat.log"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 加载配置
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        REPO_OWNER=$(jq -r '.repo.owner' "$CONFIG_FILE")
        REPO_NAME=$(jq -r '.repo.name' "$CONFIG_FILE")
        GITHUB_TOKEN=$(jq -r '.github.token' "$CONFIG_FILE")
        CHECK_INTERVAL=$(jq -r '.monitor.check_interval_minutes' "$CONFIG_FILE")
    else
        echo -e "${YELLOW}[WARN] 配置文件不存在，使用默认配置${NC}"
        REPO_OWNER="xingmu"
        REPO_NAME="zenc_snake_game"
        GITHUB_TOKEN=""
        CHECK_INTERVAL=30
    fi
}

# 初始化
init() {
    echo -e "${BLUE}[INFO] 初始化CI状态检查...${NC}"
    
    # 创建目录
    mkdir -p "$LOG_DIR"
    mkdir -p "$(dirname "$STATUS_FILE")"
    mkdir -p "$(dirname "$HEARTBEAT_LOG")"
    
    # 当前时间戳
    TIMESTAMP=$(date +%s)
    DATE_STR=$(date +"%Y-%m-%d %H:%M:%S")
    
    echo "检查时间: $DATE_STR"
    echo "仓库: $REPO_OWNER/$REPO_NAME"
}

# 检查GitHub Actions状态
check_github_actions() {
    echo -e "${BLUE}[INFO] 检查GitHub Actions状态...${NC}"
    
    local api_url="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runs"
    local headers=""
    
    if [ -n "$GITHUB_TOKEN" ]; then
        headers="-H 'Authorization: token $GITHUB_TOKEN'"
    fi
    
    # 获取最近的工作流运行
    response=$(curl -s -H "Accept: application/vnd.github.v3+json" $headers \
        "$api_url?per_page=5&status=completed" || echo "ERROR")
    
    if [[ "$response" == *"ERROR"* ]]; then
        echo -e "${RED}[ERROR] 获取GitHub Actions状态失败${NC}"
        return 1
    fi
    
    # 解析响应
    echo "$response" | jq '.workflow_runs[] | {id, name, status, conclusion, created_at, html_url}' > /tmp/gh_actions.json
    
    # 统计状态
    total_runs=$(echo "$response" | jq '.workflow_runs | length')
    success_runs=$(echo "$response" | jq '[.workflow_runs[] | select(.conclusion == "success")] | length')
    failure_runs=$(echo "$response" | jq '[.workflow_runs[] | select(.conclusion == "failure")] | length')
    
    echo "最近工作流运行:"
    echo "  总计: $total_runs"
    echo "  成功: $success_runs"
    echo "  失败: $failure_runs"
    
    # 检查最新的构建工作流
    latest_build=$(echo "$response" | jq '[.workflow_runs[] | select(.name == "Zen-C Snake Game CI/CD")] | .[0]')
    
    if [ "$latest_build" != "null" ]; then
        build_id=$(echo "$latest_build" | jq -r '.id')
        build_status=$(echo "$latest_build" | jq -r '.conclusion')
        build_url=$(echo "$latest_build" | jq -r '.html_url')
        build_time=$(echo "$latest_build" | jq -r '.created_at')
        
        echo "最新构建:"
        echo "  ID: $build_id"
        echo "  状态: $build_status"
        echo "  时间: $build_time"
        echo "  链接: $build_url"
        
        # 获取构建作业详情
        check_build_jobs "$build_id"
    fi
    
    return 0
}

# 检查构建作业
check_build_jobs() {
    local run_id="$1"
    
    echo -e "${BLUE}[INFO] 检查构建作业详情...${NC}"
    
    local api_url="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runs/$run_id/jobs"
    local headers=""
    
    if [ -n "$GITHUB_TOKEN" ]; then
        headers="-H 'Authorization: token $GITHUB_TOKEN'"
    fi
    
    response=$(curl -s -H "Accept: application/vnd.github.v3+json" $headers "$api_url" || echo "ERROR")
    
    if [[ "$response" != *"ERROR"* ]]; then
        jobs=$(echo "$response" | jq '.jobs[] | {name, status, conclusion, started_at, completed_at}')
        
        echo "构建作业:"
        echo "$jobs" | jq -r '. | "  - \(.name): \(.conclusion) (\(.started_at) → \(.completed_at))"'
        
        # 检查各平台构建状态
        check_platform_status "$response"
    fi
}

# 检查各平台构建状态
check_platform_status() {
    local jobs_json="$1"
    
    echo -e "${BLUE}[INFO] 检查各平台构建状态...${NC}"
    
    # 初始化状态
    windows_status="❓"
    linux_status="❓"
    macos_status="❓"
    
    # 检查Windows构建
    if echo "$jobs_json" | jq -e '.jobs[] | select(.name | contains("Windows"))' > /dev/null; then
        windows_job=$(echo "$jobs_json" | jq '[.jobs[] | select(.name | contains("Windows"))] | .[0]')
        windows_conclusion=$(echo "$windows_job" | jq -r '.conclusion')
        
        if [ "$windows_conclusion" = "success" ]; then
            windows_status="✅"
        elif [ "$windows_conclusion" = "failure" ]; then
            windows_status="❌"
        else
            windows_status="⚠️"
        fi
    fi
    
    # 检查Linux构建
    if echo "$jobs_json" | jq -e '.jobs[] | select(.name | contains("Linux"))' > /dev/null; then
        linux_job=$(echo "$jobs_json" | jq '[.jobs[] | select(.name | contains("Linux"))] | .[0]')
        linux_conclusion=$(echo "$linux_job" | jq -r '.conclusion')
        
        if [ "$linux_conclusion" = "success" ]; then
            linux_status="✅"
        elif [ "$linux_conclusion" = "failure" ]; then
            linux_status="❌"
        else
            linux_status="⚠️"
        fi
    fi
    
    # 检查macOS构建
    if echo "$jobs_json" | jq -e '.jobs[] | select(.name | contains("macOS"))' > /dev/null; then
        macos_job=$(echo "$jobs_json" | jq '[.jobs[] | select(.name | contains("macOS"))] | .[0]')
        macos_conclusion=$(echo "$macos_job" | jq -r '.conclusion')
        
        if [ "$macos_conclusion" = "success" ]; then
            macos_status="✅"
        elif [ "$macos_conclusion" = "failure" ]; then
            macos_status="❌"
        else
            macos_status="⚠️"
        fi
    fi
    
    echo "平台构建状态:"
    echo "  🪟 Windows: $windows_status"
    echo "  🐧 Linux: $linux_status"
    echo "  🍎 macOS: $macos_status"
}

# 检查发布状态
check_release_status() {
    echo -e "${BLUE}[INFO] 检查发布状态...${NC}"
    
    local api_url="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest"
    local headers=""
    
    if [ -n "$GITHUB_TOKEN" ]; then
        headers="-H 'Authorization: token $GITHUB_TOKEN'"
    fi
    
    response=$(curl -s -H "Accept: application/vnd.github.v3+json" $headers "$api_url" || echo "ERROR")
    
    if [[ "$response" != *"ERROR"* ]] && [[ "$response" != *"Not Found"* ]]; then
        latest_release=$(echo "$response" | jq -r '.tag_name // "无"')
        release_date=$(echo "$response" | jq -r '.published_at // "未知"')
        release_url=$(echo "$response" | jq -r '.html_url // ""')
        
        echo "最新发布:"
        echo "  版本: $latest_release"
        echo "  时间: $release_date"
        if [ -n "$release_url" ]; then
            echo "  链接: $release_url"
        fi
    else
        echo "最新发布: 无"
    fi
}

# 检查构建产物
check_artifacts() {
    echo -e "${BLUE}[INFO] 检查构建产物...${NC}"
    
    # 检查本地构建目录
    if [ -d "$PROJECT_DIR/build" ]; then
        echo "本地构建产物:"
        find "$PROJECT_DIR/build" -type f \( -name "*.exe" -o -name "snake_game" \) | while read -r file; do
            size=$(du -h "$file" | cut -f1)
            mtime=$(stat -c "%y" "$file" | cut -d' ' -f1)
            echo "  - $(basename "$file") ($size, $mtime)"
        done
    else
        echo "本地构建目录不存在"
    fi
}

# 生成状态报告
generate_status_report() {
    echo -e "${BLUE}[INFO] 生成状态报告...${NC}"
    
    local report_file="$LOG_DIR/ci_status_$(date +%Y%m%d_%H%M%S).md"
    
    cat > "$report_file" << EOF
# CI/CD状态报告

## 报告信息
- 生成时间: $DATE_STR
- 仓库: $REPO_OWNER/$REPO_NAME
- 检查间隔: ${CHECK_INTERVAL}分钟

## GitHub Actions状态
- 最近运行: $total_runs 次
- 成功: $success_runs 次
- 失败: $failure_runs 次

## 平台构建状态
- 🪟 Windows: $windows_status
- 🐧 Linux: $linux_status  
- 🍎 macOS: $macos_status

## 发布状态
- 最新版本: $latest_release
- 发布时间: $release_date

## 构建产物
$(find "$PROJECT_DIR/build" -type f \( -name "*.exe" -o -name "snake_game" \) 2>/dev/null | while read -r file; do
    size=\$(du -h "\$file" | cut -f1)
    mtime=\$(stat -c "%y" "\$file" | cut -d' ' -f1)
    echo "- \$(basename "\$file") (\$size, \$mtime)"
done || echo "无")

## 建议
1. 定期检查构建失败原因
2. 优化构建缓存策略
3. 监控构建时间和资源使用
4. 及时处理构建失败

## 日志文件
- 状态报告: $report_file
- 上次状态: $STATUS_FILE

---

*报告生成时间: $DATE_STR*
EOF
    
    echo -e "${GREEN}[OK] 状态报告生成完成: $report_file${NC}"
    
    # 保存状态到文件
    cat > "$STATUS_FILE" << EOF
{
  "timestamp": $TIMESTAMP,
  "date": "$DATE_STR",
  "repository": "$REPO_OWNER/$REPO_NAME",
  "workflow_runs": {
    "total": $total_runs,
    "success": $success_runs,
    "failure": $failure_runs
  },
  "platform_status": {
    "windows": "$windows_status",
    "linux": "$linux_status",
    "macos": "$macos_status"
  },
  "latest_release": "$latest_release",
  "report_file": "$report_file"
}
EOF
}

# 记录到心跳日志
log_to_heartbeat() {
    echo -e "${BLUE}[INFO] 记录到心跳日志...${NC}"
    
    local status_emoji="✅"
    if [ "$failure_runs" -gt 0 ]; then
        status_emoji="⚠️"
    fi
    
    cat >> "$HEARTBEAT_LOG" << EOF
## CI/CD状态检查 - $DATE_STR
- **状态**: $status_emoji $(if [ "$failure_runs" -gt 0 ]; then echo "有失败构建"; else echo "正常"; fi)
- **最近运行**: $total_runs 次 ($success_runs 成功, $failure_runs 失败)
- **平台状态**: Windows$windows_status Linux$linux_status macOS$macos_status
- **最新发布**: $latest_release
- **报告文件**: $report_file
EOF
    
    echo -e "${GREEN}[OK] 心跳日志记录完成${NC}"
}

# 发送通知（如果需要）
send_notification() {
    echo -e "${BLUE}[INFO] 检查是否需要发送通知...${NC}"
    
    # 这里可以添加通知逻辑
    # 例如：如果有失败构建，发送Telegram通知
    
    if [ "$failure_runs" -gt 0 ]; then
        echo -e "${YELLOW}[WARN] 检测到失败构建，建议发送通知${NC}"
        # send_telegram_notification "构建失败: $failure_runs 次失败构建"
    fi
}

# 主函数
main() {
    echo -e "${BLUE}=== CI/CD状态定时检查 ===${NC}"
    
    # 加载配置
    load_config
    
    # 初始化
    init
    
    # 检查GitHub Actions状态
    if check_github_actions; then
        # 检查发布状态
        check_release_status
        
        # 检查构建产物
        check_artifacts
        
        # 生成状态报告
        generate_status_report
        
        # 记录到心跳日志
        log_to_heartbeat
        
        # 发送通知
        send_notification
        
        echo -e "${GREEN}✅ CI/CD状态检查完成${NC}"
    else
        echo -e "${RED}❌ CI/CD状态检查失败${NC}"
        return 1
    fi
    
    echo -e "${BLUE}=== 检查结束 ===${NC}"
}

# 显示帮助
show_help() {
    cat << EOF
CI/CD状态定时检查脚本

用法: $0 [选项]

选项:
  -h, --help     显示此帮助信息
  -c, --config   指定配置文件路径
  -l, --log      指定日志目录
  -q, --quiet    安静模式（减少输出）

示例:
  $0              运行状态检查
  $0 --config /path/to/config.json  使用指定配置
  $0 --quiet      安静模式运行

集成到心跳系统:
  将此脚本添加到心跳系统的定时任务中，
  例如每30分钟运行一次。
EOF
}

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -l|--log)
            LOG_DIR="$2"
            shift 2
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        *)
            echo -e "${RED}[ERROR] 未知选项: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# 运行主函数
main "$@"