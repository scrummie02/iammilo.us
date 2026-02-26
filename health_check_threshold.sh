#!/bin/bash

cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
ram_usage=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2 }')
disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

alert=0

if awk "BEGIN {exit !($cpu_usage > 80)}"; then alert=1; fi
if awk "BEGIN {exit !($ram_usage > 80)}"; then alert=1; fi
if [ "$disk_usage" -gt 80 ]; then alert=1; fi

if [ $alert -eq 1 ]; then
    echo "🚨 System Resource Alert!"
    echo "CPU Usage: $cpu_usage%"
    echo "RAM Usage: $ram_usage%"
    echo "Disk Usage (Root): $disk_usage%"
fi