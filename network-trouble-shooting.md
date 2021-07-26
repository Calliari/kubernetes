## Kubernetes network trouble-shooting swiss-army container
reference https://github.com/nicolaka/netshoot


YML structure for netshoot container/pod
```
cat <<EOF | tee netshoot.yml
apiVersion: v1
kind: Pod
metadata:
  name: netshoot
spec:
  containers:  
  - name: netshoot
    image: nicolaka/netshoot
    command: ['sh', '-c', 'while true; do sleep 5; done'] # keep the container running
EOF
```
Create the netshoot 
```
kubectl apply -f netshoot.yml
```

Access the container interactively to troubleshoot the networking pods such as (kube-proxy, core-dns)
```
kubectl exec --stdin --ttynetshoot -- /bin/sh
```
