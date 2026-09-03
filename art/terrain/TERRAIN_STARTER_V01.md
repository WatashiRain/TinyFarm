# TinyFarm Terrain Starter v0.1

TinyFarm Terrain Starter v0.1 is an original, locally generated pixel-art terrain set. No external artwork is used.

- Production sheet: `res://art/terrain/terrain_starter_v01.png`
- Dimensions: 256×256 RGBA8
- Grid: 16×16 pixels (16 columns × 16 rows)
- Generator: `res://tools/generate_terrain_starter.gd`
- TileSet: `res://resources/tilesets/terrain_starter_v01.tres`
- Preview: 8× nearest-neighbor enlargement on a neutral review background

## Atlas layout

Coordinates are zero-based `(column, row)`.

| Coordinate | Tile |
| --- | --- |
| (0,0)–(2,0) | grass_base_01, grass_base_02, grass_base_03 |
| (3,0)–(5,0) | dirt_base, dirt_variation_01, dirt_variation_02 |
| (6,0)–(7,0) | farm_soil_dry, farm_soil_wet |
| (8,0)–(10,0) | tilled_center, tilled_horizontal_edge, tilled_vertical_edge |
| (11,0)–(14,0) | tilled_corner_tl, tr, bl, br |
| (0,1) | path_center |
| (1,1)–(4,1) | path_edge_top, bottom, left, right |
| (5,1)–(8,1) | path_outer_corner_tl, tr, bl, br |
| (9,1)–(12,1) | path_inner_corner_tl, tr, bl, br |
| (13,1) | path_variation |
| (0,2)–(1,2) | water_center, water_variation |
| (2,2)–(5,2) | shore_top, bottom, left, right |
| (6,2)–(9,2) | shore_corner_tl, tr, bl, br |
| (0,3)–(3,3) | grass_marks, dirt_specks, pebbles, tiny_ground_flower |

## Palette

The terrain reuses the foliage, soil, bark, wood, stone, cream, and yellow colors from `res://art/palettes/tinyfarm_v01.*`. Four restrained water colors extend that palette: deep `#24696F`, base `#348B8E`, light `#4FAA9F`, and glint `#A7D3B0`.

The shared TileSet exposes named Grass, Path, Farm Soil, and Water terrain categories. The playground uses explicit atlas selection for edges and corners, keeping the initial terrain implementation deterministic and straightforward to maintain.
