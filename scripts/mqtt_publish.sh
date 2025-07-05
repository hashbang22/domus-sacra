#!/bin/bash

COLOR=$(cat /home/mikeda/liturgical_calendar/1962_liturgical_color_today)
echo "The color is $COLOR"

# Ensure we don't send an empty message
if [[ -z "$COLOR" ]]; then
    COLOR="Unknown"
fi

echo "Color is now $COLOR"

mosquitto_pub -h localhost -t "1962liturgical/color" -m "$COLOR" -d

