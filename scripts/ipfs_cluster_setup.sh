#!/usr/bin/env bash

# Setting defaults.
USER_NAME=$USER
PRIVATE_KEY=~/.ssh/id_rsa
HOSTS=HostList.txt

# Usage.
usage()
{
    echo "usage: ipfs_cluster_setup.sh [--user User] [--key Private_Key] [--hosts Host_List] [-h | --help] "
}

# Read input parameters.
if [ "$1" == "" ]; then usage; exit 1; fi
while [ "$1" != "" ]; do
    case $1 in
    	--user)
        	shift
        	USER_NAME=$1
        	;;
        --key)
        	shift
        	PRIVATE_KEY=$1
        	;;
        --hosts)
        	shift
        	HOSTS=$1
        	;;
        -h | --help )
        	usage
        	exit
        	;;
        * )
        	usage
            exit
    esac
    shift
done

# Creating the cluster secret key
CLUSTER_SECRET=$(od  -vN 32 -An -tx1 /dev/urandom | tr -d ' \n')
# Set up IPFS on all nodes.
for node in $(cat $HOSTS)
do
    # Copying node setup script to the node.
    scp -i $PRIVATE_KEY node_setup.sh $USER_NAME@$node:

    # Setting up the node.
    echo "Setting up $node"
    ssh -i $PRIVATE_KEY $USER_NAME@$node "bash node_setup.sh $CLUSTER_SECRET"
done

# Starting IPFS Cluster Service daemon on the master node/ first peer.
master_node=$(head -1 "$HOSTS")
echo "Starting IPFS Cluster Service Daemon on $master_node"
ssh -i $PRIVATE_KEY $USER_NAME@$master_node ". ~/.profile && ipfs-cluster-service daemon > ~/logs/ipfs_cluster_service_daemon.log 2>&1" &

# Getting the master data.
master_ip=$(ssh -i $PRIVATE_KEY $USER_NAME@$master_node "ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep -v '10.10.1.*'")
master_id=$(ssh -i $PRIVATE_KEY $USER_NAME@$master_node ". ~/.profile && ipfs-cluster-ctl id | head -n 1 | cut -d'|' -f1 | xargs")

# Adding additional peers to the network.
for peer in $(tail -n +2 $HOSTS); do
    echo "Starting IPFS Cluster Service Daemon on $peer"
    ssh -i $PRIVATE_KEY $USER_NAME@$peer ". ~/.profile && ipfs-cluster-service daemon --bootstrap /ip4/$master_ip/tcp/9096/ipfs/$master_id > ~/logs/ipfs_cluster_service_daemon.log 2>&1 " &
done

# Preparing the FUSE mountpoint.
# Node JS Installation.
ssh -i $PRIVATE_KEY $USER_NAME@$master_node "curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash - && sudo apt-get install -y nodejs && sudo apt install npm"

# Setting up IPFS-FUSE
ssh -i $PRIVATE_KEY $USER_NAME@$master_node "sudo apt-get install -y libfuse-dev && sudo npm install -g ipfs-fuse --unsafe-perm"
ssh -i $PRIVATE_KEY $USER_NAME@$master_node "ipfs-fuse" & # Mounted on /users/<USER>/IPFS