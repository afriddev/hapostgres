#!/bin/bash
set -e

echo "Creating storage directory..."
sudo mkdir -p /home/alien/his-masterdb
sudo chown -R "$USER:$USER" /home/alien/his-masterdb
sudo chmod -R 777 /home/alien/his-masterdb

echo "✓ Storage directory ready: /home/alien/his-masterdb"
echo "Directory permissions:"
ls -ld /home/alien/his-masterdb
echo ""
echo "Run: ./deploy.sh"
