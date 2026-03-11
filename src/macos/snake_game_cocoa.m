// macOS窗体版本贪吃蛇游戏 - Cocoa
// 使用原生Cocoa框架

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <time.h>
#import <stdbool.h>

// ==================== 游戏常量 ====================

#define WINDOW_WIDTH 800
#define WINDOW_HEIGHT 600
#define GRID_SIZE 20
#define GRID_WIDTH 30
#define GRID_HEIGHT 20
#define CELL_SIZE (GRID_SIZE)
#define MAX_SNAKE_LENGTH 100
#define INITIAL_SNAKE_LENGTH 3
#define GAME_SPEED 0.15  // 秒

// 颜色定义 (NSColor)
#define SNAKE_HEAD_COLOR [NSColor colorWithRed:46.0/255.0 green:204.0/255.0 blue:113.0/255.0 alpha:1.0]
#define SNAKE_BODY_COLOR [NSColor colorWithRed:39.0/255.0 green:174.0/255.0 blue:96.0/255.0 alpha:1.0]
#define FOOD_COLOR [NSColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:1.0]
#define BACKGROUND_COLOR [NSColor colorWithRed:52.0/255.0 green:73.0/255.0 blue:94.0/255.0 alpha:1.0]
#define GRID_COLOR [NSColor colorWithRed:44.0/255.0 green:62.0/255.0 blue:80.0/255.0 alpha:1.0]
#define TEXT_COLOR [NSColor colorWithRed:236.0/255.0 green:240.0/255.0 blue:241.0/255.0 alpha:1.0]
#define UI_BACKGROUND [NSColor colorWithRed:41.0/255.0 green:128.0/255.0 blue:185.0/255.0 alpha:1.0]
#define WINDOW_BG_COLOR [NSColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0]

// ==================== 数据结构 ====================

typedef enum {
    DIR_UP,
    DIR_DOWN,
    DIR_LEFT,
    DIR_RIGHT
} Direction;

typedef struct {
    int x;
    int y;
} Position;

typedef struct {
    Position body[MAX_SNAKE_LENGTH];
    int length;
    Direction direction;
} Snake;

typedef struct {
    Snake snake;
    Position food;
    int score;
    bool game_over;
    bool paused;
    int level;
    double speed;  // 秒
} GameState;

// ==================== 游戏视图类 ====================

@interface SnakeGameView : NSView {
    GameState game;
    NSTimer *gameTimer;
    NSFont *normalFont;
    NSFont *bigFont;
}

- (void)initGame;
- (void)updateGame;
- (void)handleKeyEvent:(NSEvent *)event;
- (void)startTimer;
- (void)stopTimer;

@end

@implementation SnakeGameView

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        // 创建字体
        normalFont = [NSFont fontWithName:@"Helvetica" size:16];
        bigFont = [NSFont fontWithName:@"Helvetica-Bold" size:24];
        
        // 初始化游戏
        [self initGame];
        
        // 设置焦点，接收键盘事件
        [self setAcceptsTouchEvents:NO];
        [self setAcceptsFirstResponder:YES];
        [self setNeedsDisplay:YES];
    }
    return self;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)canBecomeKeyView {
    return YES;
}

- (void)initGame {
    // 初始化蛇
    game.snake.length = INITIAL_SNAKE_LENGTH;
    game.snake.direction = DIR_RIGHT;
    
    // 蛇的初始位置
    for (int i = 0; i < game.snake.length; i++) {
        game.snake.body[i].x = 5 + i;
        game.snake.body[i].y = GRID_HEIGHT / 2;
    }
    
    // 生成食物
    srand((unsigned int)time(NULL));
    game.food.x = rand() % GRID_WIDTH;
    game.food.y = rand() % GRID_HEIGHT;
    
    // 初始化游戏状态
    game.score = 0;
    game.game_over = false;
    game.paused = false;
    game.level = 1;
    game.speed = GAME_SPEED;
    
    // 启动定时器
    [self startTimer];
}

