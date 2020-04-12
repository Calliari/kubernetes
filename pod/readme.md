# kubernetes-pod
This is a kubernetes cluster from scratch part (Create a single pod)


For this simple cluster to work 3 servers are needed.
 - 1 for kubernetes master
 - 1 for kubernetes node 1
 - 1 for kubernetes node 2


To create a pod make sure the cluster is running with the master and worker-nodes successfuly

ssh into the master `control plane` and run the following:
```
# Create the nginx pod from the file called 'nginx-pod.yaml'
kubectl -f apply nginx-pod.yaml

# Confirm that pod is running 
kubectl get pod  -o wide
```

We can check if the pod is actually accepting the requets with:
```
curl -I 10.244.2.3 # if all good, 200 HTTP request will be replied
curl -I `kubectl get pod -o wide | awk '{print $6}' | tail -1`
```

We can check the page html code response if the pod is actually accepting the requets with:
```
curl -i 10.244.2.3 # if all good, 200 HTTP request will be replied
curl -I `kubectl get pod -o wide | grep nginx |awk '{print $6}'`
```