#!/bin/bash

# Usage: ./get_liturgical_info.sh [YYYY-MM-DD]
# If no date is provided, it defaults to today.

DATE=${1:-$(date +%F)}
API_URL="https://www.missalemeum.com/en/api/v5/proper/$DATE?variant=a4&index=0"

# Fetch data from Missale Meum API
RESPONSE=$(curl -s -X GET -H "accept: application/json" "$API_URL")

# Check if response is valid JSON
if ! echo "$RESPONSE" | jq empty 2>/dev/null; then
  echo "Error: API response is not valid JSON. Raw response:"
  echo "$RESPONSE"
  exit 1
fi

# Extract raw color code and celebration title
RAW_COLOR=$(echo "$RESPONSE" | jq -r '.[0].info.colors[0]')
TITLE=$(echo "$RESPONSE" | jq -r '.[0].info.title')

# Map color code to full name
case "$RAW_COLOR" in
  w) COLOR="White" ;;
  r) COLOR="Red" ;;
  g) COLOR="Green" ;;
  v) COLOR="Violet" ;;
  b) COLOR="Black" ;;
  p) COLOR="Rose" ;;
  *) COLOR="Unknown ($RAW_COLOR)" ;;
esac

# Output results
echo "Date: $DATE"
echo "Liturgical Color: $COLOR"
echo "Celebration: $TITLE"