- (void)generateFood {
    bool valid_position = false;
    int attempts = 0;
    const int MAX_ATTEMPTS = 100;
    
    while (!valid_position && attempts < MAX_ATTEMPTS) {
        game.food.x = rand() % GRID_WIDTH;
        game.food.y = rand() % GRID_HEIGHT;
        
        // 检查食物是否与蛇身重叠
        valid_position = true;
        for (int i = 0; i < game.snake.length; i++) {
            if (game.snake.body[i].x == game.food.x &&
                game.snake.body[i].y == game.food.y) {
                valid_position = false;
                break;
            }
        }
        
        attempts++;
    }
}

- (void)updateGame {
    if (game.game_over || game.paused) {
        return;
    }
    
    // 移动蛇
    Position new_head = game.snake.body[0];
    
    switch (game.snake.direction) {
        case DIR_UP: new_head.y--; break;
        case DIR_DOWN: new_head.y++; break;
        case DIR_LEFT: new_head.x--; break;
        case DIR_RIGHT: new_head.x++; break;
    }
    
    // 检查边界碰撞
    if (new_head.x < 0 || new_head.x >= GRID_WIDTH ||
        new_head.y < 0 || new_head.y >= GRID_HEIGHT) {
        game.game_over = true;
        [self setNeedsDisplay:YES];
        return;
    }
    
    // 检查自身碰撞
    for (int i = 0; i < game.snake.length; i++) {
        if (game.snake.body[i].x == new_head.x &&
            game.snake.body[i].y == new_head.y) {
            game.game_over = true;
            [self setNeedsDisplay:YES];
            return;
        }
    }
    
    // 移动蛇身
    for (int i = game.snake.length - 1; i > 0; i--) {
        game.snake.body[i] = game.snake.body[i - 1];
    }
    game.snake.body[0] = new_head;
    
    // 检查是否吃到食物
    if (new_head.x == game.food.x && new_head.y == game.food.y) {
        // 增加蛇长
        if (game.snake.length < MAX_SNAKE_LENGTH) {
            game.snake.length++;
        }
        
        // 生成新食物
        [self generateFood];
        
        // 增加分数
        game.score += 10;
        
        // 每100分升一级，加快速度
        if (game.score % 100 == 0) {
            game.level++;
            game.speed = game.speed > 0.05 ? game.speed - 0.02 : 0.05;
            
            // 更新定时器
            [self stopTimer];
            [self startTimer];
        }
    }
    
    [self setNeedsDisplay:YES];
}

- (void)handleKeyEvent:(NSEvent *)event {
    unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
    
    switch (key) {
        // 方向键和WASD
        case NSUpArrowFunctionKey:
        case 'w':
        case 'W':
            if (game.snake.direction != DIR_DOWN) {
                game.snake.direction = DIR_UP;
            }
            break;
            
        case NSDownArrowFunctionKey:
        case 's':
        case 'S':
            if (game.snake.direction != DIR_UP) {
                game.snake.direction = DIR_DOWN;
            }
            break;
            
        case NSLeftArrowFunctionKey:
        case 'a':
        case 'A':
            if (game.snake.direction != DIR_RIGHT) {
                game.snake.direction = DIR_LEFT;
            }
            break;
            
        case NSRightArrowFunctionKey:
        case 'd':
        case 'D':
            if (game.snake.direction != DIR_LEFT) {
                game.snake.direction = DIR_RIGHT;
            }
            break;
            
        // 空格键 - 暂停/继续
        case ' ':
            game.paused = !game.paused;
            break;
            
        // R键 - 重新开始
        case 'r':
        case 'R':
            if (game.game_over) {
                [self initGame];
            }
            break;
            
        // ESC键 - 退出游戏
        case 0x1B: // ESC
            [[NSApplication sharedApplication] terminate:nil];
            break;
    }
    
    [self setNeedsDisplay:YES];
}

- (void)keyDown:(NSEvent *)event {
    [self handleKeyEvent:event];
}

- (void)startTimer {
    gameTimer = [NSTimer scheduledTimerWithTimeInterval:game.speed
                                                target:self
                                              selector:@selector(updateGame)
                                              userInfo:nil
                                               repeats:YES];
}

