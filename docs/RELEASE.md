# 构建与验证

发布版本：**v1.0.0**。运行环境：Godot `4.7.2.stable.official.ed1daf0bf`，Compatibility渲染器，640×360内部画布，物理120Hz。

## 包含的内容

- 源码ZIP：项目、GDScript、可编辑场景、所需像素素材与字体、许可证、代码讲解、检查与打包工具、演示图和发布封面。
- Windows便携ZIP：源码ZIP同等内容，另加官方Godot 4.7.2的64位EXE与控制台启动器。不是编译导出的游戏EXE。
- 两个ZIP都附`PACKAGE-MANIFEST.json`，逐文件记录字节数与SHA256。
- Release单独提供`SHA256SUMS.txt`，用于下载后核对完整ZIP。

不包含Godot导入缓存、开发机器路径、账户凭据、原始录像、剪辑依赖、AI草稿地图或未使用的美术包；引擎不提交Git历史。

## 重建

维护者安装Python 3和Git，在已提交的仓库中执行：

```sh
python tools/make_release.py --version 1.0.0
```

Windows便携包需要本地官方引擎目录，里面包含`Godot_v4.7.2-stable_win64.exe`和同名`_console.exe`：

```sh
python tools/make_release.py --version 1.0.0 --engine-dir /path/to/official-godot
```

输出到被Git忽略的`dist/`，已有同名ZIP会报错，避免覆盖历史包。脚本只收录Git列出的文件，并检查缺失字体、缓存、可执行文件误入源码包、重复条目、路径穿越、CRC、封闭文件清单与全部字节哈希。

验证下载的包：

```sh
python tools/make_release.py --verify dist/godot-mushroom-meadow-v1.0.0-source.zip
```

## 运行检查

```sh
godot --headless --editor --path . --import
godot --headless --path . --script res://tests/smoke.gd
```

`tests/smoke.gd`检查14朵蘑菇、三层可编辑瓦片、人物与字体资源、真实E按键蓄力与释放、高度变化、连续盖柄连接、邻居延迟响应、R重置清空状态。成功会输出含`"ok":true`的JSON，并退出0。

打包后还需在一个不存在导入缓存、带中文和空格的目录解压，逐文件核对manifest，再分别运行源码启动器与便携启动器；最后从GitHub公开地址重新读取仓库及下载验证。实际发布结果记录于`VALIDATION.md`。
