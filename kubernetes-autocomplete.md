Reference https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

### Test if bash-completion is already installed:
```
type _init_completion
```

### You can install it with
```
apt-get install bash-completion 
# or 
yum install bash-completion
```

##### The above commands create `/usr/share/bash-completion/bash_completion`.
```
echo 'source /usr/share/bash-completion/bash_completion' >> ~/.bashrc
```

### Enable kubectl autocompletion
```
echo 'source <(kubectl completion bash)' >> ~/.bashrc
kubectl completion bash | sudo tee -a /etc/bash_completion.d/kubectl

echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc
```

### Reoad the bash shell
```
source ~/.bashrc
```
