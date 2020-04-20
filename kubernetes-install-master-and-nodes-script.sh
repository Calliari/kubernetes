#!/bin/bash

### Install all these packages on all all servers (Masters and worker-modes)

sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates gnupg2

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

# install a perticular verion
#sudo apt-get install -y kubelet=1.18.1-00 kubeadm=1.18.1-00 kubectl=1.18.1-00

# install the lastest verison
sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl

sudo apt-get update -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update -y
## install latest docker-engine docker-engine-client
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# install a specific verions (docker engine and docker client) [docker(18.06.1~ce~3-0~ubuntu]
#sudo apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu && sudo apt-mark hold docker-ce


echo -e "\n\nSHOW HOLD for Kubeadm, kubectl and kubelet -------------"
sudo apt-mark showhold
echo -e "\n\nSHOW Kubeadm, kubectl and  Verion -------------"
kubeadm version && kubectl version && kubectl describe  nodes | grep 'Kubelet Version'
echo -e "\n\nSHOW Docker Verion -------------"
sudo docker version
