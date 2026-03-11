#!/bin/bash

# 窗体版本贪吃蛇游戏 - 项目管理脚本
# 自动构建和测试三个平台版本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查平台
check_platform() {
    case "$(uname -s)" in
        Linux*)     PLATFORM="Linux";;
        Darwin*)    PLATFORM="macOS";;
        CYGWIN*|MINGW*|MSYS*) PLATFORM="Windows";;
        *)          PLATFORM="Unknown";;
    esac
    log_info "检测到平台: $PLATFORM"
}

# 检查依赖
check_dependencies() {
    log_info "检查系统依赖..."
    
    case "$PLATFORM" in
        Linux)
            if command -v gcc &> /dev/null; then
                log_success "找到GCC编译器"
            else
                log_error "未找到GCC编译器"
                return 1
            fi
            
            if pkg-config --exists gtk+-3.0; then
                log_success "找到GTK3开发包"
            else
                log_warning "未找到GTK3开发包，Linux版本需要GTK3"
            fi
            ;;
            
        macOS)
            if command -v clang &> /dev/null; then
                log_success "找到Clang编译器"
            else
                log_error "未找到Clang编译器"
                return 1
            fi
            
            if xcode-select -p &> /dev/null; then
                log_success "找到Xcode命令行工具"
            else
                log_warning "未找到Xcode命令行工具，macOS版本需要Xcode"
            fi
            ;;
            
        Windows)
            if command -v gcc &> /dev/null; then
                log_success "找到MinGW GCC编译器"
            else
                log_warning "未找到MinGW GCC编译器，Windows版本需要MinGW"
            fi
            ;;
    esac
    
    return 0
}

# 构建当前平台版本
build_current_platform() {
    log_info "构建当前平台版本..."
    
    case "$PLATFORM" in
        Linux)
            if [ -f "build_linux_window.sh" ]; then
                chmod +x build_linux_window.sh
                ./build_linux_window.sh
            else
                log_error "未找到Linux构建脚本"
                return 1
            fi
            ;;
            
        macOS)
            if [ -f "build_macos_window.sh" ]; then
                chmod +x build_macos_window.sh
                ./build_macos_window.sh
            else
                log_error "未找到macOS构建脚本"
                return 1
            fi
            ;;
            
        Windows)
            if [ -f "build_windows_window.bat" ]; then
                cmd //c build_windows_window.bat
            else
                log_error "未找到Windows构建脚本"
                return 1
            fi
            ;;
            
        *)
            log_error "不支持的平台: $PLATFORM"
            return 1
            ;;
    esac
    
    return 0
}

# 验证构建结果
verify_build() {
    log_info "验证构建结果..."
    
    case "$PLATFORM" in
        Linux)
            if [ -f "build/snake_game_linux" ]; then
                log_success "Linux版本构建成功: build/snake_game_linux"
                file build/snake_game_linux
            else
                log_error "Linux版本构建失败"
                return 1
            fi
            ;;
            
        macOS)
            if [ -f "build/snake_game_macos.app/Contents/MacOS/snake_game_macos" ]; then
                log_success "macOS版本构建成功: build/snake_game_macos.app"
                file build/snake_game_macos.app/Contents/MacOS/snake_game_macos
            else
                log_error "macOS版本构建失败"
                return 1
            fi
            ;;
            
        Windows)
            if [ -f "build/snake_game_win32.exe" ]; then
                log_success "Windows版本构建成功: build/snake_game_win32.exe"
                # Windows环境下无法使用file命令
            else
                log_error "Windows版本构建失败"
                return 1
            fi
            ;;
    esac
    
    return 0
}

# 生成项目报告
generate_report() {
    log_info "生成项目报告..."
    
    REPORT_FILE="window_version_report_$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$REPORT_FILE" << EOF
# 窗体版本贪吃蛇游戏 - 项目报告
生成时间: $(date)
平台: $PLATFORM

## 项目状态
$(if [ -f "src/core/game_logic.zc" ]; then echo "✅ 核心游戏逻辑: 已实现"; else echo "❌ 核心游戏逻辑: 缺失"; fi)
$(if [ -f "src/windows/snake_game_win32.c" ]; then echo "✅ Windows版本: 已实现"; else echo "❌ Windows版本: 缺失"; fi)
$(if [ -f "src/linux/snake_game_gtk.c" ]; then echo "✅ Linux版本: 已实现"; else echo "❌ Linux版本: 缺失"; fi)
$(if [ -f "src/macos/snake_game_cocoa.m" ]; then echo "✅ macOS版本: 已实现"; else echo "❌ macOS版本: 缺失"; fi)

## 构建脚本
$(if [ -f "build_windows_window.bat" ]; then echo "✅ Windows构建脚本: 已创建"; else echo "❌ Windows构建脚本: 缺失"; fi)
$(if [ -f "build_linux_window.sh" ]; then echo "✅ Linux构建脚本: 已创建"; else echo "❌ Linux构建脚本: 缺失"; fi)
$(if [ -f "build_macos_window.sh" ]; then echo "✅ macOS构建脚本: 已创建"; else echo "❌ macOS构建脚本: 缺失"; fi)

## 文档
$(if [ -f "README_WINDOW_VERSIONS.md" ]; then echo "✅ 窗体版本文档: 已创建"; else echo "❌ 窗体版本文档: 缺失"; fi)
$(if [ -f "WINDOW_ARCHITECTURE.md" ]; then echo "✅ 架构设计文档: 已创建"; else echo "❌ 架构设计文档: 缺失"; fi)

## 当前平台构建状态
平台: $PLATFORM
构建时间: $(date)
构建结果: $(if verify_build &>/dev/null; then echo "✅ 成功"; else echo "❌ 失败"; fi)

## 文件统计
$(find src -type f -name "*.zc" -o -name "*.c" -o -name "*.m" | wc -l) 个源代码文件
$(find . -name "*.md" -o -name "*.txt" | wc -l) 个文档文件
$(find build -type f 2>/dev/null | wc -l) 个构建文件

## 下一步建议
1. 测试其他平台版本
2. 添加自动化测试
3. 创建发布包
4. 更新用户文档

EOF
    
    log_success "报告已生成: $REPORT_FILE"
    cat "$REPORT_FILE"
}

# 主函数
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  窗体版本贪吃蛇游戏 - 项目管理脚本${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    # 检查平台
    check_platform
    
    # 检查依赖
    if ! check_dependencies; then
        log_warning "部分依赖缺失，但继续执行..."
    fi
    
    # 构建当前平台版本
    if build_current_platform; then
        log_success "构建成功!"
    else
        log_error "构建失败"
        exit 1
    fi
    
    # 验证构建结果
    if verify_build; then
        log_success "验证通过!"
    else
        log_error "验证失败"
        exit 1
    fi
    
    # 生成报告
    generate_report
    
    echo
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  项目管理完成!${NC}"
    echo -e "${GREEN}========================================${NC}"
}

# 执行主函数
main "$@"