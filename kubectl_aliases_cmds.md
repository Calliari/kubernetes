### Some more alias that helps for the CKA certification
```
echo "source <(kubectl completion bash)" >> ~/.bashrc # add autocomplete permanently to your bash shell.
```

##### Aliases
```
cat <<EOF >> ~/.bash_profile
alias k='kubectl'
alias kc='kubectl create -f' # 'create' and 'apply' are similar but 'create' would trown an error if object already exist, 'apply' woundn't.
alias ka='kubectl apply -f'
alias kr='kubectl run'
alias kg='kubectl get'
alias kd='kubectl describe'
alias ke='kubectl explain'
alias kx='kubectl expose'
alias kexec='kubectl exec'
EOF
```

##### Reload the session
source ~/.bashrc # to make it reload the session and autocomplete will be ready to work with `kubectl get + TAB`
source ~/.bash_profile # to make it reload the aliases


### To interact with the `nodes` we need to run commands from the `master (controller)`
#### Get commands with basic output
```
kubectl get namespace                         # List all namespace 
kubectl get services                          # List all services in the namespace
kubectl get pods --all-namespaces             # List all pods in all namespaces
kubectl get pods -o wide                      # List all pods in the namespace, with more details
kubectl get deployment my-dep                 # List a particular deployment
kubectl get pods                              # List all pods in the namespace
kubectl get pod my-pod -o yaml                # Get a pod's YAML
kubectl get pod my-pod -o yaml --export       # Get a pod's YAML without cluster specific information
kubectl get endpoints                         # List of endpoints in your cluster that get created with a service:

```

Get all (pods, services, deployments)
`kubectl get all`

Get all nodes assigned to a master on a cluster
`kubectl get nodes`
`kubectl get nodes -o wide`

Get logs, debugs from node:
`kubectl get node $node_name_here`
`kubectl describe node $node_name_here`

Pods CMD
`kubectl get pods --all-namespaces`

To get logs, debug a pod we run:
`kubectl get pods $pod_name_here` # if the 'namespace' is not explicity definided, kubernetes will use the 'default' namespace
`kubectl get pods $pod_name_here --namespace $namespace_here`
`kubectl get pods $pod_name_here -o wide --namespace $namespace_here`
`kubectl describe pods $pod_name_here`


