#!/bin/bash

set -e

echo "====== PostgreSQL HA Cluster Setup ======"
echo ""

# Create base directory for persistent storage
echo "Creating storage directory..."
sudo mkdir -p /home/alien/masterdb
sudo chown -R $USER:$USER /home/alien/masterdb
sudo chmod -R 755 /home/alien/masterdb

echo "✓ Storage directory created: /home/alien/masterdb"
echo ""
echo "All PostgreSQL and etcd data will be stored here:"
echo "  /home/alien/masterdb/pvc-<uuid>_postgres-ha_postgres-data-postgres-patroni-0/"
echo "  /home/alien/masterdb/pvc-<uuid>_postgres-ha_postgres-data-postgres-patroni-1/"
echo "  /home/alien/masterdb/pvc-<uuid>_postgres-ha_postgres-data-postgres-patroni-2/"
echo "  /home/alien/masterdb/pvc-<uuid>_postgres-ha_etcd-data-etcd-0/"
echo "  /home/alien/masterdb/pvc-<uuid>_postgres-ha_etcd-data-etcd-1/"
echo "  /home/alien/masterdb/pvc-<uuid>_postgres-ha_etcd-data-etcd-2/"
echo ""
echo "Data persists across pod/node/cluster restarts!"
echo "To migrate: Just copy /home/alien/masterdb/ to new server"
echo ""
echo "Next step: Run ./deploy.sh"
