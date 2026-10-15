# 封面制作记录

工具：内置imagegen，基于已检查的本地实机帧编辑；最终PNG以常用封面尺寸输出。不是重新生成人物或场景的开发素材。

横版输入为1920×1080实机压缩帧，竖版输入为同帧中央608×1080裁切。两版图片各自生成，而不是把横版文字直接裁掉。

## 横版提示词

```text
Use case: precise-object-edit / text overlay. Landscape 16:9 video cover.
Use the supplied Godot gameplay frame as the exact edit target.
Main Chinese title, verbatim: 蘑菇草坪
Subtitle, verbatim: 小蘑菇，也有大弹力！
Friendly bold Chinese lettering in warm ivory, deep forest-green edge,
restrained shadow. Main title one line centered at x50%, y8–24%;
subtitle centered at y29–35%. Keep both lines within central 4:3 crop.
Keep the exact green samurai, compressed mushroom and attached stalk,
all surrounding props, native block pixels, colors and framing.
No new scenery, repainting, smooth illustration, logo, badges or watermark.
Do not reveal the high launch; save the surprise for the video.
```

## 竖版提示词

```text
Use case: precise-object-edit / text overlay. Portrait 9:16 video cover.
Use the supplied real vertical gameplay crop as the exact edit target.
Main Chinese title, verbatim: 蘑菇草坪
Subtitle, verbatim: 小蘑菇，也有大弹力！
Warm ivory friendly Chinese display lettering, dark forest-green edge.
Main title one horizontal line centered, y16–25%; subtitle y29–33%.
Keep lettering above the character and within a central 3:4 crop.
Keep the exact pixel character, red mushroom with grounded attached stalk,
grass, path and partial mint mushroom. No extending or reimagining the map.
No extra objects, limbs, painterly smoothing, borders, sidebars or watermark.
```

实际生成提示词还详细列明了主体、字色、位置与避免项，以上保留可复用的核心要求。封面生成并非逐像素不变的技术证明；游戏资源的原字节核验单独记录在素材receipt与发布验证中。
