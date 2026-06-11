# Sway Notes

This repository documents the current working Sway setup on this machine. It reflects the final live configuration after the abandoned IBus and plain-XKB experiments were removed.

## Live files

These are the config files that currently matter.

- `~/.config/sway/config`
- `~/.config/waybar/config.jsonc`
- `~/.config/waybar/style.css`
- `~/.config/waybar/weather.sh`
- `~/.config/waybar/input-method.sh`
- `~/.config/waybar/microphone.sh`
- `~/.config/foot/foot.ini`
- `~/.config/environment.d/90-fcitx5.conf`
- `~/.config/fcitx5/profile`
- `~/.config/mako/config`

## Tracked copies in this repo

This repository now stores curated copies of the live config files so it can be used as both documentation and a real backup of the setup.

- `sway/config`
- `waybar/config.jsonc`
- `waybar/style.css`
- `waybar/weather.sh`
- `waybar/input-method.sh`
- `waybar/microphone.sh`
- `mako/config`
- `foot/foot.ini`
- `environment.d/90-fcitx5.conf`
- `fcitx5/profile`

## Removed files

These were created during earlier attempts and intentionally removed from the final setup.

- `~/.config/environment.d/90-ibus.conf`
- `~/.config/fcitx5/conf/imselector.conf`
- `~/.config/fcitx5/config`

## Display

- External displays are configured by `sway/apply-output-modes.sh`, which queries Sway outputs, skips internal `eDP-*` panels, and applies the highest available resolution and refresh rate for each connected external output.
- Internal display `eDP-1` is pinned to `scale 1.5`.
- Reason: reloads were resetting the live scale back to `2.0` until it was made persistent in config.

```conf
output eDP-1 scale 1.5
exec_always sh ~/.config/sway/apply-output-modes.sh
```

## Shortcuts

- `Mod` in the default Sway config is `Super`.
- The list below focuses on the active shortcuts that matter most in this setup.

### Session and app launch

- `Super+Return`: open terminal (`foot`)
- `Super+d`: open app launcher (`wofi`)
- `Super+Ctrl+v`: open clipboard history in `wofi` and copy the chosen entry back to the regular and primary clipboards
- `Super+Shift+c`: reload Sway config
- `Super+Escape`: lock screen with `swaylock`
- `Super+Shift+e`: exit/logout from Sway with confirmation

### Focus and moving windows

- `Super+h` / `Super+j` / `Super+k` / `Super+l`: focus left / down / up / right
- `Super+Left` / `Super+Down` / `Super+Up` / `Super+Right`: same focus movement with arrow keys
- `Super+Shift+h` / `Super+Shift+j` / `Super+Shift+k` / `Super+Shift+l`: move focused window left / down / up / right
- `Super+Shift+Left` / `Super+Shift+Down` / `Super+Shift+Up` / `Super+Shift+Right`: same window movement with arrow keys
- `Super+Shift+q`: kill focused window

### Workspaces

- `Super+1` through `Super+0`: switch to workspaces 1 through 10
- `Super+Tab`: switch to the next workspace
- `Super+Shift+Tab`: switch to the previous workspace
- `Super+Shift+1` through `Super+Shift+0`: move the focused window to workspaces 1 through 10
- New workspaces are created on the currently focused output when you switch to a number/name that does not exist yet.

### Layout and container control

- `Super+b`: split horizontally
- `Super+v`: split vertically
- `Super+s`: stacking layout
- `Super+w`: tabbed layout
- `Super+e`: toggle split layout
- `Super+f`: fullscreen
- `Super+Shift+Space`: toggle floating
- `Super+Space`: toggle focus between tiling and floating areas
- `Super+a`: focus parent container
- `Super+left mouse drag`: move a floating window
- `Super+right mouse drag`: resize a floating window

### Scratchpad and resize mode

- `Super+Shift+-`: move focused window to scratchpad
- `Super+-`: show or cycle scratchpad windows
- `Super+r`: enter resize mode
- In resize mode: `h` or `Left` shrinks width, `l` or `Right` grows width, `k` or `Up` shrinks height, `j` or `Down` grows height, and `Return` or `Escape` leaves resize mode.

### Input method and lid handling

