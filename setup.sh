#!/bin/bash
set -e

echo "Creating storage directory..."
sudo mkdir -p /home/alien/masterdb
sudo chown -R "$USER:$USER" /home/alien/masterdb
sudo chmod -R 777 /home/alien/masterdb

echo "✓ Storage directory ready: /home/alien/masterdb"
echo "Directory permissions:"
ls -ld /home/alien/masterdb
echo ""
echo "Run: ./deploy.sh"
