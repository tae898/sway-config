#!/bin/sh

input_method=$(/usr/bin/fcitx5-remote -n 2>/dev/null)

case "$input_method" in
    hangul)
        printf '🇰🇷\n'
        ;;
    keyboard-us)
        printf '🇺🇸\n'
        ;;
    "")
        printf '❓\n'
        ;;
    *)
        printf '⌨️\n'
        ;;
esac