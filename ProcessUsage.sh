#!/bin/bash
# ProcessUsage.sh
# Author: Neel Patel
# Description: Finds top 5 processes by CPU usage, confirms before killing non-root ones, and logs activity.

# Get current date for log file
LOG_FILE="$HOME/ProcessUsageReport-$(date +%Y-%m-%d).log"

echo "Checking top 5 CPU consuming processes..."
echo

# Display top 5 processes sorted by CPU usage
TOP_PROCESSES=$(ps -eo pid,user,comm,%cpu,lstart --sort=-%cpu | head -n 6)
echo "$TOP_PROCESSES"
echo

read -p "Do you want to kill non-root processes from the above list? (y/n): " confirm

if [[ $confirm != "y" && $confirm != "Y" ]]; then
    echo "Exiting without killing any process."
    exit 0
fi

echo "--------------------------------------------------" >> "$LOG_FILE"
echo "Process Usage Report - $(date)" >> "$LOG_FILE"
echo "--------------------------------------------------" >> "$LOG_FILE"

KILLED_COUNT=0

# Get the top 5 processes excluding the header
ps -eo pid,user,comm,%cpu,lstart --sort=-%cpu | head -n 6 | tail -n 5 | while read pid user comm cpu l1 l2 l3 l4 l5; do
    if [[ "$user" != "root" ]]; then
        start_time="$l1 $l2 $l3 $l4 $l5"
        kill -9 "$pid" 2>/dev/null

        if [[ $? -eq 0 ]]; then
            dept=$(id -gn "$user" 2>/dev/null)
            echo "Username: $user" >> "$LOG_FILE"
            echo "Department (Primary Group): $dept" >> "$LOG_FILE"
            echo "Process Name: $comm" >> "$LOG_FILE"
            echo "Process ID: $pid" >> "$LOG_FILE"
            echo "Started At: $start_time" >> "$LOG_FILE"
            echo "Killed At: $(date)" >> "$LOG_FILE"
            echo "------------------------------------------" >> "$LOG_FILE"
            ((KILLED_COUNT++))
        fi
    fi
done

echo
echo "$KILLED_COUNT processes were killed. Log saved to $LOG_FILE."
