#!/usr/bin/env sh
set -eu
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
engine=${GODOT_BIN:-}
if [ -z "$engine" ]; then
    engine=$(command -v godot4 || command -v godot || true)
fi
if [ -z "$engine" ]; then
    echo 'Godot not found. Install Godot 4.7.2 and set GODOT_BIN.' >&2
    exit 1
fi
"$engine" --headless --editor --path "$project_dir" --import
exec "$engine" --path "$project_dir" "$@"
