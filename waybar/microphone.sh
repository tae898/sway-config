#!/bin/sh

mic_volume=$(/usr/bin/wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)

case "$mic_volume" in
    *MUTED*)
        printf '🚫\n'
        ;;
    "")
        printf '❓\n'
        ;;
    *)
        printf '🎤\n'
        ;;
esac