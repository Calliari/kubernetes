Looking at logs:
Reference: https://kubernetes.io/docs/tasks/debug-application-cluster/debug-cluster/#looking-at-logs

### Master
```
   /var/log/kube-apiserver.log - API Server, responsible for serving the API
   /var/log/kube-scheduler.log - Scheduler, responsible for making scheduling decisions
   /var/log/kube-controller-manager.log - Controller that manages replication controllers
```

### Worker Nodes
```
  /var/log/kubelet.log - Kubelet, responsible for running containers on the node
  /var/log/kube-proxy.log - Kube Proxy, responsible for service load balancing
```


Check the logs for your K8s services
```
sudo journalctl -u kubelet
```

Some of the logs will not be available on the node but on the container, look for the `kube-apiserver Pod` and take note of its full Pod name.
```
kubectl get pods -n kube-system # get the 'kube-apiserver Pod' name
kubectl logs -n kube-system KUBE-APISERVER_POD_NAME
```

The same principal can be used on any container/pod on the cluster:
```
kubectl logs -n NAMESPACE POD_NAME
kubectl describe -n NAMESPACE POD_NAME

```
