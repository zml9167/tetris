# 俄罗斯方块游戏

使用 Godot 4.7 引擎实现的经典俄罗斯方块游戏。

## 功能特性

- 经典俄罗斯方块游戏机制
- 键盘控制
- 部分游戏手柄支持（仅左右移动）
- 分数系统和等级提升
- 保存/加载功能
- 暂停菜单
- 游戏结束处理（返回标题画面）
- 最高分记录
- 放弃游戏确认对话框
- 改进的碰撞检测
- 流畅的旋转机制

## 技术栈

- Godot 4.7
- GDScript
- 2D 图形

## 在线游玩

你可以直接在浏览器中游玩：[https://zml9167.github.io/tetris/Tetris.html](https://zml9167.github.io/tetris/Tetris.html)

## 安装方法

1. 下载并安装 [Godot 4.7](https://godotengine.org/download)
2. 克隆本仓库：
   ```bash
   git clone https://github.com/yourusername/tetris.git
   ```
3. 在 Godot 中打开项目，选择 `project.godot` 文件
4. 按播放按钮开始游戏

## 控制方式

### 键盘
- **左箭头/A**：向左移动
- **右箭头/D**：向右移动
- **上箭头/W**：顺时针旋转
- **下箭头/S**：逆时针旋转
- **空格**：硬降（快速下落）
- **Escape**：暂停游戏

### 游戏手柄
- **方向键左右**：左右移动

旋转、硬降和暂停目前没有手柄绑定。

## 游戏机制

- 方块从屏幕顶部落下
- 完成整行来获得分数
- 随着等级提升，游戏速度会加快
- 当方块到达屏幕顶部时游戏结束
- 当旋转会导致方块超出底部边界时，旋转会被阻止
- 按**空格**激活硬降（快速下落）

## 项目结构

```
tetris/
├── autoload/
│   └── global/          # 全局自动加载（配置、存档、随机数）
├── resource/
│   ├── data/            # GameConfig 与 SaveData 资源
│   └── pieces/          # 方块定义（I/J/L/O/S/T/Z）
├── scenes/
│   ├── block_pool/      # 方块场景与对象池
│   ├── game/            # 主游戏场景
│   ├── pause_menu/      # 暂停菜单
│   └── title/           # 标题画面与放弃确认对话框
├── scripts/
│   └── core/            # GameGrid 与 PieceRotation
├── project.godot        # 项目配置
├── README.md            # 英文说明文件
└── README_zh.md         # 中文说明文件
```

## 游戏玩法

1. 在标题画面选择“Play”开始新游戏，有存档时选择“Continue”继续
2. 使用控制键移动和旋转下落的方块
3. 尝试完成水平行来获得分数
4. 随着分数增加，游戏速度会加快
5. 按 Escape 键暂停游戏
6. 当方块堆叠到顶部时游戏结束

## 保存和加载

- 每锁定一个方块后会自动保存进度
- 你可以从标题画面继续上次保存的游戏
- 你可以从标题画面放弃当前游戏（需要确认）

## 贡献

欢迎贡献！请随时提交 Pull Request。

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。