- `Ctrl+Space`: toggle `fcitx5` between US and Hangul
- `Shift+Space`: intentionally disabled with `nop`
- `wl-paste --watch cliphist store -max-items 1000` starts from Sway on startup and reload to keep clipboard history available across the session

### Hardware and screenshot keys

- `XF86AudioMute`: toggle speaker mute
- `XF86AudioLowerVolume`: volume down
- `XF86AudioRaiseVolume`: volume up
- `XF86AudioMicMute`: toggle mic mute
- `XF86MonBrightnessDown`: brightness down
- `XF86MonBrightnessUp`: brightness up
- `Print`: select a region and copy the screenshot to the clipboard

## Input

### Keyboard base layout and repeat

- Base Sway layout is plain `us`.
- Repeat delay is `250` ms.
- Repeat rate is `40`.

```conf
input type:keyboard {
    xkb_layout us
    repeat_delay 250
    repeat_rate 40
}
```

### Touchpad and gestures

- Touchpad has tap-to-click enabled.
- Disable-while-typing (`dwt`) is enabled.
- Swipe gestures are configured directly in Sway.

```conf
input type:touchpad {
        dwt enabled
        tap enabled
}

bindgesture swipe:3:left focus left
bindgesture swipe:3:down focus down
bindgesture swipe:3:up focus up
bindgesture swipe:3:right focus right
bindgesture swipe:4:up exec $menu
bindgesture swipe:4:down scratchpad show
bindgesture swipe:4:left workspace prev
bindgesture swipe:4:right workspace next
```

Meaning:

- three-finger swipes move focus
- four-finger up opens the app launcher
- four-finger down shows the scratchpad
- four-finger left/right moves to the previous/next workspace

### Korean input

- Korean input is provided by `fcitx5` with `fcitx5-hangul`.
- This machine no longer uses `ibus`.
- `fcitx5` starts from Sway on login.
- `dbus-update-activation-environment` exports the required environment for Qt and XWayland apps.

```conf
exec /bin/sh -c '/usr/bin/pgrep -x fcitx5 >/dev/null || /usr/bin/fcitx5 -d'
exec_always /bin/sh -c '/usr/bin/dbus-update-activation-environment --systemd XMODIFIERS=@im=fcitx QT_IM_MODULE=fcitx QT_IM_MODULES="wayland;fcitx"'
```

Persistent environment file:

```ini
XMODIFIERS=@im=fcitx
QT_IM_MODULE=fcitx
QT_IM_MODULES=wayland;fcitx
```

Current `fcitx5` profile keeps both US and Hangul in one input group:

```ini
[Groups/0]
Name=Default
Default Layout=us
DefaultIM=hangul

[Groups/0/Items/0]
Name=keyboard-us
Layout=

[Groups/0/Items/1]
Name=hangul
Layout=us

[GroupOrder]
0=Default
```

Hotkey handling is owned by Sway, not by an extra `fcitx5` hotkey config file:

```conf
bindsym --locked Ctrl+space exec fcitx5-remote -t
bindsym --locked Shift+space nop
```

Meaning:

- `Ctrl+Space` toggles US/Hangul.
- `Shift+Space` is blocked to prevent the chooser popup.

### Media keys

- Volume keys use `wpctl`, not `pactl`.
- Reason: `pactl` was not installed, but PipeWire and `wpctl` were available.
- Brightness keys use `brightnessctl`.

```conf
bindsym --locked XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bindsym --locked XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bindsym --locked XF86AudioRaiseVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bindsym --locked XF86AudioMicMute exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
bindsym --locked XF86MonBrightnessDown exec brightnessctl set 5%-
bindsym --locked XF86MonBrightnessUp exec brightnessctl set 5%+
```

### Brightness permissions

- `brightnessctl` originally failed with `Permission denied`.
- Cause: the backlight device was group-owned by `video`, and the user was not in that group.
- Fix: add the user to `video` and log out/in again.

```bash
sudo usermod -aG video "$USER"
```

## Terminal

- Default terminal is `foot`.
- Foot font size is set to `11` because the default text looked too small on the HiDPI display.
- Foot now uses an explicit light color palette instead of the terminal default dark theme.
- `Super+Shift+c` only reloads Sway. It does not reload Foot colors for existing terminal windows.
- To apply Foot color changes, start a new Foot instance. If needed, stop the server first with `pkill foot`.

