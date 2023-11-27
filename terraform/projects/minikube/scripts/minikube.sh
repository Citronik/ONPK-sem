

K8S_VERSION="{{ k8s_version }}"


echo "Starting minikube.sh"

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubectl

sudo apt-get install bash-completion

source /usr/share/bash-completion/bash_completion

echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
source ~/.bashrc

# su - ubuntu -c "minikube start --kubernetes-version=${K8S_VERSION} --nodes=3"
# su - ubuntu -c "minikube addons enable ingress"
# su - ubuntu -c "minikube status"

minikube start --kubernetes-version=${K8S_VERSION} --nodes=3
minikube addons enable ingress
minikube status

echo "minikube.sh DONE"