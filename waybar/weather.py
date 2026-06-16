#!/usr/bin/env python3
import os
import sys
import json
import time
import urllib.request

CACHE_FILE = os.path.expanduser("~/.cache/sway-weather-j1.json")
CACHE_TTL = 900 # 15 minutes

WEATHER_CODES = {
    "113": "☀️", "116": "⛅", "119": "☁️", "122": "☁️", "143": "🌫️",
    "176": "🌦️", "179": "🌨️", "182": "🌨️", "185": "🌨️", "200": "⛈️",
    "227": "🌬️", "230": "❄️", "248": "🌫️", "260": "🌫️", "263": "🌦️",
    "266": "🌧️", "281": "🌧️", "284": "🌧️", "293": "🌦️", "296": "🌧️",
    "299": "🌧️", "302": "🌧️", "305": "🌧️", "308": "🌧️", "311": "🌧️",
    "314": "🌧️", "317": "🌨️", "320": "🌨️", "323": "🌨️", "326": "🌨️",
    "329": "🌨️", "332": "🌨️", "335": "🌨️", "338": "🌨️", "350": "🌨️",
    "353": "🌦️", "356": "🌧️", "359": "🌧️", "362": "🌨️", "365": "🌨️",
    "368": "🌨️", "371": "🌨️", "374": "🌨️", "377": "🌨️", "386": "⛈️",
    "389": "⛈️", "392": "⛈️", "395": "⛈️"
}

def get_emoji(code):
    return WEATHER_CODES.get(code, "🌡️")

def fetch_weather():
    try:
        req = urllib.request.Request(
            "https://wttr.in/?format=j1",
            headers={"User-Agent": "Mozilla/5.0"}
        )
        with urllib.request.urlopen(req, timeout=5) as response:
            return response.read().decode("utf-8")
    except Exception:
        return None

def main():
    now = time.time()
    data_str = None
    
    # Try reading from cache
    if os.path.exists(CACHE_FILE):
        mtime = os.path.getmtime(CACHE_FILE)
        if now - mtime < CACHE_TTL:
            try:
                with open(CACHE_FILE, "r") as f:
                    data_str = f.read()
            except Exception:
                pass

    # If cache is missing or stale, fetch fresh
    if not data_str:
        fresh_data = fetch_weather()
        if fresh_data:
            data_str = fresh_data
            try:
                os.makedirs(os.path.dirname(CACHE_FILE), exist_ok=True)
                with open(CACHE_FILE, "w") as f:
                    f.write(data_str)
            except Exception:
                pass
        else:
            # Fallback to stale cache if fetch fails
            if os.path.exists(CACHE_FILE):
                try:
                    with open(CACHE_FILE, "r") as f:
                        data_str = f.read()
                except Exception:
                    pass

    if not data_str:
        print(json.dumps({"text": "n/a", "tooltip": "Weather unavailable"}))
        return

    try:
        data = json.loads(data_str)
        curr = data["current_condition"][0]
        temp = curr["temp_C"]
        code = curr["weatherCode"]
        emoji = get_emoji(code)
        
        area = data["nearest_area"][0]
        city = area["areaName"][0]["value"]
        region = area["region"][0]["value"]
        
        text = f"{emoji} {temp}°C"
        
        tooltip_lines = [
            f"📍 {city}, {region}",
            ""
        ]
        
        hourly = data["weather"][0]["hourly"]
        for h in hourly:
            t = int(h["time"])
            time_str = f"{t//100:02d}:00"
            h_temp = h["tempC"]
            h_code = h["weatherCode"]
            h_emoji = get_emoji(h_code)
            h_desc = h["weatherDesc"][0]["value"]
            tooltip_lines.append(f"{time_str}  {h_emoji}  {h_temp}°C  ({h_desc})")
            
        tooltip = "\n".join(tooltip_lines)
        
        print(json.dumps({
            "text": text,
            "tooltip": tooltip
        }))
    except Exception as e:
        print(json.dumps({"text": "err", "tooltip": f"Error parsing weather: {str(e)}"}))

if __name__ == "__main__":
    main()
