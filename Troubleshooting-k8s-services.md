Get a list of nodes and view their statuses,
```
kubectl get nodes -o wide
```

Get to know more about a particular node
```
kubectl describe node NODE_NAME
```

Check the status of your services on a node and stop/star;
```
sudo systemctl status kubelet
sudo systemctl stop kubelet  && sleep 5 && sudo systemctl start kubelet # stop the node and try to re-start it again

```

This is prevent the service (kubelet) to start at the bootstrap.
```
sudo systemctl disable kubelet
```

Make sure the all neccessary services are on the `enable` mode to starting at the bootstrap.
```
sudo systemctl enable kubelet
```

Check the status of your system Pods (control-plane):
```
kubectl get pods -n kube-system

kubectl describe pod POD_NAME -n kube-system # for a particular pod in a namespace
```
