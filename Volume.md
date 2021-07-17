There are two type of storage to use on the k8s cluster `Volume` and `PersistentVolume`.

### In order to allow a pod to user `Volume`.
#### Create `Volume` storage object within a pod .
```
cat > volume-pod.yml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: volume-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ['sh', '-c', 'echo Success! > /output/success.txt']
    volumeMounts:
     - name: my-volume # This need to match the 'volumes: - name:'
       mountPath: /output # This path will be on the pod (containers: busybox)
  volumes:
  - name: my-volume # volumes' name to be used by the pod
    hostPath:
      path: /var/data # This path will be on the worker-node
EOF
```

```
# Get the pod
kubectl get pod volume-pod -o wide
```
<hr>

#### Create a multi-container Pod with an emptyDir volume shared between containers, (This one is ephemeral and the data on the `volumes` will be erased when a pod is terminated).
```
cat > shared-volume-pod.yml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: shared-volume-pod
spec:
  containers:
  - name: busybox1
    image: busybox
    command: ['sh', '-c', 'while true; do echo Success! > /output/success.txt; sleep; done']
    volumeMounts:
     - name: shared-vol
       mountPath: /output # This path will be on the pod (containers: busybox1)
  - name: busybox2
    image: busybox
    command: ['sh', '-c', 'while true; do cat /input/success.txt; sleep; done']
    volumeMounts:
     - name: shared-vol
       mountPath: /input # This path will be on the pod (containers: busybox2)
  volumes:
  - name: shared-vol
    emptyDir: {} # Which is erased when a pod is removed/destroyed/terminated
EOF
```

<hr>

### In order to allow a pod to use `PersistentVolume`, it needs to exist first and this store is a object of the cluster.
*PersistentVolumeClaims reference a storageclass, and they must reference the same StorageClass as a PersistentVolume in order to bind to that PersistentVolume.*
#### 1/3) Create `StorageClass` config object first to be used by `PersistentVolume`.
```
cat > volume-StorageClass.yml <<'EOF'
apiVersion: storage.k8s.io/v1 
kind: StorageClass 
metadata: 
  name: localdisk # name to be used by 'PersistentVolume'
provisioner: kubernetes.io/no-provisioner
allowVolumeExpansion: true # Allow the 
EOF
```

```
# Get the StorageClass
kubectl get sc -o wide
```


#### 2/3) Create `PersistentVolume` storage object within a pod.
```
cat > volume-PersistentVolume.yml <<'EOF'
kind: PersistentVolume 
apiVersion: v1 
metadata: 
   name: host-pv 
spec: 
   storageClassName: localdisk # use the name of 'StorageClass' that will be connect to this 'PersistentVolume' object
   persistentVolumeReclaimPolicy: Recycle # [Retain, Delete, Recycle]
   capacity: 
      storage: 1Gi # stoge allocated to PersistentVolume as MAX that the pod can use
   accessModes: 
      - ReadWriteOnce 
   hostPath: 
      path: /var/output # this will be available on the host 'worker-node' where the pod will be running.
EOF
```

```
# Get the PersistentVolume
kubectl get pv -o wide
```

#### 3/3) Create `PersistentVolumeClaim` object, this is be clam the `PersistentVolume` created.
```
cat > volume-PersistentVolumeClaim.yml <<'EOF'
apiVersion: v1 
kind: PersistentVolumeClaim 
metadata: 
   name: host-pvc 
spec: 
   storageClassName: localdisk # use the name of 'StorageClass' that will be connect to this 'PersistentVolumeClaim' object
   accessModes: 
      - ReadWriteOnce 
   resources: 
      requests: 
         storage: 100Mi # Use 100M from 1G on the `PersistentVolume`
EOF
```

```
# Get the PersistentVolumeClaim
kubectl get pvc -o wide
```

<hr>

### Create a pod to use the storage
```
cat > pod-using-volumes.yml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
   name: pv-pod
spec:
   containers:
   - name: busybox
     image: busybox
     command: ['sh', '-c', 'while true; do echo Success! > /output/success.txt; sleep 5; done'] # piping some text to this path
     volumeMounts:
     - name: pv-storage # Mount the path `/output` to the `volumes` spec.volumes.name
       mountPath: /output
   volumes:
   - name: pv-storage
     persistentVolumeClaim:
        claimName: host-pvc # connect this pod to `PersistentVolumeClaim`
EOF
```

```
# Get the PersistentVolumeClaim
kubectl get pod pv-pod -o wide
```