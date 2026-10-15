# 第三方素材与许可

## 工程自己的部分

GDScript交互代码、场景布局、代码定义的蘑菇像素造型与运行时合成音效按根目录MIT许可提供。基础人物与环境像素素材来自下述作者；不将这些素材称为本工程原创。

## Ninja Adventure

- 作者：**Pixel-Boy 与 AAA**。
- 作者页：https://pixel-boy.itch.io/ninja-adventure-asset-pack
- 上游工程：https://github.com/pixel-boy/NinjaAdventure
- 固定提交：`6ac78232d5aedcc85ce5f27d060ea92366f7c24a`。
- 许可：**Creative Commons Zero v1.0 Universal / CC0-1.0**。
- 作者页明确允许在游戏中使用及商用。感谢两位作者开放素材。
- 原始来源、字节数、SHA256见 `assets/cc0/ninja-adventure/receipt.json`；许可证见该目录 `LICENSE.txt` 和 `licenses/CC0-1.0.txt`。

| 本地文件 | 上游路径 | 用途 |
|---|---|---|
| `floor.png` | `content/map/tileset_floor.png` | 地面、路径和水岸瓦片 |
| `props.png` | `content/map/tileset_village_abandoned.png` | 树木、岩石等 |
| `traveler.png` | `content/character/samurai_green/samurai_green.png` | 绿色旅行者角色 |
| `grass.png` | `content/destroyable/grass.png` | 草丛 |
| `water.png` | `content/map/tileset_animated.png` | 水面细节 |
| `tile-definition.source.txt` | `content/map/tileset.tres` | 构建瓦片用的上游定义记录 |

上述PNG没有重绘或更改字节；运行时按区域取图，以最近邻整数倍显示。`floor-terrains.json`整理了瓦片连接信息，`scenes/terrain.tscn`为本场景搭建的固定地图。没有引入该素材包的音乐、角色脚本或音效。

## Noto Sans SC

- 本地文件：`assets/fonts/NotoSansSC.ttf`。
- 字体内部版本：`2.004-H2`，Noto Sans SC可变字体。
- 文件内版权：2014–2021 Adobe，保留字体名Source。
- 许可：**SIL Open Font License 1.1**，完整文本见 `assets/fonts/OFL.txt`。
- 项目：https://github.com/notofonts/noto-cjk
- 许可说明：https://openfontlicense.org/

字体以原文件随工程提供，没有改名或制作本工程专属字体，不将其按MIT重新授权。

## Godot Engine（仅便携包携带二进制）

- 项目：https://godotengine.org/
- 源码：https://github.com/godotengine/godot
- 版本：`4.7.2.stable.official.ed1daf0bf`。
- 对应源码提交：`ed1daf0bf001b61586d9930840f2f1394092c079`。
- 许可页：https://godotengine.org/license/
- Godot许可：`licenses/GODOT-LICENSE.txt`。
- 第三方依赖版权及许可：`licenses/GODOT-COPYRIGHT.txt`。

二进制保持原字节，只放在Windows便携ZIP的`engine/`中；Git仓库和源码ZIP不携带引擎。上游声明下载地址与哈希记录在`licenses/upstream-notices.json`。

## 工程演示图

`media/preview.png`与`media/bounce.gif`来自本场景Godot实机，包含上述CC0人物和环境素材，用于说明工程效果。
