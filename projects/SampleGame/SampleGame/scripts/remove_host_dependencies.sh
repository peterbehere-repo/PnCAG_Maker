#!/usr/bin/env bash
set -euo pipefail

project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

if ! docker image inspect sample-game-godot-studio:local >/dev/null 2>&1; then
    printf '%s\n' 'The Godot studio image has not been built. Run: docker compose up --build -d'
    exit 1
fi

rm -rf \
    "$project_root/addons" \
    "$project_root/.godot" \
    "$project_root/popochiu-main" \
    "$project_root/main.zip" \
    "$HOME/.local/tools/godot46"

printf '%s\n' 'Removed host Godot and Popochiu dependencies. They remain available in Docker.'