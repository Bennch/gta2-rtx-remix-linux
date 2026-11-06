#!/usr/bin/env bash
# Launch GTA2 + RTX Remix mod under Wine on Hyprland (NVIDIA).
# Usage: PRIMARY_MONITOR=DP-1 ./start-gta2-rtx.sh
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WINEPREFIX="${WINEPREFIX:-$HOME/Games/GTA2/prefix}"
GAME_DIR="${GAME_DIR:-$WINEPREFIX/drive_c/Program Files (x86)/Rockstar Games/GTA2}"
PRIMARY_MONITOR="${PRIMARY_MONITOR:-DP-2}"   # the monitor GTA2 should use (xrandr/hyprctl name)
export WINEPREFIX

# Remix: prefer the local d3d9_remix.dll (the renamed Remix d3d9.dll)
export WINEDLLOVERRIDES="d3d9_remix=n,b"

# Use the NVIDIA GPU and NVAPI (avoids Intel iGPU / Mesa conflicts)
export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export VK_DRIVER_FILES=/usr/share/vulkan/icd.d/nvidia_icd.json
export DXVK_ENABLE_NVAPI=1
export WINE_DISABLE_HARDWARE_SCHEDULING=1

# Wine takes the first Xwayland output as primary. If that is a rotated screen, the game
# window ends up off-screen. Make the wanted monitor primary.
xrandr --output "$PRIMARY_MONITOR" --primary >/dev/null 2>&1 || true

cd "$GAME_DIR"

# GTA2 stops drawing when its own window loses keyboard focus -> hand focus back.
( sleep 8; exec "$SCRIPT_DIR/gta2-focus-keeper.sh" ) >/dev/null 2>&1 &

# VRR makes the whole picture flicker with this game's frame pacing: off while it runs.
OLD_VRR=$(hyprctl getoption misc:vrr 2>/dev/null | awk '/int:/{print $2}')
hyprctl eval 'hl.config({ misc = { vrr = 0 } })' >/dev/null 2>&1 || true
trap 'hyprctl eval "hl.config({ misc = { vrr = ${OLD_VRR:-1} } })" >/dev/null 2>&1' EXIT

wine gta2.exe "$@"
