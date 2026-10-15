# 从踩压到弹起：实际交互代码

这不是播放预设弹跳动画。脚下是否有支撑、压了多少、弹多高和邻近蘑菇何时响应，均在运行时计算。这里的片段来自本工程，省略部分外围判定；完整实现以链接中的函数为准。

## 1. 用一个数表示压缩

[`spring.gd:step()`](../src/spring.gd)保存`displacement`和`velocity`，分别是压缩量和形变速度。脚下没有人时载荷目标为0，站稳时0.32，E蓄力时0.58，由[`meadow.gd:_physics_process()`](../src/meadow.gd)传入：

```gdscript
velocity += (stiffness * (load_force - displacement) - damping * velocity) * h
displacement += velocity * h
```

`stiffness`决定拉回目标的力度，`damping`逐渐消耗晃动。积分小步`h`不超过1/120秒，单帧累计时间最多0.1秒；压缩边界为−0.23到0.72，触及边界同时限制速度。大蘑菇、小蘑菇和不同颜色的刚度略有区别，见`mushroom.gd:refresh()`。

## 2. 菌盖变形，菌柄基部落地

[`mushroom.gd:cap_transform()`](../src/mushroom.gd)用压缩量改变菌盖的宽高、支撑高度和轻微倾斜。`refresh()`从菌盖图像的透明遮罩中寻找底部连接点，并把菌柄顶端埋入一点，减少像素缝。

```gdscript
var joint: Vector2 = $Cap.transform * cap_joint
var tip_distance: float = $Stalk.texture.get_height() - 0.5
$Stalk.transform = Transform2D(
    Vector2(1.0 + q * 0.16, 0),
    -joint / tip_distance,
    Vector2.ZERO
)
```

连接点跟随菌盖变换；菌柄通过伸缩与剪切连接该点，而自身原点始终在地面。因此菌盖不会弹起来、把菌柄独自留在下面。

## 3. 脚底怎样贴着走

角色的`position`负责平面移动，`height`单独表示离地高度。`supports()`把脚底位置逆变换回菌盖图像，检查不透明像素，`support_at()`在重叠菌盖中选最高有效支撑面。

[`traveler.gd:move_vertical()`](../src/traveler.gd)在站立时平滑跟随`surface_height()`；腾空后用重力积分。只有从支撑面上方落下、穿过高度时才落在菌盖上，避免从下方吸附。`update_depth()`让站在菌盖上的身体正确绘制在盖面前面，地面阴影仍保留地面深度。

## 4. 压缩量怎样变成弹力

[`mushroom.gd:bounce_rise()`](../src/mushroom.gd)扣除站立载荷后，把额外压缩比例映射到目标高度，再乘菌盖尺寸系数：

```gdscript
var stored := clampf((spring.displacement - standing_load) / (0.58 - standing_load), 0.0, 1.0)
return lerpf(40.0, 80.0, stored) * clampf(cap_width / 48.0, 0.5, 1.5)
```

[`traveler.gd:launch_bounce()`](../src/traveler.gd)再把高度换算成初速度：

```gdscript
launch(sqrt(2.0 * GRAVITY * minf(rise, available_rise)))
```

重力为300。`available_rise`按角色当前位置与显示边界留空间，避免北侧起跳时出画。E松开时仍需站在同一朵蘑菇且已经站稳，才触发蓄力弹射；落地冲击还能触发较小的回弹。

## 5. 周围蘑菇怎样“传话”

[`meadow.gd:spread()`](../src/meadow.gd)寻找165原生像素内的邻居，按距离排队，而不是立即同时摇动所有蘑菇：

```gdscript
"due": clock + 0.09 + distance / 220.0
"force": strength * (1.0 - distance / 175) * 2.5
```

到时间后执行`target.pulse()`，给目标自己的弹簧速度一个脉冲，并按左右方向添加侧摆。越远，开始越晚、响应越轻；R重置会清掉尚未触发的队列。

## 6. 孢子、影子和原生音效

- [`effects.gd`](../src/effects.gd)在实际冲击与释放处生成孢子；靠水移动时生成水纹。
- [`traveler.gd:_draw()`](../src/traveler.gd)按高度缩小、淡化角色地面影子。
- [`sound.gd`](../src/sound.gd)用正弦、频率下滑和衰减包络合成48kHz弹跳音效，按冲击调音高，6个播放器轮转；没有素材包音乐或外部音效文件。

## 调整与扩展

先改`cap_width`和`stalk_height`观察尺度，再调整刚度、阻尼、`bounce_rise()`和`spread()`，每次只改一组。运行`tests/smoke.gd`可检查资源、蓄力释放、明显高跳、盖柄不断开、邻近响应和重置。修改地图可直接打开`scenes/terrain.tscn`，三层瓦片可单独编辑。
