# kubernetes-replicaSet
This is a kubernetes cluster from scratch part (Create a replicaSet for having a numbers of pods that we need for the application in the cluster with a self-healing and scalability to pods)


For this simple cluster to work 3 servers are needed.
 - 1 for kubernetes master
 - 1 for kubernetes node 1
 - 1 for kubernetes node 2


To create a pod make sure the cluster is running with the master and worker-nodes successfuly

These are the services that are accessed by the clients/users (ClusterIP, NodePort, LoadBalancer).There are 3 types of services (ClusterIP, NodePort, LoadBalancer)

ssh into the master `control plane` and run the following to create a service:

<hr></hr>

- replicaSet
    This is the replicaSet created inside a cluster. So basically we use this type of object when we want to self-healing and scalability to pods. 
    
    #### Create the nginx replicaSet using the `type: replicaSet` from the file called 'nginx-replicaSet.yaml'
    kubectl -f apply nginx-replicaSet.yaml

    ```
    kubectl get rs -o wide
    kubectl get rs nginx-replicaset -o wide

    ```