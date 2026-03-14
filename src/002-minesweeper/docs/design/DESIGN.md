# Minesweeper Game Design Document

## 1. Game Overview
- **Game Name**: Minesweeper (扫雷)
- **Type**: Classic puzzle game
- **Platform**: Windows (Zen-C with GUI)
- **Core Logic**: Reveal tiles avoiding mines, use number hints to deduce safe tiles

## 2. Game Features

### 2.1 Difficulty Levels
| Level | Rows | Cols | Mines |
|-------|------|------|-------|
| Easy  | 9    | 9    | 10    |
| Medium| 16   | 16   | 40    |
| Hard  | 16   | 30   | 99    |

### 2.2 Core Gameplay
- **Left Click**: Reveal tile
- **Right Click**: Flag tile
- **Middle Click**: Chord (reveal neighbors when flagged count matches number)
- **Timer**: Count elapsed time
- **Mine Counter**: Show remaining unflagged mines

### 2.3 Game States
- `READY`: Game started, waiting for input
- `PLAYING`: Active gameplay
- `WON`: All non-mine tiles revealed
- `LOST`: Mine revealed

### 2.4 First Click Safety
- First click is always safe
- If first click hits mine, relocate mine to first available empty spot

### 2.5 Auto-Reveal Feature
- When revealing a tile with 0 mines nearby, automatically reveal all adjacent tiles
- Recursive cascade reveal

## 3. UI/UX Design

### 3.1 Window Layout
```
┌─────────────────────────────┐
│  [Face] [Time] [Mines]      │  <- Header (40px)
├─────────────────────────────┤
│                             │
│     Game Board Grid         │  <- Game Area
│                             │
└─────────────────────────────┘
```

### 3.2 Visual Elements
- **Tiles**: 
  - Hidden: Raised 3D appearance (gray)
  - Revealed: Flat (light gray)
  - Flagged: Flag icon (red)
  - Question: Question mark (optional)
- **Numbers**: 1-8 with distinct colors (blue, green, red, etc.)
- **Mines**: Bomb icon (black/red)
- **Face Button**: 
  - 😊 Ready
  - 😮 During click
  - 😎 Win
  - 💀 Lose

### 3.3 Color Scheme
| Element | Color |
|---------|-------|
| Background | #C0C0C0 (Classic gray) |
| Hidden Tile | #C0C0C0 |
| Revealed Tile | #D0D0D0 |
| Number 1 | #0000FF (Blue) |
| Number 2 | #008000 (Green) |
| Number 3 | #FF0000 (Red) |
| Number 4 | #000080 (Navy) |
| Number 5 | #800000 (Maroon) |
| Number 6 | #008080 (Teal) |
| Number 7 | #000000 (Black) |
| Number 8 | #808080 (Gray) |

### 3.4 Tile Size
- Standard: 16x16 pixels
- Spacing: 1 pixel between tiles

## 4. Input Handling

### 4.1 Keyboard Shortcuts
| Key | Action |
|-----|--------|
| F2 | New Game |

### 4.2 Mouse Handling
- Input debouncing: 100ms cooldown
- Direction validation: Prevent 180° rapid turns
- Smooth interaction feedback

## 5. Scoring System

### 5.1 Time-Based Scoring
- Bonus points for faster completion
- Penalty for wrong flags
- Formula: `Score = BasePoints + TimeBonus - FlagPenalty`

### 5.2 Best Times
- Track best completion times per difficulty
- Store top 3 times

## 6. File Management

### 6.1 Data Storage
- **Location**: `%APPDATA%\Minesweeper\`
- **Files**:
  - `scores.dat` - High scores
  - `config.properties` - User settings
  - `games\save_*.dat` - Saved game states
  - `logs\game.log` - Game logs
