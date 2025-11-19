#!/bin/bash
set -e

echo "====== Restoring Master DB After K3s Reinstall ======"
echo ""

# Check data exists
if [ ! -d "/home/alien/masterdb/postgres-patroni-0" ]; then
    echo "❌ ERROR: No data found"
    echo "Run ./setup.sh first"
    exit 1
fi

echo "✓ Data found"
ls -la /home/alien/masterdb/
echo ""

# Fix permissions
echo "→ Fixing permissions..."
sudo chown -R 101:101 /home/alien/masterdb/postgres-patroni-*
sudo chmod -R 700 /home/alien/masterdb/postgres-patroni-*
sudo chmod -R 777 /home/alien/masterdb/etcd-*
echo "✓ Permissions fixed"
echo ""

# Deploy
./deploy.sh

echo ""
echo "====== Restore Complete ======"
echo "Check your data:"
echo "  kubectl exec -n his-masterdb postgres-patroni-0 -- psql -U postgres -c '\l'"
