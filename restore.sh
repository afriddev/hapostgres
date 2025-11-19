#!/bin/bash
set -e

echo "====== Restoring Master DB from Existing Data ======"
echo ""
echo "This script reconnects to data at /home/alien/masterdb"
echo ""

# Check if data exists
if [ ! -d "/home/alien/masterdb/postgres-patroni-0" ]; then
    echo "❌ ERROR: No data found at /home/alien/masterdb"
    echo "Run ./setup.sh first to create directories"
    exit 1
fi

echo "✓ Data found at /home/alien/masterdb"
ls -la /home/alien/masterdb/
echo ""

# Fix permissions
echo "→ Fixing permissions..."
sudo chown -R 101:101 /home/alien/masterdb/postgres-patroni-*
sudo chmod -R 700 /home/alien/masterdb/postgres-patroni-*
sudo chmod -R 777 /home/alien/masterdb/etcd-*
echo "✓ Permissions fixed"
echo ""

# Deploy everything
echo "→ Deploying cluster..."
./deploy.sh

echo ""
echo "====== Restore Complete ======"
echo "✓ Your databases should be reconnected!"
echo ""
echo "Verify your data:"
echo "  kubectl exec -n his-masterdb postgres-patroni-0 -- psql -U postgres -d testdb -c 'SELECT * FROM users;'"
