### This is a serie of commands to peform a smoke test on the cluster and check if every thing is working

#### Test the kubectl 
```
kubectl version 
kubectl -h

```

#### 1) Test the secret encryption 
```
# create a secret to be tested
kubectl create secret generic my-test-secret --from-literal="mykey=myvalue"

# check if the secret is encryption

sudo ETCDCTL_API=3 etcdctl get \
--cacert /etc/kubernetes/pki/etcd/ca.crt \
--cert /etc/kubernetes/pki/etcd/server.crt \
--key /etc/kubernetes/pki/etcd/server.key \
/registry/secrets/default/my-test-secret | hexdump -C

If the secret "myvalue" is show somewhere on the output its not using encryption "DANGER"

```

#### 2) Test deployments on the cluster 
```
# create a deployment to be tested
kubectl create
```