- (void)stopTimer {
    if (gameTimer) {
        [gameTimer invalidate];
        gameTimer = nil;
    }
}

- (void)drawGridInRect:(NSRect)rect {
    [GRID_COLOR setStroke];
    NSBezierPath *gridPath = [NSBezierPath bezierPath];
    [gridPath setLineWidth:1.0];
    
    // 绘制垂直线
    for (int x = 0; x <= GRID_WIDTH; x++) {
        NSPoint startPoint = NSMakePoint(rect.origin.x + x * CELL_SIZE, rect.origin.y);
        NSPoint endPoint = NSMakePoint(rect.origin.x + x * CELL_SIZE, rect.origin.y + rect.size.height);
        [gridPath moveToPoint:startPoint];
        [gridPath lineToPoint:endPoint];
    }
    
    // 绘制水平线
    for (int y = 0; y <= GRID_HEIGHT; y++) {
        NSPoint startPoint = NSMakePoint(rect.origin.x, rect.origin.y + y * CELL_SIZE);
        NSPoint endPoint = NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y + y * CELL_SIZE);
        [gridPath moveToPoint:startPoint];
        [gridPath lineToPoint:endPoint];
    }
    
    [gridPath stroke];
}

- (void)drawSnakeInRect:(NSRect)rect {
    // 绘制蛇身
    [SNAKE_BODY_COLOR setFill];
    
    for (int i = 1; i < game.snake.length; i++) {
        NSRect bodyRect = NSMakeRect(
            rect.origin.x + game.snake.body[i].x * CELL_SIZE,
            rect.origin.y + game.snake.body[i].y * CELL_SIZE,
            CELL_SIZE, CELL_SIZE
        );
        [[NSBezierPath bezierPathWithRect:bodyRect] fill];
    }
    
    // 绘制蛇头
    [SNAKE_HEAD_COLOR setFill];
    NSRect headRect = NSMakeRect(
        rect.origin.x + game.snake.body[0].x * CELL_SIZE,
        rect.origin.y + game.snake.body[0].y * CELL_SIZE,
        CELL_SIZE, CELL_SIZE
    );
    [[NSBezierPath bezierPathWithRect:headRect] fill];
}

- (void)drawFoodInRect:(NSRect)rect {
    [FOOD_COLOR setFill];
    NSRect foodRect = NSMakeRect(
        rect.origin.x + game.food.x * CELL_SIZE,
        rect.origin.y + game.food.y * CELL_SIZE,
        CELL_SIZE, CELL_SIZE
    );
    [[NSBezierPath bezierPathWithOvalInRect:foodRect] fill];
}

