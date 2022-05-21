##### Backup the cluster with etcd
```
# SAMPLE 1 - ETCD snapshot with endpoint
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
snapshot save snapshotdb-bkp

# SAMPLE 2 - ETCD snapshot without endpoint
ETCDCTL_API=3 etcdctl \
--cacert /etc/kubernetes/pki/etcd/ca.crt \
--cert /etc/kubernetes/pki/etcd/server.crt \
--key /etc/kubernetes/pki/etcd/server.key \
snapshot save ./etcd-backup.db
```

##### Restore backup from snapshot with etcd
```
# Stop all the pods
cd /etc/kubernetes/manifests/
mkdir bkp
mv *.yaml ./bkp/

#  restoring backup from snapshot with etcd
ETCDCTL_API=3 etcdctl 
--cacert /etc/kubernetes/pki/etcd/ca.crt \
--cert /etc/kubernetes/pki/etcd/server.crt \
--key /etc/kubernetes/pki/etcd/server.key \
snapshot restore ./etcd-backup.db --data-dir="/var/lib/etcd" 
```
