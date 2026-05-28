#!/bin/sh

set -eu

swaymsg -t get_outputs | python3 -c '
import json
import sys

outputs = json.load(sys.stdin)

def mode_key(mode):
    return (
        mode.get("width", 0) * mode.get("height", 0),
        mode.get("refresh", 0),
    )

for output in outputs:
    name = output.get("name", "")
    if not name or name.startswith("eDP-"):
        continue
    modes = output.get("modes") or []
    if not modes:
        continue
    best = max(modes, key=mode_key)
    refresh_hz = best["refresh"] / 1000.0
    print("output {} mode {}x{}@{:.3f}Hz".format(
        name,
        best["width"],
        best["height"],
        refresh_hz,
    ))
' | while IFS= read -r command; do
    [ -n "$command" ] || continue
    swaymsg "$command" >/dev/null
done