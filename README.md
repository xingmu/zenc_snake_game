# Windows Mini Games DIY 🕹️

一个让你**自己动手打造**的 Windows 迷你游戏集合。

## 🎮 游戏列表

| 游戏 | 描述 | 状态 |
|------|------|------|
| 🐍 贪吃蛇 | 经典贪吃蛇游戏 | ✅ 可玩 |
| ⭐ 更多游戏 | 陆续添加中 | 🚧 开发中 |

## ✨ 项目特色

- **DIY 精神**: 所有代码开源，你可以自己修改、扩展
- **零依赖**: 不需要安装任何运行时，直接编译运行
- **多版本**: 控制台版 / 窗体版 可选
- **易于扩展**: 清晰的代码结构，方便添加新游戏

## 🚀 快速开始

### 下载项目

```bash
git clone https://github.com/xingmu/windows-minigames-diy.git
cd windows-minigames-diy
```

### 编译运行

#### 贪吃蛇（控制台版）
```bash
# Windows
build\build_console.bat

# Linux
./build/build_linux_console.sh

# macOS
./build/build_mac_console.sh
```

#### 贪吃蛇（窗体版）
```bash
# Windows
build\build_window.bat

# Linux (需要GTK3)
./build/build_linux_window.sh
```

## 📁 项目结构

```
windows-minigames-diy/
├── src/                    # 源代码
│   ├── snake/             # 贪吃蛇游戏
│   │   ├── console/      # 控制台版本
│   │   └── window/       # 窗体版本
│   └── common/           # 公共代码
├── build/                 # 构建脚本
├── docs/                  # 文档
└── README.md
```

## 🛠️ 技术栈

- **语言**: C / Zen-C
- **图形**: Win32 API / GTK3 / Console
- **编译器**: GCC / MinGW / Clang

## 🤝 如何贡献

1. Fork 本项目
2. 创建分支 (`git checkout -b feature/新游戏`)
3. 提交更改 (`git commit -am '添加新游戏'`)
4. 推送分支 (`git push origin feature/新游戏`)
5. 创建 Pull Request

## 📄 许可证

MIT License - 自由使用，永久开源

---

**DIY 精神，玩转编程** 🔧
