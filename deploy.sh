#!/bin/bash

set -e

echo "====== Deploying PostgreSQL HA Cluster ======"
echo ""

# Check if local-path-provisioner is installed
if ! kubectl get storageclass local-path &> /dev/null; then
    echo "Installing local-path-provisioner..."
    kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.24/deploy/local-path-storage.yaml
    echo "Waiting for provisioner to be ready..."
    kubectl wait --for=condition=ready pod -l app=local-path-provisioner -n local-path-storage --timeout=120s
    echo "✓ local-path-provisioner installed"
else
    echo "✓ local-path-provisioner already installed"
fi

echo ""
echo "Applying manifests..."

kubectl apply -f namespace.yaml
echo "✓ Namespace created"

kubectl apply -f secrets.yaml
echo "✓ Secrets created"

kubectl apply -f storage-class.yaml
echo "✓ StorageClass created"

kubectl apply -f etcd/
echo "✓ etcd deployed"

echo ""
echo "Waiting for etcd to be ready..."
kubectl wait --for=condition=ready pod -l app=etcd -n postgres-ha --timeout=300s
echo "✓ etcd is ready"

kubectl apply -f patroni/
echo "✓ Patroni deployed"

echo ""
echo "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres-patroni -n postgres-ha --timeout=300s

echo ""
echo "====== Deployment Complete ======"
echo ""
echo "Cluster Status:"
kubectl get pods -n postgres-ha
echo ""
echo "Services:"
kubectl get svc -n postgres-ha
echo ""
echo "Storage:"
kubectl get pvc -n postgres-ha
echo ""
echo "Data Location:"
echo "  /home/alien/masterdb/"
echo ""
echo "Connection Info:"
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')
echo "  Master: $NODE_IP:30002"
echo "  Replica: $NODE_IP:30003"
echo "  User: his"
echo "  Password: his123"
echo "  Database: registration"
echo ""
echo "Check cluster status:"
echo "  kubectl exec -n postgres-ha postgres-patroni-0 -- patronictl list"
echo ""
echo "Verify data storage:"
echo "  ls -la /home/alien/masterdb/"
