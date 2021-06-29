### RBAC-Role-Based-Access-Control.md
#### Create and apply a 'Role' spec file: (1/4)
```
cat <<EOF | tee pod-reader-role.yml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: beebox-mobile
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "watch", "list", "delete"]
EOF

```

#### Apply the 'Role': (2/4)
```
kubectl apply -f pod-reader-role.yml
```

#### Create the 'RoleBinding' spec file: (3/4)
```
cat <<EOF | tee pod-reader-rolebinding.yml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader
  namespace: beebox-mobile
subjects:
- kind: User
  name: dev
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
EOF
```

#### Apply the 'RoleBinding': (4/4)
```
kubectl apply -f pod-reader-rolebinding.yml
```


############# Service Account #############