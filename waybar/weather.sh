#!/bin/sh

weather_cache_file="${XDG_CACHE_HOME:-$HOME/.cache}/sway-weather.txt"
weather_cache_ttl=900

now=$(/bin/date +%s)
if [ -r "$weather_cache_file" ]; then
    cache_mtime=$(/bin/date -r "$weather_cache_file" +%s 2>/dev/null || printf '0')
else
    cache_mtime=0
fi

if [ $((now - cache_mtime)) -ge "$weather_cache_ttl" ]; then
    /bin/mkdir -p "$(/usr/bin/dirname "$weather_cache_file")"
    weather_text=$(/usr/bin/curl -fsS --max-time 3 'https://wttr.in/?format=3' 2>/dev/null | /usr/bin/tr -d '\r' | /usr/bin/sed 's/^[^:]*: //; s/  */ /g')
    if [ -n "$weather_text" ]; then
        printf '%s\n' "$weather_text" > "$weather_cache_file"
    fi
fi

if [ -r "$weather_cache_file" ]; then
    /usr/bin/sed -n '1p' "$weather_cache_file"
else
    printf 'n/a\n'
fi