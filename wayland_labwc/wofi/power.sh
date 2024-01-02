#!/bin/bash

entries="⇠ Logout\n⏾ Suspend\n Reboot\n⏻ Shutdown"

selected=$(echo -e $entries|wofi --width 100 --height 150 --xoffset 1764 --dmenu --cache-file /dev/null -c /home/owl/.config/wofi/power -s /home/owl/.config/wofi/power.css | awk '{print tolower($2)}')

case $selected in
  logout)
    swaymsg exit;;
  suspend)
    exec systemctl suspend;;
  reboot)
    exec systemctl reboot;;
  shutdown)
    exec systemctl poweroff -i;;
esac
