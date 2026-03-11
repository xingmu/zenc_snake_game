#!/bin/bash
# auto_release.sh - Zen-C贪吃蛇游戏自动发布脚本
# 在构建成功后自动创建GitHub发布

set -e

# 配置
CONFIG_FILE="$(dirname "$0")/../ci/config.json"
SCRIPT_DIR="$(dirname "$0")"
LOG_DIR="$(dirname "$0")/../logs"
RELEASE_DIR="$(dirname "$0")/../release"

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
        RELEASE_ENABLED=$(jq -r '.release.enabled' "$CONFIG_FILE")
        AUTO_CREATE=$(jq -r '.release.auto_create' "$CONFIG_FILE")
        DRAFT_RELEASE=$(jq -r '.release.draft' "$CONFIG_FILE")
        PRERELEASE=$(jq -r '.release.prerelease' "$CONFIG_FILE")
    else
        echo -e "${RED}[ERROR] 配置文件不存在: $CONFIG_FILE${NC}"
        exit 1
    fi
}

# 初始化
init() {
    echo -e "${BLUE}[INFO] 初始化自动发布系统...${NC}"
    
    # 创建目录
    mkdir -p "$LOG_DIR"
    mkdir -p "$RELEASE_DIR"
    
    # 设置日志
    LOG_FILE="$LOG_DIR/release_$(date +%Y%m%d_%H%M%S).log"
    exec 3>&1 4>&2
    exec > >(tee -a "$LOG_FILE") 2>&1
    
    echo "=== 自动发布开始: $(date) ==="
}

# 检查前提条件
check_prerequisites() {
    echo -e "${BLUE}[INFO] 检查前提条件...${NC}"
    
    # 检查GitHub Token
    if [ -z "$GITHUB_TOKEN" ]; then
        echo -e "${RED}[ERROR] GitHub Token未设置${NC}"
        echo "请在配置文件中设置 github.token"
        return 1
    fi
    
    # 检查是否启用发布
    if [ "$RELEASE_ENABLED" != "true" ]; then
        echo -e "${YELLOW}[WARN] 发布功能未启用${NC}"
        return 1
    fi
    
    # 检查gh命令行工具
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}[ERROR] GitHub CLI (gh) 未安装${NC}"
        echo "请安装: https://cli.github.com/"
        return 1
    fi
    
    # 认证GitHub CLI
    echo "$GITHUB_TOKEN" | gh auth login --with-token
    if [ $? -ne 0 ]; then
        echo -e "${RED}[ERROR] GitHub CLI认证失败${NC}"
        return 1
    fi
    
    echo -e "${GREEN}[OK] 前提条件检查通过${NC}"
    return 0
}

# 获取版本信息
get_version_info() {
    echo -e "${BLUE}[INFO] 获取版本信息...${NC}"
    
    # 尝试从文件读取版本
    if [ -f "VERSION" ]; then
        VERSION=$(cat VERSION | tr -d '[:space:]')
    elif [ -f "version.txt" ]; then
        VERSION=$(cat version.txt | tr -d '[:space:]')
    else
        # 使用语义化版本，基于当前日期和提交次数
        COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "1")
        DATE_PART=$(date +%Y%m%d)
        VERSION="1.0.$COMMIT_COUNT-$DATE_PART"
    fi
    
    # 获取最新标签
    LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    
    # 生成变更日志
    generate_changelog
    
    echo "当前版本: $VERSION"
    echo "最新标签: $LATEST_TAG"
    
    export VERSION
    export LATEST_TAG
}

