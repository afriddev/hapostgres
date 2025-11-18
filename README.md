# PostgreSQL High Availability Cluster

Production-ready PostgreSQL HA setup with Patroni and etcd on Kubernetes.

## Features
-  Auto-scaling: Change replicas without creating PV files manually
-  Persistent storage: Data survives pod/node/cluster restarts
-  Secrets management: All credentials stored securely
-  Custom port: PostgreSQL on internal port 10003
-  NodePort access: Master (30002), Replicas (30003)
-  Automatic failover with Patroni

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

## Prerequisites
- Kubernetes cluster (minikube, k3s, or production cluster)
- kubectl configured
- Sufficient storage at `/home/alien/masterdb`

## Quick Start

### 1. Setup Storage
```bash
chmod +x setup.sh
./setup.sh
```

### 2. Deploy Cluster
```bash
chmod +x deploy.sh
./deploy.sh
```

### 3. Verify Deployment
```bash
kubectl get pods -n postgres-ha
kubectl exec -n postgres-ha postgres-patroni-0 -- patronictl list
kubectl get pvc -n postgres-ha
```

## Configuration

### Database Credentials (02-secrets.yaml)
```yaml
POSTGRES_USER: his
POSTGRES_PASSWORD: his123
POSTGRES_DB: registration
REPLICATION_USER: replicator
REPLICATION_PASSWORD: rep-pass
```

### Scaling
To change replicas, edit `patroni/statefulset.yaml`:
```yaml
spec:
  replicas: 5  
```

Then apply:
```bash
kubectl apply -f patroni/statefulset.yaml
```

New pods will automatically get storage provisioned.

## Connection Info

### From Inside Cluster
```bash
postgres-master.postgres-ha.svc.cluster.local:10003

postgres-replicas.postgres-ha.svc.cluster.local:10003
```

### From Outside Cluster
```bash
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')

PGPASSWORD=his123 psql -h $NODE_IP -p 30002 -U his -d registration

PGPASSWORD=his123 psql -h $NODE_IP -p 30003 -U his -d registration
```

## Storage Persistence

### Data Location
All data is stored in `/home/alien/masterdb/`:
```
/home/alien/masterdb/
├── local-path-provisioner-*/   # Auto-created by provisioner
│   ├── pvc-xxx-yyy/            # PostgreSQL data volumes
│   └── pvc-zzz-www/            # etcd data volumes
```

### Backup
```bash
kubectl exec -n postgres-ha postgres-patroni-0 -- \
  pg_dumpall -U his > backup.sql

kubectl exec -n postgres-ha postgres-patroni-0 -- \
  pg_dump -U his registration > registration_backup.sql
```

### Restore
```bash
cat backup.sql | kubectl exec -i -n postgres-ha postgres-patroni-0 -- \
  psql -U his
```

## Maintenance

### Check Cluster Health
```bash
kubectl exec -n postgres-ha postgres-patroni-0 -- patronictl list
```

### Manual Failover
```bash
kubectl exec -n postgres-ha postgres-patroni-0 -- \
  patronictl failover postgres-cluster
```

### Restart Cluster
```bash
kubectl rollout restart statefulset -n postgres-ha postgres-patroni
```

### View Logs
```bash
kubectl logs -n postgres-ha postgres-patroni-0 -f
kubectl logs -n postgres-ha etcd-0 -f
```
## Troubleshooting
### Pods Not Starting
```bash
kubectl describe pod -n postgres-ha postgres-patroni-0
kubectl get pvc -n postgres-ha
```
### Storage Issues
```bash
kubectl get storageclass
kubectl get pods -n local-path-storage
```
### Connection Issues
```bash
kubectl run -it --rm debug --image=postgres:15 --restart=Never -- \
  psql -h postgres-master.postgres-ha.svc.cluster.local -p 10003 -U his -d registration
kubectl get svc -n postgres-ha
```

## Cleanup
```bash
kubectl delete namespace postgres-ha
sudo rm -rf /home/alien/masterdb/*
```
## Moving to Production Server

1. Copy entire `postgres-ha/` folder to server
2. Run `setup.sh` on server
3. Update node selectors if needed in statefulset files
4. Run `deploy.sh`

Data persists across:
-  Pod restarts
-  Node reboots
-  Cluster restarts
-  Minikube stop/start
-  Server migrations (copy `/home/alien/masterdb/`)

## Support

For issues or questions:
- Check logs: `kubectl logs -n postgres-ha <pod-name>`
- Check status: `kubectl get all -n postgres-ha`
- Describe resources: `kubectl describe <resource> -n postgres-ha`