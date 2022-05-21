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
kubectl create deployment deployment-nginx --image=nginx

# check if the deployment logs any errors
kubectl describe deployment/deployment-nginx

# check if the pod from the deployment is in the "running" status
POD_NAME=$(kubectl get pod  | grep nginx | awk '{print $1}')
kubectl exec $POD_NAME -- curl -sI 127.0.0.1

```
#### 3) Test port-forward on the cluster (hostPort:8081 <= containerPort:80 )
```
# Get the pod name
POD_NAME=$(kubectl get pod -l app=nginx-deploy -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 8081:80

# test if the cluster can ping with the "port-forward", should the output be "Handling connection for 8081" from another session
curl 127.0.0.1:8081
```

#### 4) Test logs on the cluster
```
kubectl logs $POD_NAME
```

#### 5) Test commands exec on the pods 
```
kubectl exec -it $POD_NAME -- nginx -v # if nginx pod

# test if pod's IP and pod's hostname match the 'kubectl get pod $POD_NAME  -owide'
kubectl exec -it $POD_NAME -- sh -c "hostname && hostname -i"
```
#### 6) Test service (svc) on the cluster (NodePort)
```
### create a service with expose command:
# "--port 80" means connecting to host's IP on port 80
# "--target-port 80" means connecting to pods' container on port 80
# "--type NodePort" means connection on the worker-node will be accepted from:
# - the port assigned to the service "curl -I 127.0.0.1:PORT"
# - the port with the "cluster-internal" an "cluster-external" IP adresses
kubectl expose deployment deployment-nginx --port 80 --target-port 80 --type NodePort

# Get the port from "kubectl get svc deployment-nginx"
curl -I 127.0.0.1:PORT      # localhost with PORT
curl -I 172.31.114.65:PORT  # internal IP with PORT
curl -I 34.247.244.55:PORT  # external IP with PORT
```

#### 7) Test service (svc) on the cluster (ClusterIP) --> cluster-internal IP
```
### create a service with expose command:
# "--port=8080" mean connecting on the SERVICE-IP with port:8080
# "--target-port 80" means connecting to pods' container on port 80
# "--type ClusterIP" means connection on the worker-node will be accepted on the service-cluster-internal IP "curl -I 127.0.0.1:PORT"
kubectl expose deployment deployment-nginx --port=8080 --target-port=80 --type=ClusterIP

curl -I SERVICE_IP:8080  # service IP with PORT
```
