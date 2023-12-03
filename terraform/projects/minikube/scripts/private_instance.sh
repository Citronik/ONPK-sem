#!/bin/bash

echo "Starting updating.sh"

if ! grep -q "$(hostname)" /etc/hosts; then
    echo "127.0.0.1 $(hostname)" >> /etc/hosts
    echo "Hostname and /etc/hosts updated: $(hostname)"
fi

if ! grep -q "158.193.152.4" /etc/resolv.conf; then
    echo "nameserver 158.193.152.4
    nameserver 8.8.8.8" >> /etc/resolv.conf
    echo adding DNS
fi

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales

apt-get update
apt-get upgrade -y

apt-get install -y git curl wget

#exec > >(tee /var/log/user_data.log) 2>&1

echo "updating.sh DONE"

#------------------------------------------------------------

echo "Starting docker.sh"

if docker --version >> /dev/null; then
    echo "docker already installed "
else

    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt-get remove $pkg; done

    # Add Docker's official GPG key:
    apt-get update -y
    apt-get install ca-certificates curl gnupg -y
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    # Add the repository to Apt sources:
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y

    apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    # postinstall
    echo "docker postinstall"
    groupadd docker
    #usermod -aG docker $USER
    usermod -aG docker ubuntu
fi

docker run hello-world

echo "docker.sh DONE"

#------------------------------------------------------------

K8S_VERSION="{{ k8s_version }}"


echo "Starting minikube.sh"

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube

# apt-transport-https may be a dummy package; if so, you can skip that package
apt-get install -y apt-transport-https ca-certificates curl

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubectl

apt-get install bash-completion

source /usr/share/bash-completion/bash_completion

echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
source ~/.bashrc

echo "Starting minikube"
echo "K8S_VERSION: ${K8S_VERSION}"

# minikube start --kubernetes-version=${K8S_VERSION} --nodes=3
# minikube addons enable ingress
# minikube status

su - ubuntu -c "minikube start --kubernetes-version=${K8S_VERSION} --nodes=3"
su - ubuntu -c "minikube addons enable ingress"
su - ubuntu -c "minikube status"

echo "minikube.sh DONE"