# kubernetes 1.21 version (Building a Kubernetes Cluster)
This is a kubernetes cluster from scratch 

For this simple cluster to work 3 servers are needed.
 - 1 for kubernetes master  (control-plane)
 - 1 for kubernetes node 1  (worker-node)
 - 1 for kubernetes node 2  (worker-node)


```
   control-plane           worker-node            worker-node
|-------------------|  |-------------------|  |-------------------| 
| kubernetes master |  | kubernetes node 1 |  | kubernetes node 2 |
|-------------------|  |-------------------|  |-------------------| 
| containerd        |  | containerd        |  | containerd        |
| kubeadm           |  | kubeadm           |  | kubeadm           |
| kubelet           |  | kubelet           |  | kubelet           |
| kubectl           |  | kubectl           |  | kubectl           |
|                   |  |-------------------|  |-------------------|
|-------------------|  
```


# First let's start with tmux in order to configure the 3 servers at the same time, until we neeed to apply configurations for each role. (for more info https://github.com/Calliari/shell-script/edit/master/linux-ubuntu-shell/tmux/tmux.md)
```
sudo apt-get install tmux -y
```

#############| control-planes & worker-nodes |###################################################
### Install and configure this on servers (masters and worker-nodes) all these packages/configuration on all 3 servers (On all nodes)
#### Modify the entry hosts to make sure the servers can communicate with eachother:
```
tee -a /etc/hosts << EOT
172.30.0.10 k8s-control
172.30.0.11 k8s-worker1
172.30.0.12 k8s-worker2
EOT
```

#### Configure the kernel modules (enabled the "overlay & br_netfilter") and install the containerd
```
cat << EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
```
#### enabled the "overlay & br_netfilter"
```
sudo modprobe overlay
sudo modprobe br_netfilter
```

#### Settings for kubernetes networking and reload the 'sysctl'
```
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system
```

#### Install and configure containerd.
```
sudo apt-get update && sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
```

##### swap needs to be disabled for cluster configuration from the command-line and when rebooted (/etc/fstab)
```
sudo swapoff -a 
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

  - Install the (apt-transport-https curl) and add GPG-key for the kubernetes repository
```
sudo apt-get update && sudo apt-get install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
```

  - Install kubelet(1.12.7-00), kubeadm(1.12.7-00), and kubectl(1.12.7-00) - test kubeadm installation
```
sudo apt-get update 
sudo apt-get install -y kubelet=1.21.0-00 kubeadm=1.21.0-00 kubectl=1.21.0-00
```

  - Locking packages, preventing these packages to be automatically updated/upgraded (kubelet kubeadm kubectl)
```
sudo apt-mark hold kubelet kubeadm kubectl
```

#############| control-planes |###################################################
## 1. On the Kube master node only (control-plane):
### Initialize the cluster with the kubernetes version and the CIDR block for containers/pods
```
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --kubernetes-version 1.21.0
```

When this is done, set up the local kubeconfig with create a Kube-home DIR and use the configuration the default configuration also change the ownership of the configuration file (this is the output from the "kubeadm init" CMD)
```
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

#### Install the Calico network add-on (calico-kubernetes-network-plugin)
```
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

#### Then you can join any number of worker nodes by running the following on each as root:
Get the join command (this command is also printed during kubeadm init. Feel free to simply copy it from there) `kubeadm token create --print-join-command`

#############| worker-nodes |###################################################
## 2. On the worker-nodes only (worker-node):
#### Get the join command (this command is also printed during kubeadm init.)
Copy the join command from the control plane node. Run it on each worker node as root (i.e. with sudo)
```
sudo kubeadm join $some_ip:6443 --token $some_token --discovery-token-ca-cert-hash $some_hash
```

### The kubernetes cluster should be up and running (control-plane and worker-nodes)
=================================================================================

##### Verify that the cluster is responsive and that Kubectl is working
```
kubectl version
```
##### Verify that all nodes have successfully joined the cluster
```
kubectl get nodes

```
##### To verify that the Calico(plugin) pods are up and running. Run this command to get a list of system pods:
```
kubectl get pods -n kube-system
```

 

### Deploy one POD to the cluster with a 'Deployment' object template.
=================================================================================
```
cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
EOF
```

Run some pods commands to get used to the outputs, to delete a this deployemnt run, "we need to pass the `metadata name` (nginx-deployment)":
`kubectl delete deployments nginx-deployment`
