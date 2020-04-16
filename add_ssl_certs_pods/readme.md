# kubernetes-Secrets ssl for port 443
This is a kubernetes cluster from scratch part (Create a pod for serving traffic on port 443 with ssl certs)

View the secrets in your cluster:
```
kubectl get secrets
kubectl describe secret example-https
```

Generate a key for your https server:
```
mkdir www.example.com_certs && cd www.example.com_certs
openssl genrsa -out www.example.com.key 2048
```

Generate a certificate for the https server:
```
openssl req -new -x509 -key www.example.com.key -out www.example.com.cert -days 3650 -subj /CN=www.example.com
```
Create an empty file to create the secret:
```
touch file
```

Create a secret from your key, cert, and file:
```
kubectl create secret generic example-https --from-file=www.example.com.key --from-file=www.example.com.cert --from-file=file
kubectl describe secret example-https
```

View the YAML from your new secret:
```
kubectl get secrets example-https -o yaml
```

New create the `configmap`, the `nginx-pod-with-certs` which will use the configmap and the `nginx-pod-without-certs`

```
kubectl apply -f configmap-https.yaml
kubectl get configmap -o yaml
```
```
kubectl apply -f nginx-pod-with-certs.yaml nginx-pod-without-certs.yaml
```

so to get a shell to the specifc running Container in a pod:
```
kubectl exec -it nginx-pod-with-https -c web-server sh
```

With this command we can check whe the certs are monted on the pod 'nginx-pod-with-https' conatiner 'web-server';
```
kubectl exec nginx-pod-with-https -c web-server -- mount | grep certs
```

Use port forwarding on the pod to server traffic from 443:
```
kubectl port-forward nginx-pod-with-https 8443:443 &
```

Curl the web server to get a response, from the cluster that you are biding the port:
```
curl https://localhost:8443 -k
```

Or you can use the below command and load the site from an incognito brower:

ssh connection with `-L` flag.
|
`ssh -L` 
port on laptop that your are using. 
        |
        `8443`: 
localhost on laptop that your are using.
                |
                `127.0.0.1`:
localhost on cluster that your are binding with (kubectl port-forward ).
                            |
                            `8443`
The username and the ip address of the server that ssh is being used.
                                    |
                                    `username@18.130.220.172`

```
ssh -L 8443:127.0.0.1:8443 username@18.130.220.172
```

Open a browser on incognito with: (https://127.0.0.1:8443/)
```
open -a Google\ Chrome --new --args -incognito "https://127.0.0.1:8443"
open -a Safari --fresh --args # and add this is the private browser "https://127.0.0.1:8443" 
```