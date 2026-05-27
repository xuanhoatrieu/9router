#!/bin/bash
# 9Router Automatic Update Script
set -e

# Load NVM environment so node/npm/bun are in PATH
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

cd /home/trieuhoa/9router

echo "=== Auto Update Check: $(date) ==="

# Check if there are local uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "WARNING: Local uncommitted changes detected! Skipping auto-update to prevent overwriting your changes."
    exit 0
fi

# Fetch latest changes from upstream
git fetch origin master

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/master)

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "New version detected on upstream repository!"
    echo "Local:  $LOCAL"
    echo "Remote: $REMOTE"
    
    # 1. Pull changes safely
    echo "Pulling latest changes..."
    git pull origin master
    
    # 2. Install dependencies (if package.json changed)
    echo "Installing dependencies..."
    npm install
    
    # 3. Build project
    echo "Building production bundle..."
    npm run build
    
    # 4. Restart the main service
    echo "Restarting 9router service..."
    systemctl --user restart 9router.service
    
    echo "Update completed successfully!"
else
    echo "No new updates found. System is up to date."
fi
