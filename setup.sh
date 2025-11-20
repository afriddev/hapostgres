#!/bin/bash
set -e
sudo mkdir -p /home/alien/masterdb/{etcd-0,etcd-1,etcd-2,postgres-patroni-0,postgres-patroni-1,postgres-patroni-2}
sudo chown -R 101:101 /home/alien/masterdb/postgres-patroni-*
sudo chmod -R 700 /home/alien/masterdb/postgres-patroni-*
sudo chmod -R 777 /home/alien/masterdb/etcd-*
