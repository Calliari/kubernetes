### We need some pods to be up and running, first, create a pod:
```
cat << EOF | tee my-nginx-pod.yml
apiVersion: v1 # for versions before 1.9.0 use apps/v1beta2
kind: Pod
metadata:
  name: my-nginx-pod
spec:
  restartPolicy: OnFailure # restart if the conatainer fails (Always, Never, OnFailure)
  containers: 
  - name: nginx-container
    image: nginx:1.14.2
    ports:
     - containerPort: 80
EOF
```

##### Spin up the pod
```
kubectl -f apply my-nginx-pod.yml
```

### Create a deployment with two replicas

```
cat << EOF | tee my-nginx-deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx-deployment
  labels:
    env: prod
    version: v1
    app: my-nginx-deployment-app
spec:
  # modify replicas according to your case
  replicas: 3
  selector:
    matchLabels:
      env: prod # this is the label need to that match the pod's labels (spec.template.labels)
      pod-name: nginx-pod # this is the label need to that match the pod's labels (spec.template.labels)
      version: v1 # this is the label need to that match the pod's labels (spec.template.labels)
  template:
    metadata:
      labels:
        env: prod # this lablel will be used by the replicaset (spec.selector.matchLabels)
        pod-name: nginx-pod # this lablel will be used by the replicaset (spec.selector.matchLabels)
        version: v1 # this lablel will be used by the replicaset (spec.selector.matchLabels)
    spec:
      containers:
      - name: nginx-container
        image: nginx:1.14.2
        ports:
        - containerPort: 80
EOF
```

##### Spin up the deployment
```
kubectl apply -f deployment.yml
```


Get a list of pods (my-nginx-pod and my-nginx-deployment )
```
kubectl get pods -o wide
```


### Drain the node which the 'cka-worker-node1' pods are running (puttin the node in maintenance)
```
kubectl drain cka-worker-node1 --ignore-daemonsets --force
```

Uncordon the node to allow new pods to be scheduled there again (getting the node out or maintenance, node back to ready status)
```
kubectl uncordon  cka-worker-node1
```

### Delete the deployment created for this drain-test
```
kubectl delete deployment my-nginx-deployment
kubectl delete pod my-nginx-pod
```
