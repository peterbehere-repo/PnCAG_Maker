# AI Game Agent Guide

Godot 4.6 and Popochiu are container-only dependencies. This host folder stores game source and assets; the running `godot-studio` service overlays Docker-managed volumes at `/workspace/addons` and `/workspace/.godot`.

## Workflow

1. Inspect existing scenes and GDScript before editing.
2. Put game work in `game/`, `scenes/`, `scripts/`, and `assets/`. Do not modify `addons/popochiu/` unless the task is explicitly about the engine.
3. Validate with `godot --headless --path /workspace --editor --quit`.
4. Launch a playtest with `godot --path /workspace --audio-driver Dummy`.
5. Use the Godot editor at `http://localhost:3000` for GUI-only editor operations.

## Access

An authorized AI agent can attach with VS Code Dev Containers or execute commands with:

```bash
docker compose exec godot-studio godot --headless --path /workspace --editor --quit
```

No provider-specific AI client or credentials are included in the image. Supply agent access through your selected AI tool after it attaches to the Dev Container.