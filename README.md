#### Install K3s

```bash
curl -sfL https://get.k3s.io | sh -
```

#### Uninstall K3s

```bash
sudo /usr/local/bin/k3s-uninstall.sh || true
```

---

#### Configure kubectl access

```bash
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
chmod 600 ~/.kube/config
echo 'export KUBECONFIG=$HOME/.kube/config' >> ~/.bashrc
export KUBECONFIG=$HOME/.kube/config
source ~/.bashrc
```

---

#### Access PostgreSQL via pod

```bash
kubectl exec -n his-masterdb -it postgres-patroni-0 -- psql -U his -d postgres
```

---

#### Create DB & grant permissions

```sql
CREATE DATABASE registration;
GRANT ALL PRIVILEGES ON DATABASE registration TO his;
```

#### Access Registration DB via pod

```bash
kubectl exec -n his-masterdb -it postgres-patroni-0 -- psql -U his -d registration
```

---

#### Setting Permissions to public key

```bash
chmod 600 /workspaces/ssh/alien_key
```

#### Connecting to the Server

```bash
ssh -i /workspaces/ssh/alien_key alien@104.154.187.72
```

#### Check Patroni leader and replica status

```bash
kubectl exec -n his-masterdb postgres-patroni-0 -- patronictl list
```
