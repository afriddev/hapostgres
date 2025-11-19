#!/bin/bash
set -e

echo "====== Deploying PostgreSQL HA Cluster ======"
echo ""

# Apply storage config first
kubectl apply -f local-path-config.yaml
echo "✓ Local path config applied"

# Restart local-path-provisioner to pick up new config
echo "Restarting local-path-provisioner..."
kubectl delete pod -n kube-system -l app=local-path-provisioner --force --grace-period=0 2>/dev/null || true
sleep 5
kubectl wait --for=condition=ready pod -l app=local-path-provisioner -n kube-system --timeout=180s
echo "✓ Storage provisioner restarted"
echo ""

# Apply namespace, secrets, storage class
kubectl apply -f namespace.yaml
kubectl apply -f secrets.yaml
kubectl apply -f storage-class.yaml
echo "✓ Namespace, Secrets, StorageClass applied"
echo ""

# Deploy ETCD
kubectl apply -f statefulset.yaml
echo "✓ ETCD StatefulSet applied"

echo "Waiting for ETCD pods to start..."
sleep 10
kubectl wait --for=condition=ready pod -l app=etcd -n postgres-ha --timeout=300s 2>/dev/null || true
echo "✓ ETCD deployed"
echo ""

echo "====== Deployment Complete ======"
kubectl get pods -n postgres-ha
echo ""
kubectl get pvc -n postgres-ha
echo ""

NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')
echo "Connection Info:"
echo "Master  : $NODE_IP:30002"
echo "Replicas: $NODE_IP:30003"
echo ""
echo "Data stored under /home/alien/masterdb/"
echo "Check data: ls -lah /home/alien/masterdb/"
