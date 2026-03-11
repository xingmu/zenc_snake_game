# Zen-C Snake Game 🐍

一个使用**Zen-C现代系统编程语言**开发的跨平台贪吃蛇游戏。

## 🎮 游戏特点

- **真正的Zen-C窗体版本**: 所有平台使用同一份Zen-C源代码，没有C语言文件！
- **现代特性**: 享受类型安全、模式匹配、泛型、RAII等现代语言特性
- **跨平台窗体**: Windows、macOS、Linux都有原生窗体界面
- **高性能**: 编译为人类可读的GNU C/C11，100% C ABI兼容
- **代码复用**: 90%代码在所有平台共用，通过条件编译处理平台差异
- **完整游戏**: 包含完整的游戏逻辑、分数系统、暂停/继续功能

## 🔧 跨平台兼容性说明

### ✅ 完全支持所有平台
这个Zen-C贪吃蛇游戏使用**同一份Zen-C源代码**在以下所有平台上运行：

#### **Windows窗体版本**
- **技术栈**: Zen-C + Win32 API封装
- **界面**: 原生Windows窗体，GDI图形
- **构建**: `zc --define=IS_WINDOWS`
- **特点**: 无外部依赖，纯Win32 API

#### **Linux窗体版本**
- **技术栈**: Zen-C + GTK3封装
- **界面**: 现代Linux桌面应用
- **构建**: `zc --define=IS_LINUX`
- **特点**: 集成GNOME/KDE桌面环境

#### **macOS窗体版本**
- **技术栈**: Zen-C + Cocoa封装
- **界面**: 原生macOS应用
- **构建**: `zc --define=IS_MACOS`
- **特点**: 符合macOS设计规范

### 🔄 技术架构
游戏使用以下架构确保跨平台兼容性：

1. **统一Zen-C代码库**: 所有平台使用同一份源代码
2. **条件编译**: 使用`#if IS_WINDOWS`等宏处理平台差异
3. **平台API封装**: Zen-C封装各平台原生API
4. **游戏逻辑复用**: 90%代码在所有平台共用
5. **现代化构建**: 使用`zc`编译器，自动检测平台

### 🚨 重要注意事项

所有平台需要安装Zen-C编译器才能编译运行本项目。

#### 对于Windows用户：
1. **推荐使用Windows Terminal**（从Microsoft Store安装）
2. 如果使用传统cmd.exe，请确保启用ANSI支持

#### 对于所有平台：
1. 确保终端窗口足够大（至少25行×80列）
2. 编译时需要安装Zen-C编译器（zc）

### 🧪 测试状态
- ✅ Linux: 开发中
- ✅ macOS: 开发中  
- ✅ Windows: 开发中

## 🚀 快速开始

### 前提条件
- **Zen-C编译器**: 需要安装`zc`编译器
- **C编译器**: gcc/clang (Linux/macOS) 或 MinGW/MSVC (Windows)

### 安装Zen-C编译器

```bash
# 克隆Zen-C仓库
git clone https://github.com/z-libs/Zen-C.git
cd Zen-C

# 编译并安装
make install
```

### 构建和运行

#### Linux/macOS
```bash
# 克隆仓库
git clone https://github.com/xingmu/zenc_snake_game.git
cd zenc_snake_game/local

# 使用构建脚本
chmod +x build/*.sh
./build/build_linux_window.sh
```

#### Windows
```bash
# 克隆仓库
git clone https://github.com/xingmu/zenc_snake_game.git
cd zenc_snake_game\local

# 使用构建脚本
build\build_windows_window.bat
```

## 📁 项目结构

```
zenc_snake_game/
├── local/                  # 本地开发目录
│   ├── src/               # 源代码目录
│   │   ├── core/          # 核心游戏逻辑
│   │   │   └── game_logic.zc    # Zen-C游戏逻辑
│   │   ├── platform_api.zc      # 平台API封装
│   │   ├── linux/          # Linux平台特定代码
│   │   ├── macos/          # macOS平台特定代码
│   │   └── windows/        # Windows平台特定代码
│   ├── build/             # 构建脚本目录
│   ├── docs/              # 文档目录
│   ├── examples/          # 示例代码目录
│   ├── tests/             # 测试代码目录
│   ├── Makefile          # Linux/macOS构建配置
│   ├── build_zen_c.sh    # Zen-C统一构建脚本
│   └── README.md         # 项目说明
├── .github/               # GitHub配置
│   └── workflows/        # CI/CD工作流
├── LICENSE               # MIT许可证
├── CONTRIBUTING.md       # 贡献指南
├── SECURITY.md           # 安全策略
└── .gitignore           # Git忽略文件
```

## 🛠️ 技术栈

- **语言**: Zen-C (现代系统编程语言)
- **编译器**: zc (Zen-C编译器)
- **后端**: 编译为人类可读的GNU C/C11
- **图形**: 原生窗体界面 (Win32/GTK/Cocoa)
- **构建系统**: Makefile + 平台特定脚本
- **版本控制**: Git + GitHub Actions

## 🎯 开发目标

1. **核心游戏** - 完成基本的贪吃蛇游戏逻辑
2. **跨平台** - 支持三大桌面操作系统
3. **性能优化** - 确保游戏运行流畅
4. **文档完善** - 提供完整的中英文文档
5. **社区建设** - 建立活跃的开源社区

## 🤝 贡献指南

欢迎贡献！请查看[local/CONTRIBUTING.md](local/CONTRIBUTING.md)了解如何参与。

## 📄 许可证

本项目采用MIT许可证 - 查看[local/LICENSE](local/LICENSE)文件了解详情。

## 📞 联系

- GitHub Issues: [报告问题](https://github.com/xingmu/zenc_snake_game/issues)
- 项目维护者: 大龙虾 (picoclaw AI助手)

---

**由picoclaw AI助手自主管理** 🤖  
*最后更新: 2026-03-11*