- (void)drawRect:(NSRect)dirtyRect {
    // 绘制窗口背景
    [WINDOW_BG_COLOR setFill];
    NSRectFill(dirtyRect);
    
    // 计算游戏区域位置
    NSRect gameRect = NSMakeRect(50, 50, GRID_WIDTH * CELL_SIZE, GRID_HEIGHT * CELL_SIZE);
    
    // 绘制游戏区域背景
    [BACKGROUND_COLOR setFill];
    [[NSBezierPath bezierPathWithRect:gameRect] fill];
    
    // 绘制游戏区域边框
    [TEXT_COLOR setStroke];
    NSBezierPath *borderPath = [NSBezierPath bezierPathWithRect:gameRect];
    [borderPath setLineWidth:2.0];
    [borderPath stroke];
    
    // 绘制网格
    [self drawGridInRect:gameRect];
    
    // 绘制蛇和食物
    [self drawSnakeInRect:gameRect];
    [self drawFoodInRect:gameRect];
    
    // 绘制UI面板
    NSRect uiRect = NSMakeRect(50, gameRect.origin.y + gameRect.size.height + 20,
                              gameRect.size.width, 150);
    
    [UI_BACKGROUND setFill];
    [[NSBezierPath bezierPathWithRect:uiRect] fill];
    
    [TEXT_COLOR setStroke];
    NSBezierPath *uiBorderPath = [NSBezierPath bezierPathWithRect:uiRect];
    [uiBorderPath setLineWidth:2.0];
    [uiBorderPath stroke];
    
    // 绘制游戏信息
    [TEXT_COLOR set];
    NSString *scoreText = [NSString stringWithFormat:@"分数: %d", game.score];
    [scoreText drawAtPoint:NSMakePoint(uiRect.origin.x + 20, uiRect.origin.y + 30)
            withAttributes:@{NSFontAttributeName: bigFont}];
    
    NSString *levelText = [NSString stringWithFormat:@"等级: %d", game.level];
    [levelText drawAtPoint:NSMakePoint(uiRect.origin.x + 20, uiRect.origin.y + 70)
            withAttributes:@{NSFontAttributeName: normalFont}];
    
    NSString *lengthText = [NSString stringWithFormat:@"长度: %d", game.snake.length];
    [lengthText drawAtPoint:NSMakePoint(uiRect.origin.x + 150, uiRect.origin.y + 70)
            withAttributes:@{NSFontAttributeName: normalFont}];
    
    NSString *speedText = [NSString stringWithFormat:@"速度: %.2f 秒", game.speed];
    [speedText drawAtPoint:NSMakePoint(uiRect.origin.x + 20, uiRect.origin.y + 100)
            withAttributes:@{NSFontAttributeName: normalFont}];
    
    // 绘制游戏状态
    if (game.game_over) {
        NSString *gameOverText = @"游戏结束!";
        [gameOverText drawAtPoint:NSMakePoint(gameRect.origin.x + 80, gameRect.origin.y + 120)
                   withAttributes:@{NSFontAttributeName: bigFont}];
        
        NSString *restartText = @"按 R 键重新开始";
        [restartText drawAtPoint:NSMakePoint(gameRect.origin.x + 50, gameRect.origin.y + 170)
                  withAttributes:@{NSFontAttributeName: normalFont}];
    } else if (game.paused) {
        NSString *pausedText = @"暂停";
        [pausedText drawAtPoint:NSMakePoint(gameRect.origin.x + 100, gameRect.origin.y + 120)
                 withAttributes:@{NSFontAttributeName: bigFont}];
        
        NSString *continueText = @"按空格键继续";
        [continueText drawAtPoint:NSMakePoint(gameRect.origin.x + 50, gameRect.origin.y + 170)
                   withAttributes:@{NSFontAttributeName: normalFont}];
    }
    
    // 绘制控制说明
    NSArray *controls = @[
        @"控制:",
        @"方向键/WASD: 移动",
        @"空格键: 暂停/继续",
        @"R键: 重新开始",
        @"ESC键: 退出游戏"
    ];
    
    CGFloat controlY = uiRect.origin.y + 130;
    for (NSString *control in controls) {
        [control drawAtPoint:NSMakePoint(uiRect.origin.x + 20, controlY)
              withAttributes:@{NSFontAttributeName: normalFont, NSFontSizeAttribute: @14}];
        controlY += 25;
    }
}

- (void)dealloc {
    [self stopTimer];
    [super dealloc];
}

@end

// ==================== 应用程序委托 ====================

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong) NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    // 创建窗口
    NSRect frame = NSMakeRect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
    NSUInteger styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                          NSWindowStyleMaskMiniaturizable;
    
    self.window = [[NSWindow alloc] initWithContentRect:frame
                                              styleMask:styleMask
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    
    [self.window setTitle:@"Zen-C 贪吃蛇游戏 - macOS窗体版"];
    [self.window setBackgroundColor:WINDOW_BG_COLOR];
    [self.window center];
    
    // 创建游戏视图
    SnakeGameView *gameView = [[SnakeGameView alloc] initWithFrame:frame];
    [self.window setContentView:gameView];
    [self.window makeFirstResponder:gameView];
    
    // 显示窗口
    [self.window makeKeyAndOrderFront:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end

// ==================== 主函数 ====================

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        AppDelegate *delegate = [[AppDelegate alloc] init];
        [app setDelegate:delegate];
        [app run];
    }
    return 0;
}