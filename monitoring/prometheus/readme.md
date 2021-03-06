Set up Prometheus monitoring in a Kubernetes cluster.

#### Reference 
https://phoenixnap.com/kb/prometheus-kubernetes-monitoring <br/>
https://sysdig.com/blog/kubernetes-monitoring-prometheus <br/>

These are option to use k as alias for kubectl and apply/deploy the yaml objects 
```
alias k=kubectl;
kubectl create -f - <<EOF
kuberneter yaml objects here
EOF

```

<hr/>

#### Prometheus Namespace, ServiceAccount, ClusterRole, ClusterRoleBinding (prometheus-space-sa.yml)
Tutorial on Prometheus monitoring on Kubernetes Cluster
Create Monitoring Namespace:
```
---
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
```

`k -n monitoring get ns`


Create Service Account for Monitoring
```
apiVersion: v1
kind: ServiceAccount
metadata:
  namespace: monitoring-sa
  name: prometheus-service-sccount
```

`k -n monitoring get sa`

#### Prometheus ClusterRole, ClusterRoleBinding (prometheus-cr-crb.yml)
Define Cluster Role for Monitoring
```
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: prometheus-cr
rules:
- apiGroups: [""]
  resources:
  - nodes
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
- apiGroups:
  - extensions
  resources:
  - ingresses
  verbs: ["get", "list", "watch"]
```

`k get ClusterRole`

Define ClusterRoleBinding for Monitoring (By adding these resources to our file, we have granted Prometheus cluster-wide access from the monitoring namespace.)
```
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: prometheus-crb
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus-cr
subjects:
- kind: ServiceAccount
  name: prometheus-sa
  namespace: monitoring
```


`k get ClusterRoleBinding`

#### Prometheus ConfigMap (prometheus-configMap.yml)

This section of the file provides instructions for the scraping process. Specific instructions for each element of the Kubernetes cluster should be customized to match your monitoring requirements and cluster setup.
Global Scrape Rules
```
---
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: monitoring
  name: prometheus-cm
  labels:
    name: prometheus-ConfigMap
data:
  prometheus.yml: |-
    global:
      scrape_interval:     10s # Set the scrape interval to every 10 seconds. Default is every 1 minute.
      evaluation_interval: 10s # Evaluate rules every 10 seconds. The default is every 1 minute.

    scrape_configs:
    
      - job_name: 'prometheus'
        scrape_interval: 5s
        static_configs:
        - targets: ['localhost:9090']
          
      - job_name: node_exporter
        static_configs:
          - targets: ["localhost:9100"]
          
      - job_name: 'kubernetes-service-endpoints'
        kubernetes_sd_configs:
        - role: endpoints
        relabel_configs:
        - action: labelmap
          regex: __meta_kubernetes_service_label_(.+)
        - source_labels: [__meta_kubernetes_namespace]
          action: replace
          target_label: kubernetes_namespace
        - source_labels: [__meta_kubernetes_service_name]
          action: replace
          target_label: kubernetes_name


```

`k -n monitoring get cm`

Scrape Node
This service discovery exposes the nodes that make up your Kubernetes cluster. The kubelet runs on every single node and is a source of valuable information.
Scrape kubelet
```
    scrape_configs:

      - job_name: 'kubelet'
        kubernetes_sd_configs:
        - role: node
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          insecure_skip_verify: true  # Required with Minikube.
```

Scrape cAdvisor (container level information)
The kubelet only provides information about itself and not the containers. To receive information from the container level, we need to use an exporter. The cAdvisor is already embedded and only needs a metrics_path: /metrics/cadvisor for Prometheus to collect container data:
```
      - job_name: 'cadvisor'
        kubernetes_sd_configs:
        - role: node
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          insecure_skip_verify: true  # Required with Minikube.
        metrics_path: /metrics/cadvisor
```

