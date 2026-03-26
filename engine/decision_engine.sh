#!/bin/bash


DATA_FILE="/tmp/system_data.txt"
REPORT="/tmp/system_report.txt"
EMAIL="kapilskumbhare@gmail.com"
ALERT_STATE="/tmp/alert_state.txt"

DISK=$(grep DISK "$DATA_FILE" | cut -d':' -f2)
CPU=$(grep CPU "$DATA_FILE" | cut -d':' -f2)
RAM=$(grep RAM "$DATA_FILE" | cut -d':' -f2)
SERVICE=$(grep SERVICE "$DATA_FILE" | cut -d':' -f2)
FAILED=$(grep FAILED_LOGINS "$DATA_FILE" | cut -d':' -f2)

PROBLEM="NONE"

# -----------------------------
# PROBLEM DETECTION
# -----------------------------

if [ "$DISK" -gt 80 ]; then
PROBLEM="High Disk Usage"
fi

if [ "$FAILED" -gt 10 ]; then
PROBLEM="Multiple Failed Login Attempts"
fi

if [ "$SERVICE" != "active" ]; then

PROBLEM="SSH Service Down"

ORIGINAL_SERVICE="$SERVICE"

bash /home/kapil/monitor/healing/self_healing.sh ssh

SERVICE="$ORIGINAL_SERVICE"

fi

# -----------------------------
# SELF HEALING
# -----------------------------

if [ "$PROBLEM" == "SSH Service Down" ]; then

echo "Running self healing..."
bash /home/kapil/monitor/healing/self_healing.sh ssh

sleep 2

SERVICE=$(systemctl is-active ssh)

fi


# -----------------------------
# REPORT
# -----------------------------

if [ "$PROBLEM" != "NONE" ]; then

    # Send alert only once
    if [ ! -f "$ALERT_STATE" ]; then

        echo "=============================" > "$REPORT"
        echo " SYSTEM MONITORING ALERT" >> "$REPORT"
        echo "=============================" >> "$REPORT"

        echo "Server Name : $(hostname)" >> "$REPORT"
        echo "Time        : $(date)" >> "$REPORT"
        echo "Problem     : $PROBLEM" >> "$REPORT"

        echo "" >> "$REPORT"

        echo "Disk Usage     : $DISK%" >> "$REPORT"
        echo "CPU Load       : $CPU" >> "$REPORT"
        echo "RAM Usage      : $RAM%" >> "$REPORT"
        echo "SSH Status     : $SERVICE" >> "$REPORT"
        echo "Failed Logins  : $FAILED" >> "$REPORT"

        mail -s "Linux Monitoring Alert - $PROBLEM" "$EMAIL" < "$REPORT"

        touch "$ALERT_STATE"

        echo "Alert mail sent"

    fi

else

    # Send recovery mail when system becomes normal
    if [ -f "$ALERT_STATE" ]; then

        echo "=============================" > "$REPORT"
        echo " SYSTEM RECOVERY REPORT" >> "$REPORT"
        echo "=============================" >> "$REPORT"

        echo "Server Name : $(hostname)" >> "$REPORT"
        echo "Time        : $(date)" >> "$REPORT"
        echo "Status      : System Back To Normal" >> "$REPORT"

        echo "" >> "$REPORT"

        echo "Disk Usage     : $DISK%" >> "$REPORT"
        echo "CPU Load       : $CPU" >> "$REPORT"
        echo "RAM Usage      : $RAM%" >> "$REPORT"
        echo "SSH Status     : $SERVICE" >> "$REPORT"
        echo "Failed Logins  : $FAILED" >> "$REPORT"

        mail -s "Linux Monitoring RECOVERY - System Normal" "$EMAIL" < "$REPORT"

        rm -f "$ALERT_STATE"

        echo "Recovery mail sent"

    fi

fi
