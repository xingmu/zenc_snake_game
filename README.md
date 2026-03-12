# Windows Mini Games DIY 🕹️

一个让你**自己动手打造**的 Windows 迷你游戏集合。

## 🎮 游戏列表

- **🐍 贪吃蛇** - 经典贪吃蛇游戏
  - 控制台版
  - 窗体版

## ✨ 项目特色

- **DIY 精神**: 所有代码开源，你可以自己修改、扩展
- **零依赖**: 不需要安装任何运行时，直接编译运行
- **多版本**: 控制台版 / 窗体版 可选
- **易于扩展**: 清晰的代码结构，方便添加新游戏
- **Zen-C 语言**: 核心代码使用 Zen-C 编写，仅支持 Windows 平台

## 🚀 快速开始

### 下载项目

```bash
git clone https://github.com/xingmu/windows-minigames-diy.git
cd windows-minigames-diy
```

### 编译运行

#### 贪吃蛇（控制台版）

```bash
cd src/snake
build_windows.bat
```

#### 贪吃蛇（窗体版）

```bash
cd src/snake
build_windows_window.bat
```

## 🛠️ 技术栈

- **语言**: Zen-C (仅支持 Windows)
- **图形**: Win32 API / Console
- **编译器**: GCC / MinGW

## ⚠️ 技术约束

- **平台限制**: 仅支持 Windows 10/11
- **开发语言**: 主代码必须使用 Zen-C 语言
- **禁止语言**: 不得使用 C++, C#, Python, Java 等其他语言

## 📄 许可证

MIT License - 自由使用，永久开源

---

**DIY 精神，玩转编程** 🔧
