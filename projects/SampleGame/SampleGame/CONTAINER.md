# Containerized Godot and Popochiu

This project keeps Godot 4.6, Popochiu, Godot import data, and Godot user settings in Docker. The image fetches Popochiu revision `784d1474ef5fe79285a9da69d550504692a3f7e3`; the `popochiu-init` service seeds it to the Docker-managed `godot-addons` volume.

## Start

Enable Docker Desktop WSL integration for this distro, then run:

```bash
docker compose up --build -d
```

Open `http://localhost:3000`. In the browser desktop, run `godot --editor --path /workspace` to use the Godot and Popochiu editor UI.

## Host Cleanup

After the successful build, remove the duplicated host dependencies with:

```bash
bash scripts/remove_host_dependencies.sh
```

The script verifies the built image first, then removes only `sample-game/addons`, `sample-game/.godot`, `sample-game/popochiu-main`, `sample-game/main.zip`, and the host Godot 4.6 installation at `~/.local/tools/godot46`.

## AI Agent Access

Open the folder in VS Code and run **Dev Containers: Reopen in Container**, or connect the agent using `docker compose exec godot-studio`. The agent’s operating instructions are in `AGENTS.md`.

## Stop

```bash
docker compose down
```

Use `docker compose down -v` only when you intend to remove the container-managed Popochiu dependency and Godot state.