#!/bin/bash
#
# mqtt_publish.sh
# Publishes liturgical color JSON to an MQTT broker

set -euo pipefail

# 🛠️ Configuration — override via env vars if needed
INPUT_FILE="${INPUT_FILE:-$(dirname "$0")/../data/tlm_liturgical_color_today}"
MQTT_HOST="${MQTT_HOST:-localhost}"
MQTT_PORT="${MQTT_PORT:-1883}"
MQTT_TOPIC="${MQTT_TOPIC:-tlm/color}"

# 🧪 Check for input file
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: Input file not found: $INPUT_FILE"
    exit 1
fi

# 📄 Read and validate payload
PAYLOAD=$(cat "$INPUT_FILE")
if [[ -z "$PAYLOAD" ]]; then
    echo "Warning: JSON payload is empty — not publishing"
    exit 0
fi

echo "Publishing to MQTT topic '$MQTT_TOPIC' on $MQTT_HOST:$MQTT_PORT"
mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -t "$MQTT_TOPIC" -m "$PAYLOAD" -r -d
