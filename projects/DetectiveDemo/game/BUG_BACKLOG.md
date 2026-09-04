# DetectiveDemo — Bug Backlog (alive as of 2026-09-04)

Live: https://peterbehere-repo.github.io/PnCAG_Maker/DetectiveDemo/
Build naming: game-<unix-ts>.{html,js,pck,wasm,png,…}; root index.html redirects to newest.

## ✅ FIXED

### 1. Web audio silent in Chrome/Windows
- Root causes (stacked):
  a) `res://icon.svg` missing → export error (harmless, but noisy).
  b) Chrome autoplay policy: audio started at room-entry (no gesture) → AudioContext suspended → cue registered `playing=true` but silent.
  c) First gate fired on pointer-DOWN; Chrome resumes audio on pointer-UP → restart still landed in suspended context.
- Fix: amplification 30x (ambience peak 0.0215 → 0.65), audio-gate Button (ACTION_MODE_BUTTON_RELEASE) + re-attach ambience at +0.6s and +1.6s after unlock. VERIFIED by Peter 2026-09-04.

### 2. Desk/window interaction areas mismatched the art
- Window hotspot was top-left (lamp area); moved to (1300, 280) — real window top-right.
- Desk prop was mid-room; moved to (400, 840) — real desk left-center.
- Detective spawn (900,780) overlapped desk (420px clickable polygon) → moved PC to (1450, 900).

### 3. Brass key pre-granted at start
- project.godot `popochiu/inventory/items_on_start=PackedStringArray("brass_key")` removed → pickup is now visible.

### 4. Build/deploy pipeline (many)
- rsync missing → stale web files accumulated; replaced with clean rm+cp.
- Versioning renamed index.js AND worklet to same name → loader collision (blank screen); renamed worklets distinctly.
- `"executable":"index"` in html not rewritten → loader fetched nonexistent index.wasm (black screen); now rewritten to game-<ts>.
- Workflow artifact/deploy-pages variants failed to parse/run → restored peaceiris/actions-gh-pages@v4 force_orphan git-push workflow.
- Root path had no redirect → stale build; now index.html redirects to newest game-<ts>.html.
- Deploy CDN lag: versioned files 404 for 30–60s after push; root may redirect old-version briefly.

## 🟡 UNRESOLVED (Peter reported, not yet root-caused)

### A. Walkable ability does not work in web build
- Clicking floor: detective does not walk (headless injection test DOES walk).
- Debug panel shows `active WA: StudyFloor`, groups populated — the walkable area registers.
- Suspects: (1) click coords mapped to viewport but room expects canvas coords; (2) input events not reaching `_unhandled_input` in web because Autoload `_input`/overlay consumes them (checked: overlay is MOUSE_FILTER_IGNORE); (3) `NavigationRegion2D` polygon not baked in exported build (headless bakes on `_ready`, but web timing?).
- Overlay instrumentation: `last click: (x,y) btn1` updates on click → input IS arriving at _input layer. `room unhandled: ?` (we removed the _unhandled_input probe — see DebugOverlay.gd).

### B. Walkable area overlay (green) never draws
- AreaDrawer draws props (orange), hotspots (cyan) — those DID render per Peter's screenshot.
- Walkable uses NavigationRegion2D polygon via `Perimeter` child — not drawn.
- Suspect: wrong node lookup (walkable area node is Node2D named StudyFloor with NavigationRegion2D child Perimeter), or polygon extraction off in web transform.

### C. Prop interactions unresponsive in web (desk/window clicks)
- Debug panel hovered updates correctly (hover works). Click → no interaction.
- Prop click path: PopochiuClickable._on_input_event requires `PopochiuUtils.e.hovered == self` — if hovered is stale/NULL at click time (fast click, click without moving), silent return.
- ALSO: room `_unhandled_input` returns early when `hovered` set (so a "click while hovering" does NOT walk — it's meant for the clickable). If the clickable's input_event doesn't fire in web, clicking a prop = dead.
- Possible root: web input event order (mouse_entered fires, but input_event on Area2D doesn't arrive?) — needs browser-console instrumentation of `_on_input_event`.

### D. [Low] Missing res://icon.svg in export
- project.godot references icon that doesn't exist. Cosmetic, but fix by adding an icon.

## 🔬 Next diagnostic steps (in order)
1. Instrument PopochiuClickable._on_input_event + PopochiuRoom._unhandled_input with prints → Peter tests web + reads console → confirms which layer drops the click.
2. Check NavigationRegion2D baking / walkable collision in exported web build (compare scene state via DebugOverlay).
3. Test walk-path after input confirmed: if clicks arrive but walk doesn't, it's the navmesh baking.