```ini
[main]
font=monospace:size=11

[colors]
foreground=4c4f69
background=eff1f5
selection-foreground=eff1f5
selection-background=7287fd
urls=1e66f5

regular0=5c5f77
regular1=d20f39
regular2=40a02b
regular3=df8e1d
regular4=1e66f5
regular5=ea76cb
regular6=179299
regular7=acb0be

bright0=6c6f85
bright1=d20f39
bright2=40a02b
bright3=df8e1d
bright4=1e66f5
bright5=ea76cb
bright6=179299
bright7=bcc0cc
```

## Bar

### Overview

- `waybar` now provides the top bar instead of the built-in `swaybar`.
- Sway starts `waybar` with `exec_always`, so a Sway config reload also restarts the bar.
- The `tray` module is now handled by Waybar, which is why `nm-applet --indicator` is started from Sway.
- The bar keeps the same core status set: brightness, speaker volume, mic state, battery, network, weather, clock, input-method flag, and tray icons.
- The old `swaybar` wrapper and `i3status` files were removed because they are no longer used.
- The bar no longer hardcodes a fixed height; Waybar now sizes itself from font and padding so it adapts better when switching monitors.

```conf
exec_always /bin/sh -c '/usr/bin/pkill -x waybar; /usr/bin/waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css'
```

### Modules

- Built-in Waybar modules handle workspaces, the focused window title, brightness, speaker volume, battery, network, clock, and the tray.
- Mic state is shown in its own pill through `waybar/microphone.sh`.
- Workspaces stay on the left, the focused window title sits in the middle area, and the status modules stay on the right.
- The tray is now a native Waybar tray instead of the old `swaybar` tray.

```jsonc
{
    "modules-left": ["sway/workspaces", "sway/mode", "sway/window"],
    "modules-right": ["backlight", "pulseaudio", "custom/microphone", "custom/network-wifi", "custom/network-ethernet", "custom/weather", "clock", "custom/input-method", "battery", "tray"]
}
```

### Custom script behavior

- `waybar/weather.sh` keeps the old `wttr.in` cache logic and refreshes at most every 15 minutes.
- `waybar/input-method.sh` maps `fcitx5-remote -n` to `🇺🇸`, `🇰🇷`, `❓`, or `⌨️`.
- `waybar/microphone.sh` maps the default audio source state to `🎤`, `🚫`, or `❓`.
- `waybar/network.sh` renders Wi-Fi and Ethernet as separate pills by checking `nmcli` for each device type.
- Clicking the microphone pill toggles mute on the default audio source through `wpctl`.
- Weather still reads from `~/.cache/sway-weather.txt`, so no extra cache migration was needed.
- Battery styling is now handled by Waybar states and CSS instead of rewriting the i3bar JSON stream.

Expected bar shape:

```text
workspace buttons | window title | ☀️ 50% | 🔊 35% or 🔇 muted | 🎤 or 🚫 | 📶 | 🔌 | ☀️ +17°C | 🕒 Wed: 2026-05-27 09:59:22 | 🇺🇸 or 🇰🇷 | 🔋 80% | tray
```

Low-battery example:

```text
workspace buttons | window title | ☀️ 50% | 🔊 35% | 🎤 | 📶 | 🔌 | ☀️ +17°C | 🕒 Wed: 2026-05-27 09:59:22 | 🇺🇸 | 🪫 14% | tray
```

## Notifications

- Notification daemon is `mako`.
- A user config was added so notifications appear centered at the top of the screen, not top-right and not center-screen.

```conf
anchor=top-center
```

Reload command:

```bash
makoctl reload
```

## Power and lid behavior

### Sway idle handling

- `swayidle` is started directly from the Sway config.
- After 10 minutes of inactivity, the session locks with `swaylock`.
- After 20 minutes of inactivity, Sway powers off outputs and turns them back on again when activity resumes.
- Before system sleep, `swayidle` locks the session first.

```conf
exec swayidle -w \
                                 timeout 600 'swaylock -f -c 000000' \
                                 timeout 1200 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' \
                                 before-sleep 'swaylock -f -c 000000'
```

### Logind defaults currently in effect

