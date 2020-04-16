### we’ll go through how to set Docker|Kubernetes to use a private registry.

#### For Docker private registry.

<hr></hr>

Docker For Log in to the docker Hub:
```
sudo docker login
```

#### existent container registry credentials configured can be found here, if its blank there is no container registry credentials configured yet.
```
sudo cat /home/$USERNAME/.docker/config.json
```



Azure|GCP|AWS Log in to private container registry using the docker login command:
- -u for username: 'podofminerva'
- -p for password:  'otj701c9OuqrRblofcNRf3W'
i.g on AZURE it can be found on the azure console container registry
- podofminerva.azurecr.io for `login-server` 

```
sudo docker login -u podofminerva -p 'otj701c9OuqrRblofcNRf3W+e' podofminerva.azurecr.io
```

Credentials added on ==> `/home/$(whoami)/.docker/config.json`

<hr></hr>

#### For Kubernetes private registry.

Kubernetes can create a few secrets we are going to use the `docker-registry secret:`
This cmd shows all available
```
kubectl create secret 
```


Create a new docker-registry secret for private container registry (CR):
secrete name: acr
DNS to access the CR: https://podofminerva.azurecr.io

```
kubectl create secret docker-registry acr --docker-server=https://podofminerva.azurecr.io --docker-username=podofminerva --docker-password='otj701c9OuqrRblofcNRf3W+e' --docker-email=user@example.com
```

Modify the default service account to use your new docker-registry secret `acr`:
```
kubectl patch sa default -p '{"imagePullSecrets": [{"name": "acr"}]}'
```

Check the default service account configured
```
kubectl get sa default -o yaml
```

The YAML for a pod using an image from a private repository:
```
apiVersion: v1
kind: Pod
metadata:
  name: acr-pod
  labels:
    app: busybox
spec:
  containers:
    - name: busybox
      # this is where the images will be download from private container registry 
      image: podofminerva.azurecr.io/busybox:latest 
      command: ['sh', '-c', 'echo Hello Kubernetes! && sleep 3600']
      imagePullPolicy: Always
```