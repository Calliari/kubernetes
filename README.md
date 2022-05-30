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
On this cluster we will assign the pod to be on 10.244.0.0/16 CIDIR network:

```
               ______________________
              | VPC with CIDIR block |
              |----------------------|   
              |   172.31.0.0/16      |
              |------|---------------| 
          ___________|__________________________________
         |                        |                     |
|--------|----------|  |----------|--------|  |---------|---------|
|  172.31.1.151     |  |  172.31.2.152     |  |  172.31.3.153     |
|-------------------|  |-------------------|  |-------------------| 
| kubernetes master |  | kubernetes node 1 |  | kubernetes node 2 |
|-------------------|  |-------------------|  |-------------------| 
|                   |  |   ____    ____    |  |   ____    ____    |  
|   ____   ____     |  |  |pod |  |pod |   |  |  |pod |  |pod |   |
|  |pod | |pod |    |  |  |____|  |____|   |  |  |____|  |____|   |
|  |____| |____|    |  |   __|_    __|_    |  |   __|_    __|_    |
|   __|_   __|_     |  |  |pod |  |pod |   |  |  |pod |  |pod |   |
|  |pod | |pod |    |  |  |____|  |____|   |  |  |____|  |____|   |
|  |____| |____|    |  |   __|_    __|_    |  |   __|_    __|_    |
|   __|_   __|_     |  |  |pod |  |pod |   |  |  |pod |  |pod |   |
|  |pod | |pod |    |  |  |____|  |____|   |  |  |____|  |____|   |
|  |____| |____|    |  |   __|_    __|_    |  |   __|_    __|_    |  
|    |       |      |  |  |pod |  |pod |   |  |  |pod |  |pod |   |
|    |       |      |  |  |____|  |____|   |  |  |____|  |____|   |
|----|-------|------|  |----|-------|------|  |----|--------|-----|  
     |       |              |       |              |        | 
     |       |              |       |              |        |    
     |_______|______________|_______|______________|________|
                               |
                               |
                      |--------|----------|   
                      |   10.244.0.0/16   |
                      |-------------------|
                      | pod cidir block   |
                      |-------------------|  

```

On master - by default we have (pod):  
 - coredns Pod                 
 - etcd Pod                    
 - kube-apiserver Pod          
 - kube-controller-manager Pod 
 - kube-proxy Pod              
 - kube-scheduler Pod
 - and additional/optional pods for the kubernetes plugins pods i.g (flannel plugin)          

 On worker-node 2 - by default we have (pod): 
 - kube-proxy Pod              
 - and pod for the apps
 
 On worker-node 2 - by default we have (pod):  
 - kube-proxy Pod              
 - and pod for the apps
 
     

### Install all these packages on all 3 servers
 ##### (There is a script that install all the necessary packages in all kubernetes automaticaly `kubernetes-install-master-and-nodes-script.sh` just need to run that in all servers and use an additional configuration to define the kunernetes-master `control plane`.)
  - Install kubelet(1.18.1-00), kubeadm(1.18.1-00), and kubectl(1.18.1-00) - test kubeadm installation
```
sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update

KUBE_COMPONENT_VERSION=1.18.1-00
sudo apt-get install -y kubelet=$KUBE_COMPONENT_VERSION kubeadm=$KUBE_COMPONENT_VERSION kubectl=$KUBE_COMPONENT_VERSION
sudo apt-mark hold kubelet kubeadm kubectl
kubeadm version

```

  - Install and test docker(18.06.1~ce~3-0~ubuntu) 90 installation 
```
sudo apt-get update -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update -y
## install latest docker-engine docker-engine-client
sudo apt-get install docker-ce docker-ce-cli containerd.io

# install a specific verions (docker engine and docker client) [docker(18.06.1~ce~3-0~ubuntu]
#sudo apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu && sudo apt-mark hold docker-ce

sudo docker version

```


### Initialize the cluster
On the Kube master node only network CIDR=10.244.0.0/16:
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

# This is a sample commands when the command plane (kubernetes master) is ready to accepct the worker-node
# $ sudo kubeadm join 172.31.39.233:6443 --token 3jmd1a.1evrjd9gcgclo0wf \
#   --discovery-token-ca-cert-hash #sha256:a239c09128b0db3d5319333936c48ac0626321b9bea214e8075479d5155af

sudo kubeadm join $some_ip:6443 --token $some_token --discovery-token-ca-cert-hash $some_hash

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

### Install Flannel-plugin (CNI) for the pods communication (translating over the container's ip and the node's ip addresses) in the cluster by running this on the Master node ONLY!
More info about the CNI plugins  here ==> https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network

And more info about the 'add-ons' which extend the functionality of Kubernetes. ==> https://kubernetes.io/docs/concepts/cluster-administration/addons/
```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

```

### To verify that the Flannel pods are up and running. Run this command to get a list of system pods:
```
kubectl get pods -n kube-system
```

### Joing the node to a cluster (node 1 and node 2)
After get the kubeadm command run on the nodes to joing them into a cluster:
```
sudo kubeadm join $some_ip:6443 --token $some_token --discovery-token-ca-cert-hash $some_hash
```
#### In order to make sure each component object gets into it's node assign a lable to the nodes, i.e: `kubectl label nodes <node name> <label-name>=<value>`
```
kubectl label nodes db-server node=database
kubectl label nodes k-node1 node=web
```

