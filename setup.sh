#!/bin/bash
set -e

echo "Creating storage directory..."

sudo mkdir -p /home/alien/masterdb
sudo chown -R "$USER:$USER" /home/alien/masterdb
sudo chmod -R 770 /home/alien/masterdb   # Ensure write access (better than 755)

echo "✓ Storage directory ready: /home/alien/masterdb"
echo "Run: ./deploy.sh"
