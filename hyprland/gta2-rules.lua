-- Hyprland (Lua config) window rules for GTA2 + RTX Remix under Wine.
-- Put in your config (e.g. host.lua / hyprland.lua) and adjust the monitor name.
-- With own_window=1 the game has one window; the Remix bridge opens an unused second one.
hl.window_rule({name = "gta2-wine", match = {class = "^gta2\\.exe$"},
    monitor = "DP-2", fullscreen = true, opaque = true, no_blur = true, no_shadow = true})
hl.window_rule({name = "gta2-remix-bridge", match = {class = "^nvremixbridge\\.exe$"},
    float = true, workspace = "special:gtabg silent", no_initial_focus = true, opaque = true, no_blur = true})
