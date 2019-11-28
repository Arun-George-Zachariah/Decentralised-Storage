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

# Set up the Ethereum peers.
for node in $(cat $HOSTS)
do
    # Setting up Ethereum on a node.
    echo "Setting up ethereum on $node"
    bash ethereum_setup.sh --user $USER_NAME --key $PRIVATE_KEY --host $node
done
echo "Completed Ethereum peer setup"

# Waiting for all process to startup.
sleep 60

# Considering the first node as a bootstrap node.
master_node=$(head -1 "$HOSTS")

# Adding additional peers to the network.
for peer in $(tail -n +2 $HOSTS); do
    # Fetch the peer key
    echo "peer :: $peer"
    peerKey=$(ssh -i $PRIVATE_KEY $USER_NAME@$peer "geth --exec 'admin.nodeInfo.enode' attach http://127.0.0.1:8545")
    echo "peeerkey  is $peerKey"
    ssh -i $PRIVATE_KEY $USER_NAME@$master_node "geth --exec 'admin.addPeer($peerKey)' attach http://127.0.0.1:8545"
done
