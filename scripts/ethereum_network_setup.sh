#!/usr/bin/env bash

# Setting defaults.
USER_NAME=$USER
PRIVATE_KEY=~/.ssh/id_rsa
HOSTS=HostList.txt

# Usage.
usage()
{
    echo "usage: ethereum_network_setup.sh [--user User] [--key Private_Key] [--hosts Host_List] [-h | --help] "
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


# Set up the Ethereum peers.
for node in $(cat $HOSTS)
do
    # Copying node setup script to the node.
    bash ethereum_setup.sh --user $USER_NAME --key $PRIVATE_KEY --host $node
done
echo "Completed Ethereum peer setup"

# Considering the first node as a bootstrap node.
master_node=$(head -1 "$HOSTS")

# Adding additional peers to the network.
for peer in $(tail -n +2 $HOSTS); do
    # Fetch the peer key
    peerKey=$(ssh -i $PRIVATE_KEY $USER_NAME@$peer "geth --exec 'admin.nodeInfo.enode' attach http://127.0.0.1:8545")
    ssh -i $PRIVATE_KEY $USER_NAME@$peer "geth --exec 'admin.addPeer($peerKey)' attach http://127.0.0.1:8545"
done
