#!/bin/bash
#
# get_tlm_liturgical_color.sh
# Fetches today's liturgical color from Missale Meum and publishes it to MQTT

set -euo pipefail

TODAYS_DATE=$(date +"%Y-%m-%d")
URL="https://www.missalemeum.com/en/$TODAYS_DATE"
OUTPUT_DIR="$(dirname "$0")/../data"
OUTPUT_FILE="$OUTPUT_DIR/tlm_liturgical_color_today"
MQTT_HOST="${MQTT_HOST:-localhost}"
MQTT_TOPIC="${MQTT_TOPIC:-1962liturgical/color}"

mkdir -p "$OUTPUT_DIR"

PAGE_CONTENT=$(curl -s "$URL")
COLOR=$(echo "$PAGE_CONTENT" | grep -oP '\b(White|Red|Green|Violet|Black|Rose|Gold)\b(?= vestments)')

if [ -z "$COLOR" ]; then
    echo "No vestment color found for today ($TODAYS_DATE)."
    exit 1
else
    echo "Liturgical color for today ($TODAYS_DATE): $COLOR"
    echo "$COLOR" > "$OUTPUT_FILE"
fi

mosquitto_pub -h "$MQTT_HOST" -t "$MQTT_TOPIC" -m "$(cat "$OUTPUT_FILE")"
