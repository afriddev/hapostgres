#!/bin/bash
set -e

if [ -d "/home/alien/masterdb/etcd-0/member" ]; then
    echo "→ Clearing old etcd data..."
    sudo rm -rf /home/alien/masterdb/etcd-*/*
    echo "✓ etcd data cleared"
fi

echo "Applying k3s namespace, RBAC, and secrets ..."
kubectl apply -f namespace/
echo "Created namespace completed."
kubectl apply -f rbac/
echo "Created RBAC completed."
kubectl apply -f secrets/

echo "Applying PVCs for etcd started ..."
kubectl apply -f pvc/etcd/etcd-pv0.yaml
kubectl apply -f pvc/etcd/etcd-pv1.yaml
kubectl apply -f pvc/etcd/etcd-pv2.yaml
echo "Applying PVCs for Patroni PostgreSQL"
kubectl apply -f pvc/patroni/patroni-pv0.yaml
kubectl apply -f pvc/patroni/patroni-pv1.yaml
kubectl apply -f pvc/patroni/patroni-pv2.yaml
echo "Created Persistent Volumes completed."

echo "→ Deploying etcd cluster..."
kubectl apply -f 04-etcd/
echo "Waiting for etcd to be ready..."
kubectl wait --for=condition=ready pod -l app=etcd -n his-masterdb --timeout=300s || true
echo ""

echo "→ Deploying Patroni PostgreSQL..."
kubectl apply -f patroni/
kubectl apply -f patroni/nodeport/
echo "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres-patroni -n his-masterdb --timeout=600s || true
echo ""

echo "====== Deployment Complete ======"
echo ""
kubectl get pods -n his-masterdb
echo ""

