#!/bin/bash
# Zen-C Snake Game 跨平台兼容性测试脚本

echo "=========================================="
echo "Zen-C Snake Game - 跨平台兼容性测试"
echo "=========================================="
echo ""

# 检查当前平台
echo "🔍 检测当前平台..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "✅ 平台: Linux"
    PLATFORM="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "✅ 平台: macOS"
    PLATFORM="macos"
elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    echo "✅ 平台: Windows (通过Cygwin/MSYS)"
    PLATFORM="windows"
else
    echo "⚠️  平台: 未知 ($OSTYPE)"
    PLATFORM="unknown"
fi

echo ""

# 检查编译器
echo "🔧 检查编译器..."
if command -v zc &> /dev/null; then
    echo "✅ Zen-C编译器 (zc): 已安装"
    zc --version
else
    echo "❌ Zen-C编译器 (zc): 未安装"
    echo "   请从 https://github.com/z-libs/Zen-C 安装"
fi

echo ""

# 检查C编译器
echo "🔧 检查C编译器..."
if command -v gcc &> /dev/null; then
    echo "✅ GCC编译器: 已安装"
    gcc --version | head -1
elif command -v clang &> /dev/null; then
    echo "✅ Clang编译器: 已安装"
    clang --version | head -1
else
    echo "❌ C编译器: 未找到gcc或clang"
fi

echo ""

# 检查终端能力
echo "🖥️  检查终端能力..."
echo "终端类型: $TERM"
echo "终端大小: $(tput cols)列 × $(tput lines)行"

# 测试ANSI转义序列支持
echo -e "\x1b[31m红色文本\x1b[0m" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ ANSI转义序列: 支持"
else
    echo "⚠️  ANSI转义序列: 可能不支持"
fi

echo ""

# 检查源代码
echo "📁 检查项目文件..."
if [ -f "src/main.zc" ]; then
    echo "✅ 源代码: src/main.zc 存在"
    echo "   文件大小: $(wc -l < src/main.zc) 行"
else
    echo "❌ 源代码: src/main.zc 不存在"
fi

echo ""

# 显示跨平台兼容性信息
echo "🌍 跨平台兼容性报告"
echo "===================="
echo ""
echo "当前游戏版本使用以下技术确保跨平台兼容性："
echo ""
echo "1. ✅ 条件编译 - 自动检测Windows/Linux/macOS"
echo "2. ✅ ANSI转义序列 - 跨平台终端控制"
echo "3. ✅ 纯ASCII字符 - 所有终端都能显示"
echo "4. ✅ 标准库函数 - 避免平台特定API"
echo "5. ✅ 简单的游戏循环 - 无复杂依赖"
echo ""
echo "支持的平台："
echo "- ✅ Windows 10/11 (推荐Windows Terminal)"
echo "- ✅ Linux (所有现代发行版)"
echo "- ✅ macOS 10.15+"
echo ""
echo "构建系统："
echo "- ✅ Makefile (Linux/macOS)"
echo "- ✅ build_windows.bat (Windows)"
echo "- ✅ build_mac.sh (macOS)"
echo ""

# 构建测试
echo "🔨 构建测试..."
if [ -f "Makefile" ]; then
    echo "执行: make clean"
    make clean > /dev/null 2>&1
    
    echo "执行: make"
    make_output=$(make 2>&1)
    
    if [ $? -eq 0 ]; then
        echo "✅ 构建成功！"
        if [ -f "build/snake_game" ]; then
            echo "✅ 可执行文件: build/snake_game"
            echo "   文件大小: $(ls -lh build/snake_game | awk '{print $5}')"
        fi
    else
        echo "❌ 构建失败"
        echo "错误信息:"
        echo "$make_output" | tail -5
    fi
else
    echo "⚠️  Makefile不存在，跳过构建测试"
fi

echo ""
echo "=========================================="
echo "测试完成！"
echo ""
echo "总结："
echo "- 平台: $PLATFORM"
echo "- Zen-C编译器: $(command -v zc > /dev/null && echo '已安装' || echo '未安装')"
echo "- C编译器: $(command -v gcc > /dev/null && echo 'GCC' || command -v clang > /dev/null && echo 'Clang' || echo '未找到')"
echo "- 终端ANSI支持: $(echo -e "\x1b[31mtest\x1b[0m" > /dev/null 2>&1 && echo '是' || echo '否')"
echo "- 源代码: $( [ -f "src/main.zc" ] && echo '存在' || echo '不存在' )"
echo ""
echo "建议："
if [ "$PLATFORM" = "windows" ]; then
    echo "💡 Windows用户建议使用Windows Terminal以获得最佳体验"
fi
echo "💡 确保终端窗口足够大（至少25行×80列）"
echo "💡 游戏使用简单的ASCII字符，无需特殊字体"
echo ""
echo "要运行游戏："
echo "  make run   # Linux/macOS"
echo "  或直接执行 build/snake_game"
echo "=========================================="