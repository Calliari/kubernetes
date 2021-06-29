### Get some sample yaml without creating the object 'deployment' imperatively.
```
kubectl create deployment my-deployment --image=nginx --dry-run -o yaml
# or pipe the skeleton to a file for customising
kubectl create deployment my-deployment --image=nginx --dry-run -o yaml > deployment.yml
```

### Scale a deployment and record imperatively
```
kubectl scale deployment my-deployment replicas=5 --record
```

### Get some details from object 'deployment' named 'my-deployment'
```
kubectl describe deployment my-deployment
```