### Add this line to /etc/sysctl.conf for 'flannel' plugin to connect the nodes and the master on the same network 
```
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
```
### sysctl - configure kernel parameters at runtime. To Load in sysctl settings from the file specified or /etc/sysctl.conf
```
sudo sysctl -p
```

### The kubernetes cluster should be up and running with one master and nodes
=================================================================================


## To interact with the `nodes` we need to run commands from the `master (controller)`
Get all (pods, service, deployment)
`kubectl get all`

Get all nodes assigned to a master on a cluster
`kubectl get nodes`
`kubectl get nodes -o wide`

# Get commands with basic output, adding the option (-o wide) can be benefitial because it's add a bit of more details from the objetc requested

```
echo "source <(kubectl completion bash)" >> ~/.bashrc # add autocomplete permanently to your bash shell.
echo "alias k=kubectl" >> ~/.bashrc # in case an optional invocation of 'kubectl' with 'k' wanted
```

Some more alias that helps for the CKA certification

```
alias k='kubectl'
alias kc='kubectl create -f' # 'create' and 'apply' are similar but 'create' would trown an error if object already exist, 'apply' woundn't.
alias ka='kubectl apply -f'
alias kr='kubectl run'
alias kg='kubectl get'
alias kd='kubectl describe'
alias ke='kubectl explain'
alias kx='kubectl expose'
alias kexec='kubectl exec'
```

Reload the session
```
source ~/.bashrc # to make it reload the session and autocomplete will be ready to work with `kubectl get + TAB`
```

Usefull commands for debug and list resources [objects]
```
# 
kubectl config get-contexts                         # List all contexts 
Set the context "kubernetes-admin@kubernetes" to be on a particular namespace "k8s-challenge-2-a"
kubectl config set-context kubernetes-admin@kubernetes --namespace=k8s-challenge-2-a 

#
kubectl get componentstatus                         # Get status of the component [controller-manager, scheduler, etcd-0]

#
kubectl get node                                    # List all nodes (worker-node)
kubectl describe node node1                         # Describe a particular node-server (worker-node)

#
kubectl get namespace                               # List all namespace 
kubectl get namespace my-app                        # List particular namespace 

#
kubectl get services                                # List all services in the namespace ( service == svc)
kubectl describe svc nginx-service                  # Describe a particular service
kubectl delete svc nginx-service                    # Delete a particular service


#
kubectl get deployment                              # List all deployment
kubectl describe deployment nginx-service           # Describe a particular deployment
kubectl delete deployment nginx-deployment          # Delete a particular deployment


#
kubectl get rs                                      # List all replicaSet
kubectl describe rs nginx-replicaset                # Describe a particular replicaSet


#
kubectl get pods --all-namespaces                   # List all pods in all namespaces
kubectl get pods                                    # List all deployment (not list the default pods)
kubectl get pods -o wide                            # List all pods in the namespace, with more details
kubectl get pod my-pod -o yaml                      # Get a pod's YAML
kubectl get pod my-pod -o yaml --export             # Get a pod's YAML without cluster specific information
kubectl describe pod nginx-service                  # Describe a particular pod
kubectl delete pod nginx-pod                        # Delete a particular pod


#
kubectl logs my-pod                                 # dump pod logs (stdout)
kubectl logs -l name=myLabel                        # dump pod logs, with label name=myLabel (stdout)
kubectl logs my-pod --previous                      # dump pod logs (stdout) for a previous instantiation of a container
kubectl logs my-pod -c my-container                 # dump pod container logs (stdout, multi-container case)
kubectl logs -l name=myLabel -c my-container        # dump pod logs, with label name=myLabel (stdout)
kubectl logs my-pod -c my-container --previous      # dump pod container logs (stdout, multi-container case) for a previous instantiation of a container
kubectl logs -f my-pod                              # stream pod logs (stdout)
kubectl logs -f my-pod -c my-container              # stream pod container logs (stdout, multi-container case)
kubectl logs -f -l name=myLabel --all-containers    # stream all pods logs with label name=myLabel (stdout)


#
kubectl get endpoints                               # List of endpoints in your cluster that get created with a service:


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

### Deploy one POD to the cluster with a deployment object kind.
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
  replicas: 1
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


If neccessary start a busybox pod for debugging, with this pod we can ping the containers and run some cmd insite the cluster to check connectivity: ( `wget -qO- POD_IP_ADDRESS:80`)
```
kubectl run busybox --image=busybox --rm -it --restart=Never -- sh
```


### Deploy the Stan's Robot Shop app to the cluster.
=================================================================================

Clone the Git repo that contains the pre-made descriptors:

`cd ~/ &&  git clone https://github.com/linuxacademy/robot-shop.git`

Or get the robot-shop project YAML files from PATH:

`kubernetes/robot-shop-K8s-descriptors`

Since this application has many components, it is a good idea to create a separate namespace for the app:

`kubectl create namespace robot-shop`

Deploy the app to the cluster:

`kubectl -n robot-shop create -f ~/robot-shop/K8s/descriptors/`

Check the status of the application's pods:
`kubectl get pods -n robot-shop`

To reach the robot shop app from your browser using the Kube master node's public IP: http://$kube_master_public_ip:30080
