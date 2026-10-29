# Tetris Game

A classic Tetris game implemented using Godot 4.7 engine.

## Features

- Classic Tetris gameplay mechanics
- Keyboard controls
- Partial gamepad support (movement only)
- Score system with level progression
- Save/load functionality
- Pause menu
- Game over handling (returns to title screen)
- High score tracking
- Abandon run confirmation dialog
- Improved collision detection
- Smooth rotation mechanics

## Technical Stack

- Godot 4.7
- GDScript
- 2D graphics

## Play Online

You can play the game directly in your browser at: [https://zml9167.github.io/tetris/Tetris.html](https://zml9167.github.io/tetris/Tetris.html)

## Installation

1. Download and install [Godot 4.7](https://godotengine.org/download)
2. Clone this repository:
   ```bash
   git clone https://github.com/zml9167/tetris.git
   ```
3. Open project in Godot by selecting `project.godot` file
4. Press play button to start game

## Controls

### Keyboard
- **Left Arrow/A**: Move left
- **Right Arrow/D**: Move right
- **Up Arrow/W**: Rotate clockwise
- **Down Arrow/S**: Rotate counterclockwise
- **Space**: Hard drop (fast fall)
- **Escape**: Pause game

### Gamepad
- **D-pad Left/Right**: Move left/right

Rotation, hard drop, and pause currently have no gamepad bindings.

## Game Mechanics

- Blocks fall from the top of the screen
- Complete lines to score points
- The game speeds up as you level up
- The game ends when blocks reach the top of the screen
- Rotation is blocked when it would cause blocks to go below the bottom boundary
- Press **Space** to activate hard drop (fast fall)

## Project Structure

```
tetris/
├── autoload/
│   └── global/          # Global autoload (config, save data, RNG)
├── resource/
│   ├── data/            # GameConfig and SaveData resources
│   └── pieces/          # Piece definitions (I/J/L/O/S/T/Z)
├── scenes/
│   ├── block_pool/      # Block scene and block pool
│   ├── game/            # Main game scene
│   ├── pause_menu/      # Pause menu
│   └── title/           # Title screen and abandon dialog
├── scripts/
│   └── core/            # GameGrid and PieceRotation
├── project.godot        # Project configuration
├── README.md            # This file
└── README_zh.md         # Chinese README
```

## How to Play

1. Choose **Play** on the title screen to start a new game, or **Continue** to resume a saved run
2. Use controls to move and rotate the falling blocks
3. Try to complete horizontal lines to score points
4. The game gets faster as your score increases
5. Press Escape to pause the game
6. The game ends when blocks stack up to the top

## Saving and Loading

- Progress is saved automatically after each piece locks
- You can continue your last saved run from the title screen
- You can abandon your current run from the title screen (with confirmation)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
