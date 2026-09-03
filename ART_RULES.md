# TinyFarm Art Rules v0.1

## Grid and sprite scale

- Use a 16×16 px base world tile. The grid is a placement unit, not a maximum sprite size.
- Terrain and soil: 16×16 px.
- Grass and flowers: about 8×8 to 16×16 px.
- Crops: one 16×16 gameplay cell; artwork may extend upward.
- Small rocks: 16×16 px. Bushes: 16×16 or 32×32 px.
- Trees: about 32×48 px. Characters: about 16×24 px.
- Tiny particles: about 1×1 to 6×6 px.

## Pixel rendering

- Import PNG sprites without lossy compression or mipmaps unless an asset has a demonstrated need.
- Use nearest-neighbor filtering; never use bilinear smoothing for pixel art.
- Keep pixel density consistent and place base sprites on integer-friendly coordinates and scales.
- Temporary Tween or shader motion may use subpixels when it remains crisp and does not create camera jitter.

## Palette

- Begin with roughly 24–32 warm, cozy colors and reuse them deliberately.
- Avoid redundant shades. Prefer a dark colored outline over pure black where it reads clearly.
- Preserve transparent pixels around sprite silhouettes.

## Animation

- Favor subtle environmental motion; vegetation should rarely feel completely static.
- Use sprite frames only where they add useful shape or timing changes.
- Reusable shaders and Tweens may supplement frame animation.
- Avoid exaggerated, rubbery movement.

## Environment

- Build visually dense scenes with many small natural details while preserving gameplay silhouettes and paths.
- Micro-effects should enrich the scene without competing for attention.

## Naming

Use lowercase snake_case and numbered variants: `grass_01.png`, `grass_02.png`, `grass_03.png`, `flower_white_01.png`, `flower_yellow_01.png`, `flower_pink_01.png`, `rock_small_01.png`, `bush_01.png`, `tree_oak_01.png`, `stump_01.png`, `mushroom_red_01.png`, `leaf_01.png`, and `sparkle_01.png`.
