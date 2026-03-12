# Zen-C Snake Game Makefile
# 使用zc编译器构建Zen-C项目

# 编译器设置
ZC = zc
CC = gcc
CFLAGS = -Wall -Wextra -O2
TARGET = snake_game

# 源文件
SRC = src/main.zc
OUT = build/$(TARGET)

# 默认目标
all: $(OUT)

# 编译Zen-C代码
$(OUT): $(SRC)
	@mkdir -p build
	$(ZC) build -o $(OUT) $(SRC)

# 运行游戏
run: $(OUT)
	./$(OUT)

# 清理构建文件
clean:
	rm -rf build/

# 安装依赖（如果需要）
install-deps:
	# 安装Zen-C编译器
	# 请参考: https://github.com/z-libs/Zen-C
	echo "请从 https://github.com/z-libs/Zen-C 安装zc编译器"

# 测试编译
test:
	@echo "测试Zen-C编译..."
	@if command -v $(ZC) >/dev/null 2>&1; then \
		echo "zc编译器已安装"; \
		$(ZC) --version; \
	else \
		echo "错误: zc编译器未安装"; \
		echo "请运行: make install-deps 查看安装说明"; \
		exit 1; \
	fi

# 显示帮助
help:
	@echo "Zen-C Snake Game 构建系统"
	@echo ""
	@echo "可用命令:"
	@echo "  make all      - 编译游戏 (默认)"
	@echo "  make run      - 编译并运行游戏"
	@echo "  make clean    - 清理构建文件"
	@echo "  make test     - 测试编译器安装"
	@echo "  make help     - 显示此帮助信息"
	@echo ""
	@echo "依赖:"
	@echo "  - zc编译器 (Zen-C编译器)"
	@echo "  - gcc编译器 (C后端)"
	@echo ""
	@echo "安装zc编译器:"
	@echo "  git clone https://github.com/z-libs/Zen-C.git"
	@echo "  cd Zen-C && make install"

.PHONY: all run clean test help install-deps