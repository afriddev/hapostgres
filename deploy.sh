#!/bin/bash
set -e

echo "====== Deploying PostgreSQL HA Cluster ======"
echo ""

kubectl get ns local-path-storage >/dev/null 2>&1 || kubectl create ns local-path-storage

kubectl apply --validate=false -f local-path-config.yaml

echo "Restarting local-path-provisioner..."
kubectl delete pod -n kube-system -l app=local-path-provisioner --force --grace-period=0 || true
sleep 3
kubectl wait --for=condition=ready pod -l app=local-path-provisioner -n kube-system --timeout=180s
echo "✓ Storage provisioner configured"

kubectl apply --validate=false -f namespace.yaml

# Apply RBAC for Patroni
kubectl apply --validate=false -f patroni/serviceaccount.yaml
kubectl apply --validate=false -f patroni/clusterrole.yaml
kubectl apply --validate=false -f patroni/rolebinding.yaml

kubectl apply --validate=false -f secrets.yaml
kubectl apply --validate=false -f storage-class.yaml
echo "✓ Namespace, Secrets, StorageClass, RBAC applied"

kubectl apply --validate=false -f etcd/
echo "✓ ETCD applied"

kubectl wait --for=condition=ready pod -l app=etcd -n his-masterdb --timeout=300s
echo "✓ ETCD ready"

kubectl apply --validate=false -f patroni/
echo "✓ Patroni applied"

kubectl wait --for=condition=ready pod -l app=postgres-patroni -n his-masterdb --timeout=300s
echo ""

echo "====== Deployment Complete ======"
kubectl get pods -n his-masterdb
kubectl get svc -n his-masterdb
kubectl get pvc -n his-masterdb

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
echo "kubectl exec -n his-masterdb postgres-patroni-0 -- patronictl list"
echo ""
echo "Data stored under /home/alien/his-masterdb/"
