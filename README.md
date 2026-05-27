# Sway Notes

This repository documents the current working Sway setup on this machine. It reflects the final live configuration after the abandoned IBus and plain-XKB experiments were removed.

## Live files

These are the config files that currently matter.

- `~/.config/sway/config`
- `~/.config/sway/status.sh`
- `~/.config/i3status/config`
- `~/.config/foot/foot.ini`
- `~/.config/environment.d/90-fcitx5.conf`
- `~/.config/fcitx5/profile`
- `~/.config/mako/config`

## Tracked copies in this repo

This repository now stores curated copies of the live config files so it can be used as both documentation and a real backup of the setup.

- `sway/config`
- `sway/status.sh`
- `i3status/config`
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

- Internal display `eDP-1` is pinned to `scale 1.5`.
- Reason: reloads were resetting the live scale back to `2.0` until it was made persistent in config.

```conf
output eDP-1 scale 1.5
```

## Shortcuts

- `Mod` in the default Sway config is `Super`.
- The list below focuses on the active shortcuts that matter most in this setup.

### Session and app launch

- `Super+Return`: open terminal (`foot`)
- `Super+d`: open app launcher (`wofi`)
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
- Closing the lid triggers `bindswitch` to disable `eDP-1`
- Opening the lid triggers `bindswitch` to re-enable `eDP-1`

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
exec sh -c 'pgrep -x fcitx5 >/dev/null || fcitx5 -d'
exec_always sh -c 'dbus-update-activation-environment --systemd XMODIFIERS=@im=fcitx QT_IM_MODULE=fcitx QT_IM_MODULES="wayland;fcitx"'
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
- Foot font size was increased because the default text looked too small on the HiDPI display.
- Foot now uses an explicit light color palette instead of the terminal default dark theme.
- `Super+Shift+c` only reloads Sway. It does not reload Foot colors for existing terminal windows.
- To apply Foot color changes, start a new Foot instance. If needed, stop the server first with `pkill foot`.

```ini
[main]
font=monospace:size=12

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

- The built-in `swaybar` is still used.
- `swaybar` runs `~/.config/sway/status.sh`, which wraps `i3status`.
- The wrapper adds brightness, mic state, weather, and the input-method flag from `fcitx5`.
- The `fcitx5` tray icon near Insync is separate from the text flag in the status line.

```conf
bar {
    position top
    status_command sh ~/.config/sway/status.sh

    colors {
        statusline #ffffff
        background #323232
        inactive_workspace #32323200 #32323200 #5c5c5c
    }
}
```

### i3status

- `i3status` updates every second.
- Native `i3status` modules currently shown:
  - volume
  - battery
  - clock

```conf
general {
        colors = true
        interval = 1
        output_format = "i3bar"
}

order += "volume master"
order += "battery all"
order += "tztime local"

volume master {
        format = "🔊 %volume"
        format_muted = "🔇 muted"
        device = "default"
        mixer = "Master"
        mixer_idx = 0
}

battery all {
        format = "%status %percentage"
        format_down = "🔋 n/a"
        status_chr = "⚡"
        status_bat = "🔋"
        status_full = "🔌"
        status_idle = "⏸️"
        status_unk = "❓"
        low_threshold = 20
}

tztime local {
        format = "🕒 %a: %Y-%m-%d %H:%M:%S"
}
```

- `%a` adds the abbreviated weekday, for example `Wed`.

### Wrapper script behavior

- Adds brightness as `☀️ <percent>`.
- Adds mic state as `🎤` when active, `🚫` when muted, `❓` if unknown.
- Keeps battery states visually distinct: charging `⚡`, discharging `🔋`, idle `⏸️`, full `🔌`, unknown `❓`.
- Rewrites the battery item to `🪫 <percent>` when capacity drops below 20%.
- The low-battery threshold is controlled in the wrapper with `LOW_BATTERY_THRESHOLD`, defaulting to `20`.
- Adds weather between the battery block and the clock.
- Weather is fetched from `wttr.in` with `?format=3`.
- The current setup does not use a manually selected city.
- Location is inferred by `wttr.in` from the public IP address of the request.
- Weather results are cached for 15 minutes in `~/.cache/sway-weather.txt` to avoid doing a network request every second.
- Adds input-method flag as:
  - `🇺🇸` for `keyboard-us`
  - `🇰🇷` for `hangul`
- The flag is appended at the end of the status list, so it appears to the right of the time and immediately left of the tray icons.

Expected bar shape:

```text
☀️ 50% | 🎤 or 🚫 | 🔊 35% or 🔇 muted | ⏸️ 80.48% | ☀️ +17°C | 🕒 Wed: 2026-05-27 09:59:22 | 🇺🇸 or 🇰🇷
```

Low-battery example:

```text
☀️ 50% | 🎤 or 🚫 | 🔊 35% or 🔇 muted | 🪫 14% | ☀️ +17°C | 🕒 2026-05-27 09:59:22 | 🇺🇸 or 🇰🇷
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
- After 5 minutes of inactivity, the session locks with `swaylock`.
- After 10 minutes of inactivity, Sway turns the displays off.
- On activity resume, the displays are turned back on.
- Before system sleep, `swayidle` locks the session first.

```conf
exec swayidle -w \
                                 timeout 300 'swaylock -f -c 000000' \
                                 timeout 600 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' \
                                 before-sleep 'swaylock -f -c 000000'
```

### Logind defaults currently in effect

- There are no local `systemd-logind` overrides configured for lid/power behavior.
- The machine is using the default logind actions: lid close `suspend`, lid close while docked `ignore`, power key `poweroff`, suspend key `suspend`, hibernate key `hibernate`, idle action `ignore`.

### Manual lock shortcut

- A manual lock shortcut is configured in Sway.

```conf
bindsym $mod+Escape exec swaylock -f -c 000000
```

- Shortcut: `Super+Escape`
- Action: immediately lock the session with `swaylock`

### External monitor and lid close

- Docked lid close is still ignored by logind.
- A Sway lid-switch hook now handles the laptop panel directly:

```conf
bindswitch --locked lid:on output eDP-1 disable
bindswitch --locked lid:off output eDP-1 enable
```

- Closing the lid disables `eDP-1` inside Sway.
- Reopening the lid re-enables `eDP-1`.
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
exec sh -c 'pgrep -x insync >/dev/null || insync start --no-daemon'
```

### Fcitx5

- `fcitx5` is started directly from Sway.
- Because it starts on login, its tray icon appears in the top-right tray area.
- That tray icon only means `fcitx5` is running.
- The status-line flag is the actual US/KR mode indicator.

## Final state summary

What changed from stock setup:

- persistent `eDP-1 scale 1.5`
- faster key repeat
- `foot` font size increased
- volume keys switched to `wpctl`
- brightness keys switched to `brightnessctl`
- user added to `video` group so brightness control works
- built-in `swaybar` kept, but wrapped with `status.sh`
- bar shows brightness, mic state, weather, and active input-language flag
- battery states are visually distinct, including a separate low-battery icon below 20%
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
brightnessctl info
wpctl status
pgrep -a insync
pgrep -a fcitx5
fcitx5-remote -n
pgrep -a mako
sed -n '1p' ~/.cache/sway-weather.txt
wl-paste --list-types
```
