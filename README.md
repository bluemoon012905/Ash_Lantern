# Ash_Lantern

## Current Version Progress

- **v0.0** – Prototype top-down arena with a circular `CharacterBody2D`, a following camera, and bounded walls so the player can roam safely with WASD/arrow keys.
- **v0.0.1** – Introduced a separate sword scene that stays attached to the player’s motion, ready for future combat.
- **v0.0.2** – Added a jaunty hat to clarify facing direction and pulled the sword in closer for readability.
- **v0.1.0** – Implemented the first combat pass: the sword now understands the five core moves (`劈`, `点`, `撩`, `挂`, `崩`), enforces their starting/ending poses, runs them through a visible queue, flashes comic-style Chinese callouts with a stylized font when a move lands, tracks a placeholder damage value of 1 per action, and snaps back to a neutral guard after a short idle.
- **v0.2.0** – Ported the prototype to 3D: the arena, player, and sword now live in a 3D space with a capsule body, jaunty hat, boxy sword mesh, 3D camera, and collisions that mirror the old 2D boundaries while keeping all queue/callout systems intact.
- **v0.3.0** – Added full mouse-aim controls with a third-person orbit camera that scroll-zooms smoothly into a first-person view, tightening FOV and lining sword direction up with wherever you’re looking.

### Controls

- Movement: Arrow keys or WASD
- Attacks: `J`=劈, `K`=点, `L`=撩, `U`=挂, `I`=崩
- The queue panel in the top-left lists upcoming sword inputs; the big comic shout at the top center shows the move name after it resolves.

### Running

1. Open the `ash_lantern_godot` folder with Godot 4.4.
2. Play the project (the default scene is already configured to `scenes/main.tscn`).

### Web Build / GitHub Pages

- The repo now ships with a Web export preset (`ash_lantern_godot/export_presets.cfg`) and a workflow at `.github/workflows/deploy-web.yml`.
- On every push to `main`, GitHub Actions installs Godot 4.4.1, exports `ash_lantern_godot` to `build/web`, and publishes it to the `gh-pages` branch using `peaceiris/actions-gh-pages`.
- After the first successful run, enable GitHub Pages in the repo settings and point it to the `gh-pages` branch (root). Your playable HTML5 build will then be served automatically.
- To test locally, run `godot --headless --export-release "Web" ../build/web/index.html` from the `ash_lantern_godot` directory and open `build/web/index.html` with any static server.
