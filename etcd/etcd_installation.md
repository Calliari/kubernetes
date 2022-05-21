### ETCD depend on go, so follow the steps below to install go if necessary
```
# Download the go if needed "https://go.dev/doc/install"
curl -L https://go.dev/dl/go1.18.2.linux-amd64.tar.gz -o go.tar.gz

# extract the go into "/usr/local" dir, need sudo
sudo tar -C /usr/local -xzf go.tar.gz

# test "go path" and "go version"
export PATH=$PATH:/usr/local/go/bin

# If go is working save on the PATH "$HOME/.profile"
# get the new PATH 
printenv | grep PATH

echo PATH="${PATH:+${PATH}:}/usr/local/go/bin" >>  ~/.profile
source ~/.profile
```

### If etcd is not installed, run these commands on the control-plane
```
git clone -b v3.5.0 https://github.com/etcd-io/etcd.git
cd etcd
./build.sh

sudo mv etcd /usr/local/
sudo chown -R root:root /usr/local/etcd


# Remove the extra "PATH" in the profile added early and replace it with only one (removing with sed "sed -i '/^PATH=\//d' ~/.profile")
echo PATH="${PATH:+${PATH}:}/usr/local/etcd/bin" >>  ~/.profile
source ~/.profile
etcd --version
