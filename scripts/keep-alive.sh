#!/bin/bash
# scripts/keep-alive.sh - Keep codespace active

LOG_FILE="$HOME/logs/keep-alive.log"
mkdir -p "$HOME/logs"

echo "[$(date)] Keep-alive script started" >> "$LOG_FILE"

# Function to keep codespace active
keep_alive() {
    while true; do
        # CPU activity
        echo "[$(date)] Sending keep-alive signal..." >> "$LOG_FILE"
        
        # Light CPU activity
        for i in {1..5}; do
            echo "scale=1000; 4*a(1)" | bc -l > /dev/null 2>&1 &
            sleep 1
        done
        
        # Network activity
        curl -s https://api.github.com/user > /dev/null 2>&1 || true
        curl -s https://httpbin.org/ip > /dev/null 2>&1 || true
        
        # Memory activity
        ps aux | head -20 > /dev/null 2>&1
        
        # Disk activity
        find /workspaces -name "*.log" -mtime +1 > /dev/null 2>&1 || true
        
        # Wait 5 minutes
        sleep 300
    done
}

# Function to auto-commit changes
auto_commit() {
    while true; do
        sleep 1800  # 30 minutes
        
        cd "/workspaces/$(basename $PWD)"
        
        # Check if there are changes
        if [[ -n $(git status --porcelain) ]]; then
            echo "[$(date)] Auto-committing changes..." >> "$LOG_FILE"
            
            git add .
            git commit -m "Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')" --allow-empty
            git push origin main 2>/dev/null || git push origin master 2>/dev/null || true
        fi
    done
}

# Run functions in background
keep_alive &
auto_commit &

# Monitor system resources
monitor_resources() {
    while true; do
        CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
        MEM_USAGE=$(free | grep Mem | awk '{printf("%.1f"), $3/$2 * 100.0}')
        DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
        
        echo "[$(date)] CPU: ${CPU_USAGE}%, MEM: ${MEM_USAGE}%, DISK: ${DISK_USAGE}%" >> "$LOG_FILE"
        
        # Alert if high usage
        if (( $(echo "$CPU_USAGE > 80" | bc -l) )) || (( $(echo "$MEM_USAGE > 80" | bc -l) )); then
            echo "[$(date)] ⚠️ High resource usage detected!" >> "$LOG_FILE"
        fi
        
        sleep 600  # 10 minutes
    done
}

monitor_resources &

echo "Keep-alive script running in background (PID: $$)"
wait