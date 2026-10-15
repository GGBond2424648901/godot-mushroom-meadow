# 验证记录

2026-10-15，使用Godot `4.7.2.stable.official.ed1daf0bf`在Windows 11验证本公开工程。

- 不依赖原开发目录的Godot导入缓存；首次导入退出0。
- 运行`tests/smoke.gd`退出0，`failures`为空。
- 加载14朵蘑菇及Grass、Footpath、Water三个TileMapLayer，人物、菌盖与字体均可用。
- 用实际E输入蓄力后释放，角色最高高度140.841原生像素，较当时支撑面上升118.831像素。
- 9个邻居脉冲执行；连续检查菌盖与菌柄接点一致、柄基部固定。
- R重置清空待执行队列、孢子及角色起跳状态。

源码与便携ZIP另做CRC、逐文件哈希、完整清单与新目录解压检查，在含中文和空格的路径冷启动。最终机器记录和下载校验值随[Release](https://github.com/GGBond2424648901/godot-mushroom-meadow/releases/latest)提供为`RELEASE-QA.json`与`SHA256SUMS.txt`；包内各有`PACKAGE-MANIFEST.json`。

仓库工作流会从干净Linux检出下载固定版本Godot，校验官方ZIP的SHA256，再导入和执行同一交互测试。实际CI结果以仓库Actions页面为准，不能以工作流文件存在代表已经运行成功。
