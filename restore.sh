#!/bin/bash
set -e

if [ ! -d "/home/alien/masterdb/postgres-patroni-0" ]; then
    echo "❌ ERROR: No data found"
    echo "Run ./setup.sh first"
    exit 1
fi

ls -la /home/alien/masterdb/

sudo chown -R 101:101 /home/alien/masterdb/postgres-patroni-*
sudo chmod -R 700 /home/alien/masterdb/postgres-patroni-*
sudo chmod -R 777 /home/alien/masterdb/etcd-*

./deploy.sh
