#!/bin/bash

MESSAGE=$1
EMAIL="kapilskumbhare@gmail.com"
REPORT=~/monitor/logs/system_report.txt

echo "=============================="
echo "ALERT SYSTEM"
echo "=============================="

echo "ALERT: $MESSAGE"

# Create logs directory if missing
mkdir -p ~/monitor/logs

# Save alert log
echo "$(date) - ALERT: $MESSAGE" >> ~/monitor/logs/alert.log

# Send email with attachment
echo "$MESSAGE" | mail -s "Linux Monitoring Alert" -A "$REPORT" "$EMAIL"
