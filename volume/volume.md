#### Yml file Pod that uses a hostPath volume to store data on the host.

```
cat > volume-pod.yml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: volume-pod
spec:
  containers:
  - name: busybox
  - image: busybox
    command: ['sh', '-c', 'echo Success! > /output/success.txt']
    volumeMounts:
     - name: my-volume
       mountPath: /output # This path will be on the pod (containers: busybox)
  volumes:
  - name: my-volume
    hostPath:
      path: /var/data # This path will be on the worker-node
EOF
```

#### Create Pod that uses a hostPath volume to store data on the host.
```
kubectl create -f volume-pod.yml
```

##### 
Check which worker node the pod is running on.
```
kubectl get pod volume-pod -o wide
```

#### Log in to that host and verify the contents of the output file.
```
cat /var/data/success.txt
```

<hr>

#### Create a multi-container Pod with an emptyDir volume shared between containers.
```
cat > shared-volume-pod.yml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: shared-volume-pod
spec:
  containers:
  - name: busybox1
  - image: busybox
    command: ['sh', '-c', 'while true; do echo Success! > /output/success.txt; sleep; done']
    volumeMounts:
     - name: my-volume
       mountPath: /output # This path will be on the pod (containers: busybox1)
 
  - name: busybox2
  - image: busybox
    command: ['sh', '-c', 'while true; do cat /input/success.txt; sleep; done']
    volumeMounts:
     - name: my-volume
       mountPath: /input # This path will be on the pod (containers: busybox2)
  volumes:
  - name: my-volume
    emptDir:
      path: {} # This path will ...

EOF
```
