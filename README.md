# Zen-C Snake Game 🐍

一个使用Zen-C现代系统编程语言开发的跨平台贪吃蛇游戏。

## 🎮 游戏特点

- **现代语言**: 使用Zen-C开发，享受类型安全、模式匹配、泛型等现代特性
- **跨平台**: 支持Windows、macOS、Linux
- **高性能**: 编译为人类可读的GNU C/C11，100% C ABI兼容
- **零依赖**: 仅需标准库，无需额外依赖
- **完整游戏**: 包含完整的游戏逻辑、分数系统、暂停/继续功能
- **终端图形**: 使用ASCII/UTF-8字符，无需图形库

## 🔧 兼容性说明

### 平台支持
- **Linux**: 完全支持，使用termios终端控制
- **macOS**: 完全支持，使用termios终端控制  
- **Windows**: 基本支持，建议使用UTF-8终端或Windows Terminal

### 终端要求
1. **推荐终端**:
   - Windows: Windows Terminal, PowerShell, Git Bash
   - macOS: Terminal, iTerm2
   - Linux: GNOME Terminal, Konsole, xterm

2. **字符编码**: 建议使用UTF-8编码以获得最佳体验
3. **终端大小**: 至少25行×25列

### 已知问题
1. **Windows传统终端**: 可能不支持UTF-8表情符号，将自动回退到ASCII字符
2. **终端颜色**: 当前版本使用单色显示
3. **游戏速度**: 固定速度，暂不可调

## 🚀 快速开始

### 前提条件
- **C编译器**: gcc/clang (Linux/macOS) 或 MinGW/MSVC (Windows)
- **终端**: 支持UTF-8的终端（推荐）或标准终端

### 构建和运行

#### Linux/macOS
```bash
# 克隆仓库
git clone https://github.com/xingmu/zenc_snake_game.git
cd zenc_snake_game

# 编译游戏
make

# 运行游戏
./snake_game
```

#### Windows
```bash
# 克隆仓库
git clone https://github.com/xingmu/zenc_snake_game.git
cd zenc_snake_game

# 方法1: 使用构建脚本
build\build_windows.bat

# 方法2: 手动编译（使用MinGW）
gcc -o snake_game.exe src/snake_game.c

# 运行游戏
snake_game.exe
```

#### 所有平台（使用构建脚本）
```bash
# Linux/macOS
chmod +x build/build_mac.sh
./build/build_mac.sh

# Windows
build\build_windows.bat
```

## 📁 项目结构

```
zenc_snake_game/
├── src/                    # 源代码目录
│   ├── snake_game.c       # 主游戏程序（UTF-8版本）
│   └── snake_game_windows.c # Windows兼容版本
├── build/                 # 构建配置
│   ├── Makefile          # Linux/macOS构建
│   ├── build_windows.bat # Windows构建脚本
│   └── build_mac.sh      # macOS构建脚本
├── docs/                  # 文档目录
├── examples/              # 示例代码目录
├── tests/                 # 测试代码目录
├── README.md             # 项目说明
├── CONTRIBUTING.md       # 贡献指南
├── SECURITY.md           # 安全策略
├── LICENSE               # MIT许可证
└── .gitignore           # Git忽略文件
```

## 🛠️ 技术栈

- **语言**: Zen-C (编译为C)
- **图形**: 终端ASCII图形 / SDL2可选
- **构建系统**: Makefile + 平台特定脚本
- **版本控制**: Git + GitHub Actions

## 🎯 开发目标

1. **核心游戏** - 完成基本的贪吃蛇游戏逻辑
2. **跨平台** - 支持三大桌面操作系统
3. **性能优化** - 确保游戏运行流畅
4. **文档完善** - 提供完整的中英文文档
5. **社区建设** - 建立活跃的开源社区

## 🤝 贡献指南

欢迎贡献！请查看[CONTRIBUTING.md](CONTRIBUTING.md)了解如何参与。

## 📄 许可证

本项目采用MIT许可证 - 查看[LICENSE](LICENSE)文件了解详情。

## 📞 联系

- GitHub Issues: [报告问题](https://github.com/xingmu/zenc_snake_game/issues)
- 项目维护者: 大龙虾 (picoclaw AI助手)

## 🏆 里程碑

- [ ] 完成Zen-C版本贪吃蛇游戏
- [ ] 支持Windows平台
- [ ] 添加SDL2图形界面
- [ ] 创建安装包
- [ ] 建立CI/CD流水线

---

**由picoclaw AI助手自主管理** 🤖  
*最后更新: 2026-03-11*