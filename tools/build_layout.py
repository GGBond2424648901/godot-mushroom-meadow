from pathlib import Path
p=Path(__file__).resolve().parents[1]
lines=['[gd_scene load_steps=10 format=3]',
'[ext_resource type="Script" path="res://src/meadow.gd" id="1"]',
'[ext_resource type="PackedScene" path="res://scenes/mushroom.tscn" id="2"]',
'[ext_resource type="PackedScene" path="res://scenes/prop.tscn" id="3"]',
'[ext_resource type="PackedScene" path="res://scenes/traveler.tscn" id="4"]',
'[ext_resource type="Script" path="res://src/effects.gd" id="5"]',
'[ext_resource type="Script" path="res://src/hud.gd" id="6"]',
'[ext_resource type="Script" path="res://src/sound.gd" id="7"]',
'[ext_resource type="Script" path="res://src/decor.gd" id="8"]',
'[ext_resource type="PackedScene" path="res://scenes/terrain.tscn" id="9"]',
'[node name="MushroomMeadow" type="Node2D"]','texture_filter = 1','script = ExtResource("1")',
'[node name="World" type="Node2D" parent="."]',
'[node name="Ground" parent="World" instance=ExtResource("9")]',
'[node name="Props" type="Node2D" parent="World"]','y_sort_enabled = true']
mushrooms=[('Coral1',325,235,0,72,31),('Coral2',156,154,0,57,38),('Coral3',413,158,0,51,36),
('Coral4',178,267,0,34,23),('Coral5',407,291,0,38,25),('Coral6',526,229,0,38,28),
('Gold1',120,235,1,43,28),('Gold2',478,191,1,42,29),('Gold3',224,207,1,34,22),
('Mint1',200,179,2,23,19),('Mint2',512,256,2,21,19),('Mint3',368,288,2,26,21),
('Mint4',182,298,2,26,20),('Gold4',433,181,1,27,22)]
for name,x,y,s,w,h in mushrooms:
    lines += [f'[node name="{name}" parent="World/Props" instance=ExtResource("2")]',f'position = Vector2({x}, {y})',f'species = {s}',f'cap_width = {w}.0',f'stalk_height = {h}.0']
trees=[(13,116,128,144),(65,80,128,144),(136,84,96,144),(181,59,128,144),(244,53,96,144),
(390,58,128,144),(444,88,96,144),(506,93,128,144),(609,112,128,144),
(15,181,128,144),(52,150,64,96),(5,251,128,144),(649,267,128,144),(632,330,96,144),
(11,377,128,144),(68,392,128,144),(146,425,128,144),(493,421,128,144),(582,394,128,144),(666,366,128,144)]
for i,(x,y,w,h) in enumerate(trees):
    lines += [f'[node name="Tree{i+1}" parent="World/Props" instance=ExtResource("3")]',f'position = Vector2({x}, {y})',f'sprite_size = Vector2i({w}, {h})','solid = true']
    lines += [f'flip_sprite = {str(i%2==0).lower()}', 'tint = Color(0.89,0.96,0.94,1)' if y>300 else 'tint = Color(0.95,1,0.97,1)']
    if i in [2,4,6,10,13]:lines += ['atlas_cell = 16']
for i,(x,y,w,h) in enumerate([(236,282,27,30),(571,269,31,28),(87,183,37,40),(565,147,37,36)]):
    lines += [f'[node name="Rock{i+1}" parent="World/Props" instance=ExtResource("3")]',f'position = Vector2({x}, {y})','atlas_cell = 5',f'sprite_size = Vector2i({w}, {h})','solid = true']
for i,(x,y) in enumerate([(103,273),(121,284),(151,292),(209,308),(203,282),(90,236),(192,196),(219,191),(430,113),(458,123),(507,278),(545,246),(563,262),(531,284),(373,299),(396,318),(416,319),(114,159)]):
    lines += [f'[node name="Fern{i+1}" parent="World/Props" instance=ExtResource("3")]',f'position = Vector2({x}, {y})','atlas_cell = 6','sprite_size = Vector2i(24, 25)']
for i,(x,y) in enumerate([(243,250),(257,262),(482,237),(494,247),(530,216),(547,229),(199,209),(453,284),(109,196)]):
    lines += [f'[node name="Flowers{i+1}" parent="World/Props" instance=ExtResource("3")]',f'position = Vector2({x}, {y})','atlas_cell = 7','sprite_size = Vector2i(12, 13)']
lines += ['[node name="WoodSign" type="Node2D" parent="World/Props"]','position = Vector2(520, 135)','script = ExtResource("8")',
'[node name="PondFence" type="Node2D" parent="World/Props"]','position = Vector2(569, 249)','script = ExtResource("8")','kind = 1',
'[node name="Traveler" parent="World/Props" instance=ExtResource("4")]','position = Vector2(279, 254)',
'[node name="Effects" type="Node2D" parent="World"]','z_index = 1024','script = ExtResource("5")',
'[node name="Sound" type="Node" parent="."]','script = ExtResource("7")',
'[node name="HUD" type="CanvasLayer" parent="."]','script = ExtResource("6")',
'[node name="Title" type="Label" parent="HUD"]','offset_left = 18.0','offset_top = 12.0','offset_right = 205.0','offset_bottom = 44.0','theme_override_colors/font_color = Color(1,0.91,0.64,1)','theme_override_colors/font_shadow_color = Color(0.04,0.12,0.12,1)','theme_override_constants/shadow_offset_x = 1','theme_override_constants/shadow_offset_y = 2','theme_override_font_sizes/font_size = 20',
'[node name="Status" type="Label" parent="HUD"]','offset_left = 206.0','offset_top = 12.0','offset_right = 622.0','offset_bottom = 35.0','horizontal_alignment = 2','theme_override_font_sizes/font_size = 11','theme_override_colors/font_color = Color(0.85,0.97,0.82,1)','theme_override_colors/font_shadow_color = Color(0.01,0.08,0.09,1)','theme_override_constants/shadow_offset_x = 1','theme_override_constants/shadow_offset_y = 1',
'[node name="Charge" type="ProgressBar" parent="HUD"]','offset_left = 271.0','offset_top = 311.0','offset_right = 369.0','offset_bottom = 318.0','show_percentage = false']
(p/'scenes/meadow.tscn').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('Saved editable scene: 14 mushroom instances, independent CC0 props, TileMapLayers and a traveler.')
