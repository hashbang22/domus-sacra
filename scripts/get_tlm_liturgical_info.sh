#!/bin/bash
#
# get_tlm_liturgical_info.sh
# Fetches liturgical info from Missale Meum and optionally outputs JSON

set -euo pipefail

# Defaults
JSON_FLAG=false
PREVIEW_FLAG=false
DATE=$(date +"%Y-%m-%d")

# Handle arguments
for arg in "$@"; do
  case "$arg" in
    --json)
      JSON_FLAG=true
      ;;
    --preview)
      PREVIEW_FLAG=true
      ;;
    --date=*)
      DATE="${arg#--date=}"
      ;;
    *)
      echo "Unknown option: $arg"
      echo "Usage: $0 [--json] [--preview] [--date=YYYY-MM-DD]"
      exit 1
      ;;
  esac
done

# Paths and filenames
SCRIPT_DIR="$(dirname "$0")"
OUTPUT_DIR="$SCRIPT_DIR/../data"
DATE_FILE="$OUTPUT_DIR/tlm_liturgical_color_${DATE}.json"
TODAY_FILE="$OUTPUT_DIR/tlm_liturgical_color_today.json"
URL="https://www.missalemeum.com/en/$DATE"

mkdir -p "$OUTPUT_DIR"

# Fetch and parse
PAGE_CONTENT=$(curl -s "$URL")
COLOR=$(echo "$PAGE_CONTENT" | grep -oP '\b(White|Red|Green|Violet|Black|Rose|Gold)\b(?= vestments)')

if [ -z "$COLOR" ]; then
  echo "No vestment color found for $DATE."
  exit 1
fi

# Construct JSON
JSON_OUTPUT="{\"date\": \"$DATE\", \"color\": \"$COLOR\"}"

# Write files unless in preview mode
if [ "$PREVIEW_FLAG" = false ]; then
  echo "$JSON_OUTPUT" > "$DATE_FILE"
  if [[ "$DATE" == "$(date +%Y-%m-%d)" ]]; then
    echo "$JSON_OUTPUT" > "$TODAY_FILE"
  fi
fi

# Output to console
if [ "$JSON_FLAG" = true ]; then
  echo "$JSON_OUTPUT"
else
  echo "Liturgical color for $DATE: $COLOR"
  if [ "$PREVIEW_FLAG" = false ]; then
    echo "Saved:"
    echo " - $DATE_FILE"
    if [[ "$DATE" == "$(date +%Y-%m-%d)" ]]; then
      echo " - $TODAY_FILE (canonical today snapshot)"
    fi
  else
    echo "(Preview mode: no files written)"
  fi
fi
