#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

# Installing yum-utils
yum install -y yum-utils
VALIDATE $? "Installed yum-utils"

# Adding Docker repository
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
VALIDATE $? "Added docker repo"

# Installing Docker components
yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
VALIDATE $? "Installed docker components"

# Starting and enabling Docker
systemctl start docker
VALIDATE $? "Started docker"

systemctl enable docker
VALIDATE $? "Enabled docker"

# Adding centos user to docker group
usermod -aG docker centos
VALIDATE $? "Added centos user to docker group"
echo -e "$R Logout and login again $N"

# Installing kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/kubectl
VALIDATE $? "Kubectl installation"

# Installing eksctl
#curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
#tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
#sudo mv /tmp/eksctl /usr/local/bin
#VALIDATE $? "eksctl installation"
sudo apt update
curl --silent --location "https://github.com/eksctl-io/eksctl/releases/download/v0.55.0/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version


# Installing kubens
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
VALIDATE $? "kubens installation"

# Installing Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Adding Helm repo for AWS EBS CSI Driver
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update

# Installing AWS EBS CSI Driver via Helm
helm upgrade --install aws-ebs-csi-driver \
    --namespace kube-system \
    aws-ebs-csi-driver/aws-ebs-csi-driver
VALIDATE $? "AWS EBS CSI Driver installation"

echo -e "$G All required components have been installed successfully! $N"
