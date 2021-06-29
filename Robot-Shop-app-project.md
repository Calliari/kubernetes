

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
