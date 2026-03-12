# 贡献指南

欢迎为Zen-C贪吃蛇游戏项目做出贡献！本指南将帮助你了解如何参与项目开发。

## 🎯 如何贡献

### 1. 报告问题
- 使用GitHub Issues报告bug或提出功能建议
- 在创建issue前，请先搜索是否已有类似问题
- 提供清晰的问题描述、复现步骤和期望结果

### 2. 提交代码
1. Fork本仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建Pull Request

### 3. 改进文档
- 修复文档中的错误
- 添加新的使用示例
- 翻译文档到其他语言
- 改进文档结构和可读性

## 📝 开发规范

### 代码风格
- **C代码**: 遵循K&R风格，使用4空格缩进
- **Zen-C代码**: 遵循Zen-C官方代码风格
- **注释**: 使用英文注释，重要函数需要文档注释
- **命名**: 使用有意义的变量名和函数名

### 提交信息规范
使用约定式提交格式：
```
<类型>[可选范围]: <描述>

[可选正文]

[可选脚注]
```

类型包括：
- `feat`: 新功能
- `fix`: bug修复
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建过程或辅助工具变动

### 测试要求
- 新功能需要包含测试用例
- 修复bug时需要添加回归测试
- 确保所有测试通过后再提交

## 🛠️ 开发环境设置

### 前提条件
- Git
- C编译器 (gcc/clang)
- Zen-C编译器 (可选，用于Zen-C版本)

### 设置步骤
```bash
# 克隆仓库
git clone https://github.com/xingmu/zenc_snake_game.git
cd zenc_snake_game

# 构建项目
cd build
make  # Linux/macOS
# 或运行 build_windows.bat  # Windows

# 运行游戏
./snake_game
```

## 🧪 测试

### 运行测试
```bash
# 运行所有测试
make test

# 运行特定测试
./tests/test_game_logic
```

### 测试覆盖率
项目使用gcov/lcov生成测试覆盖率报告：
```bash
make coverage
```

## 📚 文档

### 文档结构
```
docs/
├── api/          # API文档
├── tutorials/    # 教程
├── design/       # 设计文档
└── translations/ # 翻译文档
```

### 构建文档
```bash
# 生成API文档
make docs
```

## 🚀 发布流程

### 版本号
使用语义化版本号：`主版本.次版本.修订版本`

### 发布步骤
1. 更新版本号
2. 更新CHANGELOG.md
3. 创建发布标签
4. 构建发布包
5. 发布到GitHub Releases

## 🤝 行为准则

请遵守以下行为准则：
- 尊重所有贡献者
- 建设性讨论，避免人身攻击
- 保持专业和礼貌
- 帮助新贡献者融入社区

## 📞 联系

- 项目维护者: 大龙虾 (picoclaw AI助手)
- GitHub Issues: 用于技术讨论和问题报告
- 讨论区: 用于功能讨论和设计决策

## 🙏 致谢

感谢所有为项目做出贡献的开发者！你的每一份贡献都让项目变得更好。

---

*最后更新: 2026-03-11*