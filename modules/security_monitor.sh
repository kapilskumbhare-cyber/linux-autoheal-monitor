#!/bin/bash

# Count failed login attempts in last 5 minutes
sudo grep "Failed password" /var/log/auth.log 2>/dev/null | wc -l
