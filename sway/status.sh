#!/bin/sh

weather_cache_file="${XDG_CACHE_HOME:-$HOME/.cache}/sway-weather.txt"
weather_cache_ttl=900
low_battery_threshold="${LOW_BATTERY_THRESHOLD:-20}"

get_network_text() {
    wifi_connected=0
    ethernet_connected=0

    if nmcli -t -f TYPE,STATE device status 2>/dev/null | awk -F: '$1=="wifi" && $2=="connected" {found=1} END {exit found ? 0 : 1}'; then
        wifi_connected=1
    fi

    if nmcli -t -f TYPE,STATE device status 2>/dev/null | awk -F: '$1=="ethernet" && $2=="connected" {found=1} END {exit found ? 0 : 1}'; then
        ethernet_connected=1
    fi

    if [ "$wifi_connected" -eq 1 ] && [ "$ethernet_connected" -eq 1 ]; then
        printf '📶🔌'
    elif [ "$wifi_connected" -eq 1 ]; then
        printf '📶'
    elif [ "$ethernet_connected" -eq 1 ]; then
        printf '🔌'
    else
        printf '⛔'
    fi
}

get_weather_text() {
    now=$(date +%s)
    if [ -r "$weather_cache_file" ]; then
        cache_mtime=$(date -r "$weather_cache_file" +%s 2>/dev/null || printf '0')
    else
        cache_mtime=0
    fi

    if [ $((now - cache_mtime)) -ge "$weather_cache_ttl" ]; then
        mkdir -p "$(dirname "$weather_cache_file")"
        weather_text=$(curl -fsS --max-time 3 'https://wttr.in/?format=3' 2>/dev/null | tr -d '\r' | sed 's/^[^:]*: //; s/  */ /g')
        if [ -n "$weather_text" ]; then
            printf '%s\n' "$weather_text" > "$weather_cache_file"
        fi
    fi

    if [ -r "$weather_cache_file" ]; then
        sed -n '1p' "$weather_cache_file"
    else
        printf 'n/a'
    fi
}

i3status --config "$HOME/.config/i3status/config" | while IFS= read -r line; do
    case "$line" in
        '{'*|'[')
            printf '%s\n' "$line"
            ;;
        *)
            brightness=$(brightnessctl -m 2>/dev/null | cut -d, -f4)
            [ -n "$brightness" ] || brightness="?%"
            battery_capacity=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null)
            network=$(get_network_text)
            weather=$(get_weather_text)
            input_method=$(fcitx5-remote -n 2>/dev/null)
            case "$input_method" in
                hangul) input_text="🇰🇷" ;;
                keyboard-us) input_text="🇺🇸" ;;
                "") input_text="❓" ;;
                *) input_text="⌨️" ;;
            esac
            mic_volume=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)
            case "$mic_volume" in
                *MUTED*) mic_text="🚫" ;;
                "" ) mic_text="❓" ;;
                * ) mic_text="🎤" ;;
            esac
            rendered_line=$(printf '%s\n' "$line" | sed "s/^\[/[{\"name\":\"brightness\",\"full_text\":\"☀️ $brightness\"},{\"name\":\"mic\",\"full_text\":\"$mic_text\"},/; s/^,\[/,[{\"name\":\"brightness\",\"full_text\":\"☀️ $brightness\"},{\"name\":\"mic\",\"full_text\":\"$mic_text\"},/; s/{\"name\":\"tztime\",/{\"name\":\"network\",\"full_text\":\"$network\"},{\"name\":\"weather\",\"full_text\":\"$weather\"},{\"name\":\"tztime\",/; s/\]$/,\{\"name\":\"input_method\",\"full_text\":\"$input_text\"\}]/")
            case "$battery_capacity" in
                ''|*[!0-9]*) ;;
                *)
                    if [ "$battery_capacity" -lt "$low_battery_threshold" ]; then
                        rendered_line=$(printf '%s\n' "$rendered_line" | sed 's/\("name":"battery"[^}]*"full_text":"\)[^"]* \([0-9.][0-9.]*%\)"/\1🪫 \2"/')
                    fi
                    ;;
            esac
            printf '%s\n' "$rendered_line"
            ;;
    esac
done