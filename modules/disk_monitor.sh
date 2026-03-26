#!/bin/bash
source ~/monitor/config.conf
# Get disk usage percentage
df / | awk 'NR==2 {print $5}' | tr -d '%'


