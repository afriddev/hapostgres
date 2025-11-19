#!/bin/bash
set -e

echo "====== Deploying PostgreSQL HA Cluster ======"
echo ""

# Ensure local-path-storage namespace
kubectl get ns local-path-storage >/dev/null 2>&1 || kubectl create ns local-path-storage

# Apply storage config for /home/alien/masterdb
kubectl apply --validate=false -f local-path-config.yaml

echo "Restarting local-path-provisioner..."
kubectl delete pod -n kube-system -l app=local-path-provisioner --force --grace-period=0 || true
sleep 3
kubectl wait --for=condition=ready pod -l app=local-path-provisioner -n kube-system --timeout=180s
echo "✓ Storage provisioner configured"

echo ""
kubectl apply --validate=false -f namespace.yaml
kubectl apply --validate=false -f secrets.yaml
kubectl apply --validate=false -f storage-class.yaml
echo "✓ Namespace, Secrets, StorageClass applied"

kubectl apply --validate=false -f etcd/
echo "✓ ETCD applied"

echo "Waiting for ETCD cluster to be ready..."
kubectl wait --for=condition=ready pod -l app=etcd -n postgres-ha --timeout=300s
echo "✓ ETCD ready"

kubectl apply --validate=false -f patroni/
echo "✓ Patroni applied"

echo "Waiting for PostgreSQL cluster to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres-patroni -n postgres-ha --timeout=300s
echo ""

echo "====== Deployment Complete ======"
kubectl get pods -n postgres-ha
kubectl get svc -n postgres-ha
kubectl get pvc -n postgres-ha

NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')
echo ""
echo "Connection Info:"
echo "Master  : $NODE_IP:30002"
echo "Replicas: $NODE_IP:30003"
echo "User    : his"
echo "Password: his123"
echo "Database: registration"
echo ""
echo "Cluster status check:"
echo "  kubectl exec -n postgres-ha postgres-patroni-0 -- patronictl list"
echo ""
echo "Data stored under /home/alien/masterdb/"