- A local `systemd-logind` override is tracked in `systemd/logind.conf.d/ignore-lid-on-ac.conf`.
- That override sets `HandleLidSwitchExternalPower=ignore`.
- Lid close on battery follows the system default: `suspend`.
- Lid close while on external power is overridden to `ignore`.
- Docked lid close remains ignored by the system default.
- Other logind actions remain at their system defaults: power key `poweroff`, suspend key `suspend`, hibernate key `hibernate`, idle action `ignore`.

### Manual lock shortcut

- A manual lock shortcut is configured in Sway.

```conf
bindsym $mod+Escape exec swaylock -f -c 000000
```

- Shortcut: `Super+Escape`
- Action: immediately lock the session with `swaylock`

### External monitor and lid close

- Logind is configured to ignore lid close on external power, while battery and docked behavior stay at their defaults.
- A Sway lid-switch hook handles the laptop panel directly:

```conf
bindswitch --locked lid:on output eDP-1 disable
bindswitch --locked lid:off output eDP-1 enable
```

- Closing the lid disables `eDP-1` inside Sway.
- Reopening the lid re-enables `eDP-1`.
- On battery, logind may also suspend the machine when the lid closes.
- On external power, logind ignores the lid-close event.
- Once `eDP-1` is disabled, Sway can move those workspaces onto the remaining active output.
- Windows are not destroyed.
- Reopening the lid does not guarantee the previous workspace arrangement will be restored automatically.

## Screenshots

- `Print` no longer saves a full-screen screenshot to disk.
- `Print` now opens region selection with `slurp`, captures with `grim`, and copies the PNG directly to the Wayland clipboard with `wl-copy`.
- No screenshot file is written to disk.

```conf
bindsym Print exec sh -c 'region=$(slurp) || exit 0; grim -g "$region" - | wl-copy --type image/png'
```

## Window management

- Scratchpad send: `Super+Shift+-`
- Scratchpad show: `Super+-`
- Floating toggle: `Super+Shift+Space`
- Focus tiling/floating area: `Super+Space`
- Resize mode: `Super+r`

Resize keys in resize mode:

- `h` shrink width
- `l` grow width
- `k` shrink height
- `j` grow height
- arrow keys also work

## Autostart

### Insync

- Insync no longer relies on desktop autostart.
- Sway starts Insync directly on login.
- The command is guarded so it does not launch duplicates.

```conf
exec /bin/sh -c '/usr/bin/pgrep -x insync >/dev/null || /usr/bin/insync start --no-daemon'
```

### Fcitx5

- `fcitx5` is started directly from Sway.
- Because it starts on login, its tray icon appears in the top-right tray area.
- That tray icon only means `fcitx5` is running.
- The status-line flag is the actual US/KR mode indicator.

### NetworkManager applet

- `nm-applet --indicator` is started directly from Sway.
- It is intended to live in the Waybar tray.
- This change was made because the applet was not reliably clickable in the old `swaybar` tray setup.

```conf
exec /usr/bin/nm-applet --indicator
```

## Final state summary

What changed from stock setup:

- persistent `eDP-1 scale 1.5`
- faster key repeat
- `foot` font size increased
- volume keys switched to `wpctl`
- brightness keys switched to `brightnessctl`
- user added to `video` group so brightness control works
- `waybar` replaced the old `swaybar` and `i3status` setup completely
- bar keeps brightness, speaker volume, mic state, weather, battery, network, clock, tray icons, and the active input-language flag
- `nm-applet --indicator` now autostarts for the Waybar tray
- Insync autostarts from Sway instead of XDG desktop autostart
- Korean input migrated from abandoned `ibus` attempts to working `fcitx5-hangul`
- `Ctrl+Space` is the only intended input toggle
- `Shift+Space` is blocked to prevent the chooser popup
- `Super+Escape` manually locks the screen
- notifications use `mako` with `top-center` placement
- `Print` copies a selected screenshot region to the clipboard instead of saving to disk

## Useful checks

```bash
swaymsg -t get_outputs
swaymsg -t get_inputs
pgrep -a waybar
pgrep -a nm-applet
brightnessctl info
wpctl status
pgrep -a insync
pgrep -a fcitx5
fcitx5-remote -n
pgrep -a mako
sed -n '1p' ~/.cache/sway-weather.txt
wl-paste --list-types
```
