#!/usr/bin/env bash
# GTA2 stops drawing whenever its own window loses keyboard focus, and the mod's
# window steals that focus on Hyprland. Hand focus back while the game runs.
#
# Focusing: Hyprland >= 0.55 with a Lua config no longer accepts the legacy
# `hyprctl dispatch focuswindow address:...` form. Set HYPR_DISPATCH to a command that
# does (e.g. a wrapper script). Default is plain hyprctl.
HYPR_DISPATCH="${HYPR_DISPATCH:-hyprctl dispatch}"
while pgrep -f "[g]ta2\.exe" >/dev/null; do
  A=$(hyprctl clients -j | python3 -c "
import json,sys
for c in json.load(sys.stdin):
    if c['class']=='gta2.exe' and c['size'][0]<1000: print(c['address'])" 2>/dev/null)
  CUR=$(hyprctl activewindow -j | python3 -c 'import json,sys;print(json.load(sys.stdin).get("address",""))' 2>/dev/null)
  [ -n "$A" ] && [ "$CUR" != "$A" ] && $HYPR_DISPATCH focuswindow address:$A >/dev/null 2>&1
  sleep 0.5
done
