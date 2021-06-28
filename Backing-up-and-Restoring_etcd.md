### Back Up the etcd Data guide/instructions and cmd


#### First, get etcd version API (API version: 3.4)
```
mkdir -p /home/$USER/etcd-backups/etcd-certs/ 
mkdir -p /home/$USER/etcd-backups/etcd-db/
etcdctl version
```

#### Secondly, get etcd cluster.name 
```
ETCDCTL_API=3 etcdctl get cluster.name \
  --endpoints=https://10.0.1.101:2379 \
  --cacert=/home/$USER/etcd-backups/etcd-certs/etcd-ca.pem \
  --cert=/home/$USER/etcd-backups/etcd-certs/etcd-server.crt \
  --key=/home/$USER/etcd-backups/etcd-certs/etcd-server.key
```

#### Back up etcd using etcdctl and the provided etcd certificates, (snapshot save) CMD, path: (/home/$USER/etcd-backups/etcd-db/etcd_backup.db)
```
ETCDCTL_API=3 etcdctl snapshot save /home/$USER/etcd-backups/etcd-db/etcd_backup.db \
  --endpoints=https://10.0.1.101:2379 \
  --cacert=/home/$USER/etcd-backups/etcd-certs/etcd-ca.pem \
  --cert=/home/$USER/etcd-backups/etcd-certs/etcd-server.crt \
  --key=/home/$USER/etcd-backups/etcd-certs/etcd-server.key
```

#### By stop and removing etcd data dir/db, the cluster will not longer be able to have the existing configurarion, at this point etcd is broken or empty:
```
sudo systemctl stop etcd
sudo rm -rf /var/lib/etcd
```

### Restore the etcd Data from path: (/home/$USER/etcd-backups/etcd-db/etcd_backup.db)
This command spins up a temporary etcd cluster(etcd-restore), saving the data from the backup file to a new data directory in the same location where the previous data directory was)
```
sudo ETCDCTL_API=3 etcdctl snapshot restore /home/$USER/etcd-backups/etcd-db/etcd_backup.db \
  --initial-cluster etcd-restore=https://10.0.1.101:2380 \
  --initial-advertise-peer-urls https://10.0.1.101:2380 \
  --name etcd-restore \
  --data-dir /var/lib/etcd
```

#### Set ownership on the new data directory:
```
sudo chown -R etcd:etcd /var/lib/etcd
```

#### Start etcd service:
```
sudo systemctl start etcd
```

#### Verify the restored data is present by looking up the value for the key cluster.name again:
```
ETCDCTL_API=3 etcdctl get cluster.name \
  --endpoints=https://10.0.1.101:2379 \
  --cacert=/home/$USER/etcd-backups/etcd-certs/etcd-ca.pem \
  --cert=/home/$USER/etcd-backups/etcd-certs/etcd-server.crt \
  --key=/home/$USER/etcd-backups/etcd-certs/etcd-server.key
```