# kubernetes
This is a kubernetes cluster from scratch 

For this simple cluster to work 3 servers are needed.
 - 1 for kubernetes master
 - 1 for kubernetes node 1
 - 1 for kubernetes node 2


```
|-------------------|  |-------------------|  |-------------------| 
| kubernetes master |  | kubernetes node 1 |  | kubernetes node 2 |
|-------------------|  |-------------------|  |-------------------| 
| docker            |  | docker            |  | docker            |
| kubeadm           |  | kubeadm           |  | kubeadm           |
| kubelet           |  | kubelet           |  | kubelet           |
| kubectl           |  | kubectl           |  | kubectl           |
| control plane     |  |-------------------|  |-------------------|
|-------------------|  
```


### Install all these packages on all 3 servers
  - Install and test docker(18.06.1~ce~3-0~ubuntu) 90 installation 
```
sudo apt-get update -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update -y
sudo apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu && sudo apt-mark hold docker-ce
sudo docker version

```

  - Install kubelet(1.12.7-00), kubeadm(1.12.7-00), and kubectl(1.12.7-00) - test kubeadm installation
```
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update -y
sudo apt-get install -y kubelet=1.12.7-00 kubeadm=1.12.7-00 kubectl=1.12.7-00 && sudo apt-mark hold kubelet kubeadm kubectl
kubeadm version

```

### Initialize the cluster
On the Kube master node only:
```
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```
When it is done, set up the local kubeconfig with create a Kube-home DIR and use the configuration the default configuration also change the ownership of the configuration file
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Copy and run the command on the nodes when a similar line prompt from the `sudo kubeadm init --pod-network-cidr=10.244.0.0/16` CMD

```
You can now join any number of machines by running the following on each node
as root:

kubeadm join $some_ip:6443 --token $some_token --discovery-token-ca-cert-hash $some_hash

```
Verify that the cluster is responsive and that Kubectl is working
```
kubectl version
```
Verify that all nodes have successfully joined the cluster
```
kubectl get nodes

```
Or the JOIN NODE to a CLUSTER can retrived from `kubeadm token create --print-join-command` CMD


### Joing the node to a cluster (node 1 and node 2)
Afert get the kubeadm command run on the nodes to joing them into a cluster:
```
sudo kubeadm join $some_ip:6443 --token $some_token --discovery-token-ca-cert-hash $some_hash
```

### Add this line to /etc/sysctl.conf for 'flannel' plugin to connect the nodes and the master on the same network 
```
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
```
### sysctl - configure kernel parameters at runtime. To Load in sysctl settings from the file specified or /etc/sysctl.conf
```
sudo sysctl -p
```

### Install Flannel in the cluster by running this only on the Master node only:
```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
```

### To verify that the Flannel pods are up and running. Run this command to get a list of system pods:
```
kubectl get pods -n kube-system
```

### The kubernetes cluster should be up and running with one master and nodes
=================================================================================


## To interact with the `nodes` we need to run commands from the `master (controller)`
Get all (pods, service, deployment)
`kubectl get all`

Get all nodes assigned to a master on a cluster
`kubectl get nodes`
`kubectl get nodes -o wide`

# Get commands with basic output
```
kubectl get namespace                         # List all namespace 
kubectl get services                          # List all services in the namespace
kubectl get pods --all-namespaces             # List all pods in all namespaces
kubectl get pods -o wide                      # List all pods in the namespace, with more details
kubectl get deployment my-dep                 # List a particular deployment
kubectl get pods                              # List all pods in the namespace
kubectl get pod my-pod -o yaml                # Get a pod's YAML
kubectl get pod my-pod -o yaml --export       # Get a pod's YAML without cluster specific information
```

Get logs, debugs from node:
`kubectl get node $pod_name`
`kubectl describe node $pod_name`

Pods CMD
`kubectl get pods --all-namespaces`
`kubectl get pods -o wide`

To get logs, debug a pod we run:
`kubectl get pods $pod_name`
`kubectl describe pods $pod_name`



### Deploy the Stan's Robot Shop app to the cluster.
=================================================================================

Clone the Git repo that contains the pre-made descriptors:

`cd ~/ &&  git clone https://github.com/linuxacademy/robot-shop.git`

Since this application has many components, it is a good idea to create a separate namespace for the app:

`kubectl create namespace robot-shop`

Deploy the app to the cluster:

`kubectl -n robot-shop create -f ~/robot-shop/K8s/descriptors/`

Check the status of the application's pods:
`kubectl get pods -n robot-shop`

To reach the robot shop app from your browser using the Kube master node's public IP: http://$kube_master_public_ip:30080
