#!/bin/sh

input_method=$(/usr/bin/fcitx5-remote -n 2>/dev/null)

case "$input_method" in
    hangul)
        printf '{"text":"🇰🇷","tooltip":"Korean (Hangul)"}\n'
        ;;
    keyboard-us)
        printf '{"text":"🇺🇸","tooltip":"English (US)"}\n'
        ;;
    "")
        printf '{"text":"❓","tooltip":"Unknown Input Method"}\n'
        ;;
    *)
        printf '{"text":"⌨️","tooltip":"%s"}\n' "$input_method"
        ;;
esac
