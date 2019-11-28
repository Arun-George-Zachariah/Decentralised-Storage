#!/usr/bin/env bash

# Usage.
usage()
{
    echo "usage: ethereum_setup.sh [--user User] [--key Private_Key] [--host Host]"
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
        --host)
        	shift
        	HOST=$1
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

# Ethereum Installation.
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "sudo apt-get update && \
          sudo apt-get install -y software-properties-common && \
          sudo add-apt-repository -y ppa:ethereum/ethereum && \
          sudo apt-get update && \
          sudo apt-get install -y ethereum"

# NodeJS Installation.
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "sudo apt-get install -y curl && \
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash - && \
sudo apt-get install -y nodejs"

# Project Setup.
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "mkdir Private-Share && mkdir Private-Share/BlockChain"

# Copyting the Genesis Block Configuration.
scp -i $PRIVATE_KEY ../config/genesis.json $USER_NAME@$HOST:Private-Share

# Initializing the Blockchain.
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "cd Private-Share && geth --datadir BlockChain init genesis.json"

# Starting the Blockchain.
#ssh -i $PRIVATE_KEY $USER_NAME@$HOST 'cd Private-Share && nohup geth --port 3000 --networkid 58343 --nodiscover --datadir=./BlockChain --maxpeers=0  --rpc --rpcport 8543 --rpcaddr 0.0.0.0 --rpccorsdomain "*" --rpcapi "eth,net,web3,admin,personal,miner" --allow-insecure-unlock' &
ssh -i $PRIVATE_KEY $USER_NAME@$HOST 'cd Private-Share && nohup geth --datadir "BlockChain" --networkid 123456 --rpc --rpcport "8545" --rpcaddr 0.0.0.0 --rpccorsdomain "*" --rpcapi="admin,db,eth,net,web3,personal,miner" --allow-insecure-unlock' &>/dev/null &
