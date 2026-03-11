# Zen-C语言特性展示

## 🎯 为什么选择Zen-C？

Zen-C是一个现代系统编程语言，设计理念是"像高级语言一样编写，像C语言一样运行"。它编译为人类可读的GNU C/C11代码，100% C ABI兼容。

## ✨ Zen-C核心特性

### 1. 类型推断
```zen-c
// 自动推断类型
let x = 42;          // 推断为i32
let name = "Zen-C";  // 推断为字符串
let pi = 3.14159;    // 推断为f64
```

### 2. 模式匹配
```zen-c
// 强大的模式匹配
match direction {
    Up => println!("向上移动"),
    Down => println!("向下移动"),
    Left | Right => println!("水平移动"),
    _ => println!("未知方向")
}
```

### 3. 泛型
```zen-c
// 泛型容器
struct Vector<T> {
    data: *mut T,
    size: usize,
    capacity: usize
}

// 泛型函数
fn swap<T>(a: &mut T, b: &mut T) {
    let temp = *a;
    *a = *b;
    *b = temp;
}
```

### 4. 特质系统
```zen-c
// 定义特质
trait Drawable {
    fn draw(&self);
    fn update(&mut self);
}

// 实现特质
impl Drawable for Snake {
    fn draw(&self) {
        // 绘制蛇
    }
    
    fn update(&mut self) {
        // 更新蛇的状态
    }
}
```

### 5. RAII内存管理
```zen-c
// 自动资源管理
{
    let file = File::open("data.txt");  // 打开文件
    // 使用文件...
} // 文件自动关闭
```

### 6. 错误处理
```zen-c
// Result类型处理错误
fn read_file(path: &str) -> Result<String, Error> {
    let file = File::open(path)?;  // ?操作符自动传播错误
    let content = file.read_to_string()?;
    Ok(content)
}
```

## 🎮 贪吃蛇游戏中的Zen-C特性

### 枚举和模式匹配
```zen-c
enum Direction {
    Up,
    Down,
    Left,
    Right
}

// 在游戏中使用
match game.snake.direction {
    Direction::Up => new_head.y -= 1,
    Direction::Down => new_head.y += 1,
    Direction::Left => new_head.x -= 1,
    Direction::Right => new_head.x += 1,
}
```

### 结构体和泛型
```zen-c
struct Position {
    x: i32,
    y: i32
}

struct Snake {
    body: [Position; MAX_LENGTH],
    length: i32,
    direction: Direction
}
```

### 函数式编程特性
```zen-c
// 使用迭代器
let snake_positions = game.snake.body.iter()
    .take(game.snake.length as usize)
    .collect::<Vec<_>>();

// 使用闭包
let is_collision = snake_positions.iter()
    .any(|pos| pos.x == new_head.x && pos.y == new_head.y);
```

## 🔧 编译过程

### Zen-C → C → 可执行文件
```
main.zc (Zen-C源代码)
    ↓ zc编译器编译
main.c (人类可读的C代码)
    ↓ gcc/clang编译
snake_game (可执行文件)
```

### 生成的C代码示例
```c
// Zen-C编译生成的C代码
typedef struct {
    int32_t x;
    int32_t y;
} Position;

typedef enum {
    Direction_Up,
    Direction_Down,
    Direction_Left,
    Direction_Right
} Direction;
```

## 🚀 性能优势

1. **零开销抽象**: Zen-C的抽象在编译时消除
2. **内存安全**: 编译时检查，无运行时垃圾回收
3. **直接C互操作**: 100% C ABI兼容
4. **现代语法**: 减少样板代码，提高开发效率

## 📚 学习资源

1. **官方文档**: https://research.tedneward.com/languages/zenc/
2. **GitHub仓库**: https://github.com/z-libs/Zen-C
3. **示例项目**: https://github.com/z-libs/Zen-C/tree/main/examples
4. **社区讨论**: GitHub Issues和Discussions

## 🎯 适合场景

- ✅ 系统编程
- ✅ 游戏开发
- ✅ 嵌入式系统
- ✅ 高性能计算
- ✅ 操作系统开发
- ✅ 编译器开发

---

**Zen-C让系统编程变得现代化！** 🚀