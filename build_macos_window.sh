#!/bin/bash

echo "========================================"
echo "  Zen-C 贪吃蛇游戏 - macOS窗体版构建脚本"
echo "========================================"
echo

# 检查是否在macOS上运行
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ 错误: 此脚本只能在macOS上运行"
    echo
    exit 1
fi

# 检查是否安装了Xcode命令行工具
if ! xcode-select -p &>/dev/null; then
    echo "❌ 错误: 未找到Xcode命令行工具"
    echo
    echo "请安装Xcode命令行工具:"
    echo "xcode-select --install"
    echo
    exit 1
fi

echo "✅ 找到Xcode命令行工具"
echo

# 设置编译选项
SOURCE_FILE="src/macos/snake_game_cocoa.m"
OUTPUT_FILE="build/snake_game_macos.app/Contents/MacOS/snake_game_macos"
APP_BUNDLE="build/snake_game_macos.app"

# 创建构建目录
mkdir -p build/snake_game_macos.app/Contents/MacOS
mkdir -p build/snake_game_macos.app/Contents/Resources

echo "🔨 正在编译macOS窗体版贪吃蛇游戏..."
echo "源文件: $SOURCE_FILE"
echo "输出文件: $OUTPUT_FILE"
echo

# 编译游戏
clang -framework Cocoa -framework Foundation -O2 -Wall -Wextra \
    "$SOURCE_FILE" -o "$OUTPUT_FILE"

if [ $? -ne 0 ]; then
    echo "❌ 编译失败!"
    echo "请检查错误信息"
    exit 1
fi

echo "✅ 编译成功!"
echo

# 创建应用包结构
echo "📦 创建应用包..."
cat > build/snake_game_macos.app/Contents/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Zen-C Snake Game</string>
    <key>CFBundleDisplayName</key>
    <string>Zen-C 贪吃蛇游戏</string>
    <key>CFBundleIdentifier</key>
    <string>com.zenc.snakegame</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleExecutable</key>
    <string>snake_game_macos</string>
    <key>CFBundleIconFile</key>
    <string></string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026 Zen-C Snake Game. All rights reserved.</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

echo "📁 应用包: $APP_BUNDLE"
echo "📏 可执行文件大小: $(stat -f%z "$OUTPUT_FILE") 字节"
echo

# 创建运行脚本
echo "📝 创建运行脚本..."
cat > build/run_game.sh << 'EOF'
#!/bin/bash
echo "正在启动Zen-C贪吃蛇游戏..."
echo "========================================"
open build/snake_game_macos.app
EOF
chmod +x build/run_game.sh

cat > build/run_direct.sh << 'EOF'
#!/bin/bash
echo "直接运行游戏..."
echo "========================================"
./snake_game_macos.app/Contents/MacOS/snake_game_macos
EOF
chmod +x build/run_direct.sh

echo "🎮 游戏已准备就绪!"
echo
echo "运行方式:"
echo "1. 双击 build/snake_game_macos.app"
echo "2. 或执行 ./build/run_game.sh"
echo "3. 或执行 ./build/run_direct.sh"
echo
echo "🎯 游戏控制:"
echo "   方向键/WASD: 移动蛇"
echo "   空格键: 暂停/继续"
echo "   R键: 重新开始"
echo "   ESC键: 退出游戏"
echo
echo "🖼️ 游戏特性:"
echo "   - 原生macOS Cocoa界面"
echo "   - 平滑的Core Graphics渲染"
echo "   - 分数和等级系统"
echo "   - 网格背景"
echo "   - 专业UI面板"
echo "   - 应用包格式，可直接分发"
echo

# 测试运行
read -p "🧪 是否要测试运行游戏? (y/N): " TEST_RUN
if [[ $TEST_RUN =~ ^[Yy]$ ]]; then
    echo
    echo "🚀 启动游戏..."
    echo
    open "$APP_BUNDLE"
    echo "游戏已启动!"
fi

echo
echo "========================================"
echo "   构建完成!"
echo "========================================"