Scrape APIServer
Use the endpoints role to target each application instance. This section of the file allows you to scrape API servers in your Kubernetes cluster.
```
  - job_name: 'k8apiserver'
    kubernetes_sd_configs:
    - role: endpoints
    scheme: https
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      insecure_skip_verify: true  # Required if using Minikube.
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    relabel_configs:
  - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
    action: keep
    regex: default;kubernetes;https
```

Scrape Pods for Kubernetes Services (excluding API Servers)
Scrape the pods backing all Kubernetes services and disregard the API server metrics.
```
      - job_name: 'k8services'
        kubernetes_sd_configs:
        - role: endpoints
          relabel_configs:
            - source_labels:
                - __meta_kubernetes_namespace
                - __meta_kubernetes_service_name
              action: drop
              regex: default;kubernetes
            - source_labels:
                - __meta_kubernetes_namespace
              regex: default
              action: keep
            - source_labels: [__meta_kubernetes_service_name]
              target_label: job
```

Pod Role
Discover all pod ports with the name metrics by using the container name as the job label.
```
      - job_name: 'k8pods'
        kubernetes_sd_configs:
        - role: pod
          relabel_configs:
          - source_labels: [__meta_kubernetes_pod_container_port_name]
            regex: metrics
            action: keep
          - source_labels: [__meta_kubernetes_pod_container_name]
            target_label: job
```


#### Prometheus ReplicaSet (prometheus-deploy-rs.yml)
Configure ReplicaSet
Define the number of replicas you need, and a template that is to be applied to the defined set of pods.
```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: monitoring
  name: prometheus-deployment
  labels:
    app: prometheus-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus-app
  template:
    metadata:
      labels:
        app: prometheus-app
    spec:
      serviceAccountName: prometheus-sa
      containers:
      - name: prometheus-app
        image: prom/prometheus:v2.1.0
        ports:
        - containerPort: 9090
          name: default
        volumeMounts:
        - name: config-volume
          mountPath: /etc/prometheus
      volumes:
      - name: config-volume
        configMap:
         name: prometheus-cm
```

`k -n monitoring get deploy`


#### Prometheus Service (prometheus-service.yml) (nodePort)
Define nodePort
Prometheus is currently running in the cluster. Adding the following section to our prometheus.yml file is going to give us access to the data Prometheus has collected.
```
---
kind: Service
apiVersion: v1
metadata:
  namespace: monitoring
  name: prometheus-svc
  labels:
    app: prometheus-svc-NodePort
spec:
  selector:
    app: prometheus-app # this is where the service would be binding the traffic to expose
  type: NodePort # this is using the nodePort for the service be available (http://NODE-IP-ADDRESS:30090)
  ports:
  - name: http
    protocol: TCP
    port: 9090 # host port of the service expose (service)
    nodePort: 30090 # host port of the worker-node (node)
    targetPort: 9090  # container port (pod)
       
```

`k -n monitoring get svc`


#### Prometheus Service (prometheus-service.yml) (LoadBalancer)
Define LoadBalancer
Prometheus is currently running in the cluster. Adding the following section to our prometheus.yml file is going to give us access to the data Prometheus has collected.
```
kind: Service
apiVersion: v1
metadata:
  namespace: monitoring
  name: prometheus-svc
  labels:
    app: prometheus-svc-LoadBalancer
spec:
  selector:
    app: prometheus-app # this is where the service would be binding the traffic to expose (app = container running inside pod)
  type: LoadBalancer
  ports:
  - protocol: TCP
    port: 9090
    targetPort: 9090
    nodePort: 30090
        
```

`k -n monitoring get svc`


#### Use the individual node URL and the nodePort defined in the prometheus.yml file to access Prometheus from your browser. 
By entering the URL or IP of your node, and by specifying the port from the yml file, you have successfully gained access to Prometheus Monitoring.
For example: `http://192.153.99.106:30090`


Checking all the objects created with a flag `-o` and `wide`
```
k -n monitoring get ns -o wide
k -n monitoring get sa -o wide
k get ClusterRole -o wide
k get ClusterRoleBinding -o wide
k -n monitoring get cm -o wide
k -n monitoring get deploy -o wide
k -n monitoring get svc -o wide
```

