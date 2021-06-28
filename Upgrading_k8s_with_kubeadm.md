### First, drain and upgrade the control-plane node.
#### Drain the control-plane node
```
kubectl drain cka-control-plane --ignore-daemonsets
```

Check the (componetes) kubeadm, kubectl, kubelet version
```
kubeadm version
kubectl version
kubelet --version
```


#### Upgrade kubeadm on the control-plane
```
sudo apt-get update
sudo apt-get install -y --allow-change-held-packages kubeadm=1.21.1-00
```

Plan the upgrade.
```
sudo kubeadm upgrade plan v1.21.1
```

Upgrade the control plane components. (kubeadm)
```
sudo kubeadm upgrade apply v1.21.1
```

Upgrade (kubelet) and (kubectl) on the control plane node.
```
sudo apt-get update
sudo apt-get install -y --allow-change-held-packages kubelet=1.21.1-00 kubectl=1.21.1-00
```

Restart (kubelet) component
```
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

Uncordon the control plane node. "putting it back to work"
```
kubectl uncordon cka-control-plane
```

Check the nodes (control-plane) 
```
kubectl get nodes
```



========================================================
### Secondly, drain and upgrade the worker-node. (Don't perform upgrades on all worker nodes at the same time, one at each time allowing the pods to ru non the other nodes during the upgrade)
#### Drain the worker-node from the master
```
kubectl drain cka-worker-node --ignore-daemonsets --force
```

Check the (componetes) kubeadm, kubectl, kubelet version

#### Upgrade kubeadm on the worker-node
```
sudo apt-get update
sudo apt-get install -y --allow-change-held-packages kubeadm=1.21.1-00
```

Upgrade the kubelet configuration on the worker-node
```
sudo kubeadm upgrade node
```

Upgrade (kubelet) and (kubectl) on the worker-node
```
sudo apt-get update
sudo apt-get install -y --allow-change-held-packages kubelet=1.21.1-00 kubectl=1.21.1-00
```

Restart (kubelet) component
```
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

From the master node, uncordon worker-node 
```
kubectl uncordon cka-worker-node
```