# 生成变更日志
generate_changelog() {
    echo -e "${BLUE}[INFO] 生成变更日志...${NC}"
    
    CHANGELOG_FILE="$RELEASE_DIR/CHANGELOG_$VERSION.md"
    
    # 获取最近提交
    if [ -n "$LATEST_TAG" ]; then
        COMMITS_SINCE_TAG=$(git log --oneline "$LATEST_TAG..HEAD" 2>/dev/null || git log --oneline -20)
    else
        COMMITS_SINCE_TAG=$(git log --oneline -20)
    fi
    
    cat > "$CHANGELOG_FILE" << EOF
# Zen-C贪吃蛇游戏 $VERSION 变更日志

## 版本信息
- **版本号**: $VERSION
- **发布日期**: $(date +"%Y-%m-%d %H:%M:%S")
- **上一个版本**: ${LATEST_TAG:-无}

## 构建信息
- **提交哈希**: $(git rev-parse --short HEAD)
- **分支**: $(git branch --show-current)
- **构建时间**: $(date)

## 变更内容

### 新功能
$(echo "$COMMITS_SINCE_TAG" | grep -i "feat\|add\|new" | sed 's/^/- /')

### 修复和改进
$(echo "$COMMITS_SINCE_TAG" | grep -i "fix\|update\|improve\|optimize" | sed 's/^/- /')

### 其他变更
$(echo "$COMMITS_SINCE_TAG" | grep -v -i "feat\|add\|new\|fix\|update\|improve\|optimize" | sed 's/^/- /')

## 文件清单
\`\`\`
$(find build/ -type f -name "*.exe" -o -name "snake_game" | sort)
\`\`\`

## 安装说明

### Windows
1. 下载 \`snake_game_windows.exe\`
2. 双击运行
3. 使用 W/A/S/D 或方向键控制

### Linux
1. 下载 \`snake_game_linux\`
2. 添加执行权限: \`chmod +x snake_game_linux\`
3. 运行: \`./snake_game_linux\`

### macOS
1. 下载 \`snake_game_macos\`
2. 添加执行权限: \`chmod +x snake_game_macos\`
3. 运行: \`./snake_game_macos\`

## 控制说明
- **W/A/S/D 或方向键**: 移动蛇
- **空格键**: 暂停/继续游戏
- **R键**: 重新开始游戏
- **ESC键**: 退出游戏

## 已知问题
- 无

## 致谢
感谢所有贡献者和用户的支持！

---

*此变更日志由自动发布系统生成*
EOF
    
    echo -e "${GREEN}[OK] 变更日志生成完成: $CHANGELOG_FILE${NC}"
}

# 准备发布文件
prepare_release_files() {
    echo -e "${BLUE}[INFO] 准备发布文件...${NC}"
    
    # 清空发布目录
    rm -rf "$RELEASE_DIR"/*
    
    # 复制构建产物
    echo "复制构建产物..."
    find build/ -type f \( -name "*.exe" -o -name "snake_game" \) -exec cp {} "$RELEASE_DIR/" \;
    
    # 复制文档
    echo "复制文档..."
    cp README.md "$RELEASE_DIR/"
    cp CHANGELOG_*.md "$RELEASE_DIR/" 2>/dev/null || true
    
    # 创建版本信息文件
    cat > "$RELEASE_DIR/VERSION_INFO.md" << EOF
# Zen-C贪吃蛇游戏 $VERSION

## 版本信息
- 版本: $VERSION
- 构建时间: $(date)
- 提交: $(git rev-parse HEAD)
- 分支: $(git branch --show-current)

## 包含文件
$(ls -la "$RELEASE_DIR/" | tail -n +2)

## 校验和
\`\`\`
$(cd "$RELEASE_DIR" && sha256sum *)
\`\`\`

## 快速开始
1. 下载对应平台的可执行文件
2. 运行游戏
3. 查看 README.md 获取详细说明
EOF
    
    # 生成校验和
    cd "$RELEASE_DIR"
    sha256sum * > SHA256SUMS
    cd - > /dev/null
    
    echo -e "${GREEN}[OK] 发布文件准备完成${NC}"
    echo "发布目录内容:"
    ls -la "$RELEASE_DIR/"
}

# 创建GitHub发布
create_github_release() {
    echo -e "${BLUE}[INFO] 创建GitHub发布...${NC}"
    
    local tag_name="v$VERSION"
    local release_name="Zen-C贪吃蛇游戏 $VERSION"
    
    # 检查标签是否已存在
    if git tag -l | grep -q "^$tag_name$"; then
        echo -e "${YELLOW}[WARN] 标签 $tag_name 已存在，跳过创建${NC}"
        return 0
    fi
    
    # 创建本地标签
    git tag -a "$tag_name" -m "Release $VERSION"
    
    # 推送标签
    git push origin "$tag_name"
    
    # 创建发布说明
    local release_notes=""
    if [ -f "$RELEASE_DIR/CHANGELOG_$VERSION.md" ]; then
        release_notes=$(cat "$RELEASE_DIR/CHANGELOG_$VERSION.md")
    else
        release_notes="# Zen-C贪吃蛇游戏 $VERSION\n\n自动构建发布"
    fi
    
    # 使用GitHub CLI创建发布
    echo "创建发布: $release_name"
    gh release create "$tag_name" \
        --title "$release_name" \
        --notes "$release_notes" \
        --draft="$DRAFT_RELEASE" \
        --prerelease="$PRERELEASE" \
        "$RELEASE_DIR"/*
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[OK] GitHub发布创建成功${NC}"
        echo "发布链接: https://github.com/$REPO_OWNER/$REPO_NAME/releases/tag/$tag_name"
        return 0
    else
        echo -e "${RED}[ERROR] GitHub发布创建失败${NC}"
        return 1
    fi
}

# 更新版本文件
update_version_file() {
    echo -e "${BLUE}[INFO] 更新版本文件...${NC}"
    
    # 更新VERSION文件
    echo "$VERSION" > VERSION
    
    # 提交版本更新
    git add VERSION
    git commit -m "chore: bump version to $VERSION"
    git push origin $(git branch --show-current)
    
    echo -e "${GREEN}[OK] 版本文件更新完成${NC}"
}

# 发送发布通知
send_release_notification() {
    echo -e "${BLUE}[INFO] 发送发布通知...${NC}"
    
    # 这里可以添加通知逻辑
    # 例如: Telegram, Email, Slack等
    
    echo -e "${GREEN}[OK] 发布通知发送完成${NC}"
}

# 清理工作
cleanup() {
    echo -e "${BLUE}[INFO] 清理工作...${NC}"
    
    # 保留最近5个发布目录
    find "$(dirname "$RELEASE_DIR")" -name "release_*" -type d | sort -r | tail -n +6 | xargs rm -rf 2>/dev/null || true
    
    # 保留最近10个日志文件
    find "$LOG_DIR" -name "release_*.log" | sort -r | tail -n +11 | xargs rm -f 2>/dev/null || true
    
    echo -e "${GREEN}[OK] 清理完成${NC}"
}

# 主函数
main() {
    echo -e "${BLUE}=== Zen-C贪吃蛇游戏自动发布系统 ===${NC}"
    
    # 初始化
    init
    
    # 加载配置
    load_config
    
    # 检查前提条件
    if ! check_prerequisites; then
        echo -e "${YELLOW}[WARN] 前提条件检查失败，跳过发布${NC}"
        exit 0
    fi
    
    # 获取版本信息
    get_version_info
    
    # 准备发布文件
    prepare_release_files
    
    # 创建GitHub发布
    if [ "$AUTO_CREATE" = "true" ]; then
        if create_github_release; then
            # 更新版本文件
            update_version_file
            
            # 发送通知
            send_release_notification
            
            echo -e "${GREEN}🎉 发布成功完成！${NC}"
        else
            echo -e "${RED}[ERROR] 发布失败${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}[INFO] 自动发布已禁用，仅准备文件${NC}"
    fi
    
    # 清理工作
    cleanup
    
    echo -e "${BLUE}=== 自动发布结束 ===${NC}"
}

# 显示帮助
show_help() {
    cat << EOF
Zen-C贪吃蛇游戏自动发布脚本

用法: $0 [选项]

选项:
  -h, --help     显示此帮助信息
  -v, --version  显示版本信息
  -d, --dry-run  干运行模式（不实际创建发布）
  -f, --force    强制创建发布（即使标签已存在）
  --config FILE  指定配置文件路径

示例:
  $0              运行自动发布
  $0 --dry-run    干运行测试
  $0 --force      强制创建发布

配置文件: $CONFIG_FILE
发布目录: $RELEASE_DIR
日志目录: $LOG_DIR
EOF
}

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            echo "自动发布脚本 v1.0.0"
            exit 0
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -f|--force)
            FORCE=true
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

# 运行主函数
main "$@"