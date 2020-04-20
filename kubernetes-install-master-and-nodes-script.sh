#!/bin/bash

### Install all these packages on all all servers (Masters and worker-modes)

# Install Docker CE
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS
apt-get update && apt-get install -y \
  apt-transport-https ca-certificates curl software-properties-common gnupg2


curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

# install a perticular verion
#sudo apt-get install -y kubelet=1.18.1-00 kubeadm=1.18.1-00 kubectl=1.18.1-00

# install the lastest verison
sudo apt-get install -y kubelet kubeadm kubectl

# hold the verions of the packages installed on the time them was installed
sudo apt-mark hold kubelet kubeadm kubectl

### Add Docker’s official GPG key
sudo apt-get update -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
### Add Docker apt repository.
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

sudo apt-get update -y
## Install Docker CE.
## install latest docker-engine docker-engine-client
sudo apt-get install -y containerd.io docker-ce docker-ce-cli containerd.io

# install a specific verions (docker engine and docker client) [docker(18.06.1~ce~3-0~ubuntu]
#sudo apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu && sudo apt-mark hold docker-ce

# Restart docker.
sudo systemctl daemon-reload
sudo systemctl restart docker

echo -e "\n\nSHOW HOLD for Kubeadm, kubectl and kubelet -------------"
sudo apt-mark showhold
echo -e "\n\nSHOW Kubeadm, kubectl and  Verion -------------"
kubeadm version && kubectl version && kubectl describe  nodes | grep 'Kubelet Version'
echo -e "\n\nSHOW Docker Verion -------------"
sudo docker version
