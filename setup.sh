#!/bin/bash
set -e

echo "====== Master DB Storage Setup ======"
echo ""

# Create storage directories - NEVER DELETE THESE
echo "→ Creating storage directories..."
sudo mkdir -p /home/alien/masterdb/{etcd-0,etcd-1,etcd-2,postgres-patroni-0,postgres-patroni-1,postgres-patroni-2}

echo "→ Setting ownership..."
sudo chown -R "$USER:$USER" /home/alien/masterdb

echo "→ Setting permissions (777)..."
sudo chmod -R 777 /home/alien/masterdb

echo ""
echo "✓ Storage directories created at /home/alien/masterdb"
echo ""
echo "Directory structure:"
ls -la /home/alien/masterdb/
echo ""
echo "Next steps:"
echo "  1. Run: ./deploy.sh"
echo "  2. Your data will persist across K3s reinstalls"
