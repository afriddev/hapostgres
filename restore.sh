#!/bin/bash
set -e

echo "====== Restoring Master DB from Existing Data ======"
echo ""
echo "This script reconnects to data at /home/alien/masterdb"
echo ""

# Check if data exists
if [ ! -d "/home/alien/masterdb/postgres-patroni-0" ]; then
    echo "❌ ERROR: No data found at /home/alien/masterdb"
    echo ""
    echo "Run ./setup.sh first to create directories"
    exit 1
fi

echo "✓ Data found at /home/alien/masterdb"
echo ""
ls -la /home/alien/masterdb/
echo ""

# Verify permissions
echo "→ Verifying permissions..."
sudo chmod -R 777 /home/alien/masterdb
sudo chown -R "$USER:$USER" /home/alien/masterdb
echo "✓ Permissions verified"
echo ""

# Deploy everything
echo "→ Deploying cluster..."
./deploy.sh

echo ""
echo "====== Restore Complete ======"
echo "✓ Your databases should be reconnected!"
echo ""
echo "Check cluster status:"
echo "  kubectl exec -n his-masterdb postgres-patroni-0 -- patronictl list"
