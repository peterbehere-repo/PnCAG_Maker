#!/usr/bin/env bash
# Rebuild the web preview after editing the game, then serve it locally.
# Usage: bash "Export Web Preview.sh" [port]
set -e
GODOT="/rool-drive/GameDev/Godot/Godot_v4.6.3-stable_linux.x86_64"
PORT="${1:-8765}"
echo ">>> Exporting web build (no-threads)..."
"$GODOT" --headless --path "$(dirname "$0")" --export-release "WebNoThreads" build/web-nothreads/index.html
echo ">>> Done. Serving at http://localhost:$PORT (Ctrl+C to stop)"
cd "$(dirname "$0")/build/web-nothreads"
python3 -m http.server "$PORT"
