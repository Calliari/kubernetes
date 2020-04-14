# kubernetes-deployment
This is a kubernetes cluster from scratch part (Create a deployment for having a numbers of pods that we need for the application in the cluster with a self-healing and scalability to pods with a possibility to rollback, bluegreen deploy, cannary deploy and etc)


For this simple cluster to work 3 servers are needed.
 - 1 for kubernetes master
 - 1 for kubernetes node 1
 - 1 for kubernetes node 2


To create a pod make sure the cluster is running with the master and worker-nodes successfuly

These are the services that are accessed by the clients/users (ClusterIP, NodePort, LoadBalancer).There are 3 types of services (ClusterIP, NodePort, LoadBalancer)

ssh into the master `control plane` and run the following to create a service:

<hr></hr>

- deployment
    This is the deployment created inside a cluster. So basically we use this type of object when we want to self-healing and scalability to pods with possibility rollback, bluegreen deploy, cannary deploy. 
    
    #### Create the nginx deployment using the `type: deployment` from the file called 'nginx-deployment.yaml'
     `kubectl apply -f nginx-deployment.yaml --record # record flag allow a easy rollback` 

    ```
    kubectl get deploy -o wide
    kubectl get deploy nginx-deployment -o wide
    ```

    Check the status of the deployment 
    ```
    kubectl rollout status deployment nginx-deployment
    ```

    Check the history of the deployment (the record flag keep tracking the deployments)
    ```
    kubectl rollout history deployment nginx-deployment
    ```

    To use the history of the deployment to rollback (the record flag keep tracking the deployments)
    ```
    kubectl rollout undo deployment nginx-deployment --to-revision=1
    ```

    To scale the delyment we can update the yaml file and re-deployment with record flag keep tracking the deployments or scale the pods imperativelly (not a good practise)
    ```
    kubectl scale deployment nginx-deployment --replicas=5
    ```