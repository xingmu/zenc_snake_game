#!/bin/bash

echo "========================================"
echo "  Zen-C 贪吃蛇游戏 - Linux窗体版构建脚本"
echo "========================================"
echo

# 检查是否安装了GTK开发包
if ! pkg-config --exists gtk+-3.0; then
    echo "❌ 错误: 未找到GTK3开发包"
    echo
    echo "请安装GTK3开发包:"
    echo "Ubuntu/Debian: sudo apt-get install libgtk-3-dev"
    echo "Fedora: sudo dnf install gtk3-devel"
    echo "Arch Linux: sudo pacman -S gtk3"
    echo
    exit 1
fi

echo "✅ 找到GTK3开发包"
echo

# 设置编译选项
SOURCE_FILE="src/linux/snake_game_gtk.c"
OUTPUT_FILE="build/snake_game_linux"
COMPILE_OPTIONS="-O2 -Wall -Wextra"

# 获取GTK编译选项
GTK_CFLAGS=$(pkg-config --cflags gtk+-3.0)
GTK_LIBS=$(pkg-config --libs gtk+-3.0)

# 创建构建目录
mkdir -p build

echo "🔨 正在编译Linux窗体版贪吃蛇游戏..."
echo "源文件: $SOURCE_FILE"
echo "输出文件: $OUTPUT_FILE"
echo

# 编译游戏
gcc $COMPILE_OPTIONS $GTK_CFLAGS $SOURCE_FILE -o $OUTPUT_FILE $GTK_LIBS -lm

if [ $? -ne 0 ]; then
    echo "❌ 编译失败!"
    echo "请检查错误信息"
    exit 1
fi

echo "✅ 编译成功!"
echo
echo "📁 输出文件: $OUTPUT_FILE"
echo "📏 文件大小: $(stat -c%s "$OUTPUT_FILE") 字节"
echo

# 检查依赖
echo "🔍 检查运行时依赖..."
ldd "$OUTPUT_FILE" | grep "=>"
echo

# 创建运行脚本
echo "📝 创建运行脚本..."
cat > build/run_game.sh << 'EOF'
#!/bin/bash
echo "正在启动Zen-C贪吃蛇游戏..."
echo "========================================"
./snake_game_linux
EOF
chmod +x build/run_game.sh

echo "🎮 游戏已准备就绪!"
echo
echo "运行方式:"
echo "1. 执行 ./build/run_game.sh"
echo "2. 或直接运行 ./build/snake_game_linux"
echo
echo "🎯 游戏控制:"
echo "   方向键/WASD: 移动蛇"
echo "   空格键: 暂停/继续"
echo "   R键: 重新开始"
echo "   ESC键: 退出游戏"
echo
echo "🖼️ 游戏特性:"
echo "   - 美观的GTK窗体界面"
echo "   - 平滑的Cairo图形"
echo "   - 分数和等级系统"
echo "   - 网格背景"
echo "   - 专业UI面板"
echo

# 测试运行
read -p "🧪 是否要测试运行游戏? (y/N): " TEST_RUN
if [[ $TEST_RUN =~ ^[Yy]$ ]]; then
    echo
    echo "🚀 启动游戏..."
    echo
    cd build && ./snake_game_linux &
    echo "游戏已启动!"
fi

echo
echo "========================================"
echo "   构建完成!"
echo "========================================"