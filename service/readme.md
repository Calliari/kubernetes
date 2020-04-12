# kubernetes-service
This is a kubernetes cluster from scratch part (Create a service for accessing the application outsite of the cluster with a realiable dns resolution to pods)


For this simple cluster to work 3 servers are needed.
 - 1 for kubernetes master
 - 1 for kubernetes node 1
 - 1 for kubernetes node 2


To create a pod make sure the cluster is running with the master and worker-nodes successfuly

These are the services that are accessed by the clients/users (ClusterIP, NodePort, LoadBalancer).There are 3 types of services (ClusterIP, NodePort, LoadBalancer)

ssh into the master `control plane` and run the following to create a service:

- ClusterIP
    This service is created inside a cluster and can only be accessed by other pods in that cluster. So basically we use this type of service when we want to expose a service to other pods within the same cluster. 
    `curl -i 10.244.2.3 # if all good, 200 HTTP request will be replied from the service`
    `curl -I `

    # Create the nginx service using the `type: ClusterIP` from the file called 'nginx-service-ClusterIP.yaml'
    kubectl -f apply nginx-service-ClusterIP.yaml

    ```
    curl -I 10.244.2.3 # if all good, 200 HTTP request will be replied from the nginx-service-ClusterIP
    curl -I `kubectl get svc -o wide | grep nginx |awk '{print $3}'`
    ```

- NodePort
    This service is created inside a cluster and can be accessed by inside and ouside cluster from any node with the port. So basically we use this type of service when we want to expose a service to other pods within the same cluster with node-ip and the port i.g (3.10.4.98:30000). 
    `curl -i 3.10.4.98:30000 # if all good, 200 HTTP request will be replied from node master (master)`
    `curl -i 35.178.41.50:30000 # if all good, 200 HTTP request will be replied from node node (node1)`
    `curl -i 35.178.188.54:30000 # if all good, 200 HTTP request will be replied from node node (node2)`

    # Create the nginx service using the `type: NodePort` from the file called 'nginx-service-NodePort.yaml'
    kubectl -f apply nginx-service-NodePort.yaml

    ```
    curl -I 10.244.2.3 # if all good, 200 HTTP request will be replied from the nginx-service-NodePort
    curl -I `kubectl get svc -o wide | grep nginx |awk '{print $3}'`
    ```


- LoadBalancer
    This service is created inside a cluster and can be accessed by inside and ouside cluster. So basically we use this type of service when we want to expose a service to other pods within the same cluster with node-ip and the port (3.10.4.98:30000). 
    `curl -i 3.10.4.98:30000 # if all good, 200 HTTP request will be replied from node master (master)`

    # Create the nginx service using the `type: LoadBalancer` from the file called 'nginx-service-LoadBalancer.yaml'
    kubectl -f apply nginx-service-LoadBalancer.yaml

    ```
    curl -I 10.244.2.3 # if all good, 200 HTTP request will be replied from the nginx-service
    curl -I `kubectl get svc -o wide | grep nginx |awk '{print $3}'`
    ```


