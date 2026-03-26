#!/bin/bash

SERVICE=$1

echo "=============================="
echo "Self-Healing Activated"
echo "=============================="

if [ "$SERVICE" == "ssh" ]; then

echo "Restarting SSH service..."

sudo systemctl start ssh

sleep 2

STATUS=$(systemctl is-active ssh)

if [ "$STATUS" == "active" ]; then
echo "SSH service restarted successfully"
else
echo "SSH restart failed"
fi

fi
