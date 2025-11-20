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

#### Access Registration DB via pod

```bash
kubectl exec -n his-masterdb -it postgres-patroni-0 -- psql -U postgres -d postgres

```

#### Create user, DB & grant permissions

```sql
CREATE USER his WITH PASSWORD 'his123';
CREATE DATABASE registration OWNER his;
GRANT ALL PRIVILEGES ON DATABASE registration TO his;
\q
```

#### Access PostgreSQL via pod
```bash
kubectl exec -n his-masterdb -it postgres-patroni-0 -- psql -U postgres -d postgres
```

#### Create user, DB, table & insert data
```bash
kubectl exec -n his-masterdb -it postgres-patroni-0 -- psql -U postgres -d postgres <<EOF
CREATE USER his WITH PASSWORD 'his123';
CREATE DATABASE registration OWNER his;
GRANT ALL PRIVILEGES ON DATABASE registration TO his;
\c registration
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    age INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
GRANT ALL PRIVILEGES ON TABLE users TO his;
GRANT USAGE, SELECT ON SEQUENCE users_id_seq TO his;
INSERT INTO users (name, email, age) VALUES 
    ('Alice', 'alice@example.com', 28),
    ('Bob', 'bob@example.com', 32);
SELECT * FROM users;
EOF
```

#### Access Registration DB and verify data
```bash
kubectl exec -n his-masterdb -it postgres-patroni-0 -- psql -U his -d registration -c "SELECT * FROM users;"
```

---

#### Create DB & grant permissions

```sql
CREATE DATABASE registration;
GRANT ALL PRIVILEGES ON DATABASE registration TO postgres;
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
