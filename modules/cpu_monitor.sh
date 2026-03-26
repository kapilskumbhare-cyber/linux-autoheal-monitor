#!/bin/bash
uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | tr -d ' '
