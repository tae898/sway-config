#!/bin/sh

mode=$1

is_connected() {
    target_type=$1
    /usr/bin/nmcli -t -f TYPE,STATE device status 2>/dev/null | /usr/bin/awk -F: -v target_type="$target_type" '$1==target_type && $2=="connected" {found=1} END {exit found ? 0 : 1}'
}

case "$mode" in
    wifi)
        if is_connected wifi; then
            printf '{"text":"📶","class":"connected","tooltip":"Wi-Fi connected"}\n'
        else
            printf '{"text":"📶","class":"disconnected","tooltip":"Wi-Fi disconnected"}\n'
        fi
        ;;
    ethernet)
        if is_connected ethernet; then
            printf '{"text":"🔌","class":"connected","tooltip":"Ethernet connected"}\n'
        else
            printf '{"text":"🔌","class":"disconnected","tooltip":"Ethernet disconnected"}\n'
        fi
        ;;
    *)
        printf '{"text":"?","class":"disconnected","tooltip":"Unknown network mode"}\n'
        exit 1
        ;;
esac