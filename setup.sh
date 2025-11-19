#!/bin/bash
set -e

echo "====== Master DB Storage Setup ======"
echo ""

# Create storage directories
echo "→ Creating storage directories..."
sudo mkdir -p /home/alien/masterdb/{etcd-0,etcd-1,etcd-2,postgres-patroni-0,postgres-patroni-1,postgres-patroni-2}

echo "→ Setting permissions..."
sudo chown -R 101:101 /home/alien/masterdb/postgres-patroni-*
sudo chmod -R 700 /home/alien/masterdb/postgres-patroni-*
sudo chmod -R 777 /home/alien/masterdb/etcd-*

echo ""
echo "✓ Storage directories created at /home/alien/masterdb"
echo ""
echo "Directory structure:"
ls -la /home/alien/masterdb/
echo ""
echo "Next: ./deploy.sh"
