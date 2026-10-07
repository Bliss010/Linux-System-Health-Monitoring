#!/bin/bash

# ==============================
# System Health Monitoring Script
# ==============================
# Description: Monitors CPU, Memory, Disk, and Process usage.
# Alerts when thresholds are exceeded.
# ==============================
# Threshold values
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=80
PROC_THRESHOLD=250

# Log file path
LOG_FILE="/var/log/system_health.log"

# Create log file if not exists
sudo touch $LOG_FILE
sudo chmod 644 $LOG_FILE

# Function to log alerts
log_alert() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ALERT: $1" | tee -a $LOG_FILE
}

echo "==============================="
echo " System Health Monitoring Report "
echo "==============================="

# CPU Usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
CPU_USAGE=${CPU_USAGE%.*}  # Convert to integer
echo "CPU Usage: $CPU_USAGE%"

if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
    log_alert "CPU usage is above threshold! Current: $CPU_USAGE%"
fi

# Memory Usage
MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
MEM_USAGE=${MEM_USAGE%.*}
echo "Memory Usage: $MEM_USAGE%"

if [ "$MEM_USAGE" -gt "$MEM_THRESHOLD" ]; then
    log_alert "Memory usage is above threshold! Current: $MEM_USAGE%"
fi

# Disk Usage (root partition)
DISK_USAGE=$(df / | grep / | awk '{print $5}' | sed 's/%//')
echo "Disk Usage: $DISK_USAGE%"

if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    log_alert "Disk usage is above threshold! Current: $DISK_USAGE%"
fi

# Running Processes
PROC_COUNT=$(ps aux --no-heading | wc -l)
echo "Running Processes: $PROC_COUNT"

if [ "$PROC_COUNT" -gt "$PROC_THRESHOLD" ]; then
    log_alert "Too many running processes! Current: $PROC_COUNT"
fi

echo "Monitoring completed successfully!"
echo "Logs saved at: $LOG_FILE"
