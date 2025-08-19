#!/bin/bash
# scripts/auto-commit.sh - Auto commit and push changes

cd "/workspaces/$(basename $PWD)" || exit 1

LOG_FILE="$HOME/logs/auto-commit.log"
mkdir -p "$HOME/logs"

echo "[$(date)] Starting auto-commit..." >> "$LOG_FILE"

# Check if git repo
if [ ! -d ".git" ]; then
    echo "[$(date)] Not a git repository, initializing..." >> "$LOG_FILE"
    git init
    git remote add origin "https://github.com/$(git config user.name)/$(basename $PWD).git" 2>/dev/null || true
fi

# Set git user if not set
if [ -z "$(git config user.name)" ]; then
    git config user.name "Codespace User"
    git config user.email "codespace@example.com"
fi

# Stage all changes
git add .

# Check if there are staged changes
if git diff --staged --quiet; then
    echo "[$(date)] No changes to commit" >> "$LOG_FILE"
else
    # Commit with timestamp
    COMMIT_MSG="Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')"
    git commit -m "$COMMIT_MSG"
    
    echo "[$(date)] Committed: $COMMIT_MSG" >> "$LOG_FILE"
    
    # Push to remote
    if git push origin main 2>/dev/null || git push origin master 2>/dev/null; then
        echo "[$(date)] Successfully pushed to remote" >> "$LOG_FILE"
    else
        echo "[$(date)] Failed to push to remote" >> "$LOG_FILE"
    fi
fi

# Cleanup old logs (keep last 100 lines)
if [ -f "$LOG_FILE" ]; then
    tail -100 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
fi

echo "[$(date)] Auto-commit completed" >> "$LOG_FILE"