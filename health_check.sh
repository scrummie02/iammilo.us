#!/bin/bash

# Function to check CPU usage
check_cpu_usage() {
    echo "CPU Usage:"
    top -bn1 | grep "Cpu(s)" | \
        sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \
        awk '{print 100 - $1"%"}'
}

# Function to check RAM usage
check_ram_usage() {
    echo "RAM Usage:"
    free -m | awk 'NR==2{printf "Mem: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }'
}

# Function to check disk space usage
check_disk_usage() {
    echo "Disk Space Usage (Root):"
    df -h / | awk 'NR==2 {print $5 " used, " $4 " free"}'
}

# Function to check network usage
check_network_usage() {
    echo "Network Usage:"
    ip -s link | head -n 15
}

# Main script starts here
echo "System Resource Usage Report"

check_cpu_usage
check_ram_usage
check_disk_usage
check_network_usage