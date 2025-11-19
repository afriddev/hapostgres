#!/bin/bash
set -e

echo "====== Deploying Master DB Cluster ======"
echo ""

# Apply in order
echo "→ Creating namespace..."
kubectl apply -f 00-namespace/
echo ""

echo "→ Creating RBAC resources..."
kubectl apply -f 01-rbac/
echo ""

echo "→ Creating secrets..."
kubectl apply -f 02-secrets/
echo ""

echo "→ Creating storage resources..."
kubectl apply -f 03-storage/
echo ""

echo "→ Deploying etcd cluster..."
kubectl apply -f 04-etcd/
echo "Waiting for etcd to be ready..."
kubectl wait --for=condition=ready pod -l app=etcd -n his-masterdb --timeout=300s || true
echo ""

echo "→ Deploying Patroni PostgreSQL..."
kubectl apply -f 05-patroni/
kubectl apply -f 05-patroni/nodeport/
echo "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres-patroni -n his-masterdb --timeout=600s || true
echo ""

echo "====== Deployment Complete ======"
echo ""
kubectl get pods -n his-masterdb
echo ""
kubectl get pvc -n his-masterdb
echo ""
kubectl get pv | grep masterdb
echo ""

NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')
echo "✓ PostgreSQL Master: $NODE_IP:30002"
echo "✓ PostgreSQL Replicas: $NODE_IP:30003"
echo "✓ User: his | Password: his123 | DB: registration"
echo ""
echo "Data location: /home/alien/masterdb/"
