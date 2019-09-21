#!/usr/bin/env bash

# Usage.
usage()
{
    echo "usage: node_setup.sh <CLUSTER_SECRET>"
}

if [[ $# -eq 0 ]] ; then
    usage
    exit 1
fi

# Constants.
CLUSTER_SECRET=$1
GO_IPFS_BINARY_URL=https://ipfs.io/ipns/dist.ipfs.io/go-ipfs/v0.4.22/go-ipfs_v0.4.22_linux-amd64.tar.gz
IPFS_CLUSTER_SERVICE_BINARY_URL=https://dist.ipfs.io/ipfs-cluster-service/v0.11.0/ipfs-cluster-service_v0.11.0_linux-amd64.tar.gz
IPFS_CLUSTER_CTL_BINARY_URL=https://dist.ipfs.io/ipfs-cluster-ctl/v0.11.0/ipfs-cluster-ctl_v0.11.0_linux-amd64.tar.gz

# Download go-ipfs
wget -O go-ipfs.tar $GO_IPFS_BINARY_URL && tar -xvf go-ipfs.tar && rm -rvf go-ipfs.tar

# Download ipfs-cluster-service
wget -O ipfs-cluster-service.tar $IPFS_CLUSTER_SERVICE_BINARY_URL && tar -xvf ipfs-cluster-service.tar && rm -rvf ipfs-cluster-service.tar

# Download ipfs-cluster-ctl
wget -O ipfs-cluster-ctl.tar $IPFS_CLUSTER_CTL_BINARY_URL && tar -xvf ipfs-cluster-ctl.tar && rm -rvf ipfs-cluster-ctl.tar

# Adding CLUSTER_SECRET to the profile.
echo 'export CLUSTER_SECRET='$CLUSTER_SECRET >> ~/.profile

# Adding PATH to the profile.
echo 'export PATH=$PATH:~/go-ipfs:~/ipfs-cluster-service:~/ipfs-cluster-ctl' >> ~/.profile && . ~/.profile

# Creating a directory for logs
mkdir logs

# Initialize IPFS
ipfs init

# Initialize IPFS Cluster Service.
ipfs-cluster-service init

# Opening required firewall ports
sudo apt-get -y update && sudo apt-get -y install firewalld
sudo firewall-cmd --zone=public --add-port=4001/tcp --permanent
sudo firewall-cmd --zone=public --add-port=5001/tcp --permanent
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
sudo firewall-cmd --zone=public --add-port=9094/tcp --permanent
sudo firewall-cmd --zone=public --add-port=9096/tcp --permanent

sudo systemctl reload firewalld

# Enabling ssh
ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# Starting IPFS daemon
ipfs daemon  > logs/ipfs_daemon.log 2>&1 &