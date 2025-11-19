### Installing K3s on Ubuntu

```bash
# Uninstall existing K3s installation if any
sudo /usr/local/bin/k3s-uninstall.sh
# Install K3s
curl -sfL https://get.k3s.io | sh -

```

### Accessing K3s Cluster with kubectl

```bash
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
chmod 600 ~/.kube/config
export KUBECONFIG=$HOME/.kube/config
echo 'export KUBECONFIG=$HOME/.kube/config' >> ~/.bashrc
source ~/.bashrc
```

### Checking Patroni Cluster Status

```bash
kubectl exec -n his-masterdb postgres-patroni-0 -- patronictl list
```
