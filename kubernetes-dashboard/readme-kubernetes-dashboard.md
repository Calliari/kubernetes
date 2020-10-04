# kubernetes-dashboard GUI
https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

#### References 
https://github.com/kubernetes/dashboard

This is a kubernetes dashboard that allows to manage and configure the kubernetes cluster from GUI

After all setting and configuration are done to have the kubernetes cluster up and running do the fowwling to install and run the kubernetes-dashboard GUI.


alias k=kubectl # to make a k as a short for kubectl

Deploy the dashboard from the file saved on this repo ro direcly from the url on this repo:
```
kubectl apply -f kubernetes-dashboard.yml
OR
kubectl apply -f https://raw.githubusercontent.com/Calliari/kubernetes/verion-1.18/kubernetes-dashboard/kubernetes-dashboard.yml
```

By default kubernetes-dashboard can only be accessible by machine itself and port `localhost:8001` or `127.0.0.1:8001`. 
This will show the apis available but the grafical interface will be at `http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login` . (As the kubernetes-dashboard need to be very secure - I will be using binding the access via ssl -L CMD)
```
ssh -i PRIVATE-KEY -L 8001:127.0.0.1:8000 SERVER_USER@SERVER_IP_WHERE_kubernetes-dashboard-is-running
```



And an for of Authentication is required as this is a admin section, so creat a user to access the GUI.
https://kubernetes.io/docs/reference/access-authn-authz/authentication/
https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md


1) creating Service Account with name admin-user in namespace kubernetes-dashboard first.
```
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF
```

2) Creating a ClusterRoleBinding.
```
cat <<EOF | kubectl create -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF
```

3) Getting a Bearer Token
For Bash:
```
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

```

For Powershell:
```
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | sls admin-user | ForEach-Object { $_ -Split '\s+' } | Select -First 1)
```



Now copy the token and paste it into Enter token field on the login screen.
Click Sign in button and that's it. You are now logged in as an admin.
``



