### **Install / Reinstall K3s**

```bash
sudo /usr/local/bin/k3s-uninstall.sh || true
curl -sfL https://get.k3s.io | sh -
```

---

### **Configure kubectl access**

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

### **Check Patroni cluster**

```bash
kubectl exec -n his-masterdb postgres-patroni-0 -- patronictl list
```

---

### **Access PostgreSQL via pod**

```bash
kubectl exec -n his-masterdb -it postgres-patroni-0 -- psql -U his -d postgres
```

---

### **Create DB & grant permissions**

```sql
CREATE DATABASE registration;
GRANT ALL PRIVILEGES ON DATABASE registration TO his;
```

### **Access Registration DB via pod**

```bash
kubectl exec -n his-masterdb -it postgres-patroni-0 -- psql -U his -d registration
```

---

✔ Scalable, clean setup — safe for HA cluster bootstrap and DB ops.
