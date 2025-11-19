

## PostgreSQL High Availability Cluster with Patroni and etcd on Kubernetes

Production-ready PostgreSQL HA setup on Kubernetes (k3s/minikube/any cluster) with:

- Auto-scaling and persistent storage
- Secure secrets management
- Custom Postgres port & NodePort access
- Automatic failover via Patroni

***

## Folder Structure

```
postgres-ha/
├── setup.sh
├── namespace.yaml
├── secrets.yaml
├── storage-class.yaml
├── deploy.sh
├── etcd/
│   ├── service.yaml
│   └── statefulset.yaml
└── patroni/
    ├── configmap.yaml
    ├── service-headless.yaml
    ├── service-master.yaml
    ├── service-replicas.yaml
    └── statefulset.yaml
```

***

## Prerequisites

- Kubernetes cluster (k3s recommended for lightweight setup)
- `kubectl` installed and configured
- Sufficient disk space at `/home/alien/masterdb` for persistent storage

***

## Installing k3s and Setting kubectl Permissions Globally

### Install k3s:

```bash
curl -sfL https://get.k3s.io | sh -
```

This installs k3s and starts the Kubernetes cluster.

***

### Configure kubectl for your user with global access:

1. Create `.kube` directory if it doesn't exist:

```bash
mkdir -p ~/.kube
```

2. Copy k3s kubeconfig to your user home:

```bash
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
chmod 600 ~/.kube/config
```

3. Add the following line to your shell profile for persistent KUBECONFIG:

```bash
echo 'export KUBECONFIG=$HOME/.kube/config' >> ~/.bashrc
source ~/.bashrc
```

Now you can run `kubectl` from any directory/session as your user without sudo.

***

## Quickstart Guide

### 1. Setup Storage (set permissions and prepare local-path storage)

```bash
chmod +x setup.sh
./setup.sh
```

### 2. Deploy PostgreSQL HA cluster

```bash
chmod +x deploy.sh
./deploy.sh
```

### 3. Verify deployment

```bash
kubectl get pods -n postgres-ha
kubectl exec -n postgres-ha postgres-patroni-0 -- patronictl list
kubectl get pvc -n postgres-ha
```

***

## Database Credentials

Defined in `secrets.yaml`:

```yaml
POSTGRES_USER: his
POSTGRES_PASSWORD: his123
POSTGRES_DB: registration
REPLICATION_USER: replicator
REPLICATION_PASSWORD: rep-pass
```

***

## Scaling

To scale PostgreSQL replicas, edit `patroni/statefulset.yaml` and adjust `replicas` count:

```yaml
spec:
  replicas: 5
```

Then apply the changes:

```bash
kubectl apply -f patroni/statefulset.yaml
```

***

## Connection Info

### Inside cluster:

- Master: `postgres-master.postgres-ha.svc.cluster.local:10003`
- Replicas: `postgres-replicas.postgres-ha.svc.cluster.local:10003`

### Outside cluster:

```bash
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')

PGPASSWORD=his123 psql -h $NODE_IP -p 30002 -U his -d registration
PGPASSWORD=his123 psql -h $NODE_IP -p 30003 -U his -d registration
```

***

## Storage Persistence

All data lives in `/home/alien/masterdb/`:

```
/home/alien/masterdb/
├── local-path-provisioner-*/         # Auto-created by provisioner
│   ├── pvc-xxx-yyy/                  # PostgreSQL data volumes
│   └── pvc-zzz-www/                  # etcd data volumes
```

***

## Backup and Restore

Backup all databases:

```bash
kubectl exec -n postgres-ha postgres-patroni-0 -- pg_dumpall -U his > backup.sql
```

Backup specific database:

```bash
kubectl exec -n postgres-ha postgres-patroni-0 -- pg_dump -U his registration > registration_backup.sql
```

Restore full backup:

```bash
cat backup.sql | kubectl exec -i -n postgres-ha postgres-patroni-0 -- psql -U his
```

***

## Maintenance

- Check cluster health:

```bash
kubectl exec -n postgres-ha postgres-patroni-0 -- patronictl list
```

- Manual failover:

```bash
kubectl exec -n postgres-ha postgres-patroni-0 -- patronictl failover postgres-cluster
```

- Restart cluster:

```bash
kubectl rollout restart statefulset -n postgres-ha postgres-patroni
```

- View logs:

```bash
kubectl logs -n postgres-ha postgres-patroni-0 -f
kubectl logs -n postgres-ha etcd-0 -f
```

***

## Cleanup

```bash
kubectl delete namespace postgres-ha
sudo rm -rf /home/alien/masterdb/*
```

***

## Moving to Production Server

1. Copy entire `postgres-ha/` folder to the server
2. Run `setup.sh` on the server to prepare storage
3. Adjust any node selectors in StatefulSets if needed
4. Run `deploy.sh` to deploy cluster

***

## Troubleshooting

- Pods not starting:

```bash
kubectl describe pod -n postgres-ha postgres-patroni-0
kubectl get pvc -n postgres-ha
```

- Storage issues:

```bash
kubectl get storageclass
kubectl get pods -n local-path-storage
```

- Connection issues:

```bash
kubectl run -it --rm debug --image=postgres:15 --restart=Never -- \
  psql -h postgres-master.postgres-ha.svc.cluster.local -p 10003 -U his -d registration
kubectl get svc -n postgres-ha
```

