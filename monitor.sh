
#!/bin/bash

BASE_DIR="/home/kapil/monitor"
LOG_DIR="$BASE_DIR/logs"

LOG_FILE="$LOG_DIR/system_monitor.log"
DATA_FILE="/tmp/system_data.txt"
STATE_FILE="$LOG_DIR/security_last_position.txt"

AUTH_LOG="/var/log/auth.log"

mkdir -p "$LOG_DIR"

echo "=============================="
echo " Starting System Monitoring"
echo "=============================="

echo "$(date) Monitoring started" >> "$LOG_FILE"

# -----------------------------
# DISK USAGE
# -----------------------------
DISK=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

# -----------------------------
# CPU LOAD
# -----------------------------
CPU=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs)

# -----------------------------
# RAM USAGE
# -----------------------------
RAM=$(free | awk '/Mem:/ {printf("%.0f"), $3/$2 * 100}')

# -----------------------------
# SERVICE STATUS
# -----------------------------
SERVICE_STATUS=$(systemctl is-active ssh)

# ==========================================
# FAILED LOGIN ATTEMPTS (NEW ONLY)
# ==========================================

FAILED_LOGIN=$(sudo journalctl -u ssh --since "1 minute ago" 2>/dev/null | grep "Failed password" | wc -l)

# -----------------------------
# DISPLAY STATUS
# -----------------------------
echo "Current Disk Usage: $DISK%"
echo "Current CPU Load: $CPU"
echo "Current RAM Usage: $RAM%"
echo "Service ssh status: $SERVICE_STATUS"
echo "Failed login attempts (new): $FAILED_LOGIN"

# -----------------------------
# SAVE DATA FOR DECISION ENGINE
# -----------------------------
echo "DISK:$DISK" > "$DATA_FILE"
echo "CPU:$CPU" >> "$DATA_FILE"
echo "RAM:$RAM" >> "$DATA_FILE"
echo "SERVICE:$SERVICE_STATUS" >> "$DATA_FILE"
echo "FAILED_LOGINS:$FAILED_LOGIN" >> "$DATA_FILE"

echo "------------------------------"
echo "Sending data to Decision Engine..."

bash "$BASE_DIR/engine/decision_engine.sh"

echo "$(date) Monitoring completed" >> "$LOG_FILE"

echo "=============================="
echo " Monitoring Completed"
echo "=============================="
