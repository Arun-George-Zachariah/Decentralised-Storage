#!/usr/bin/env bash

# Usage.
usage()
{
    echo "usage: webapp_setup.sh [--user User] [--key Private_Key] [--host Host]"
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

# Flask setup
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "sudo apt-get update && sudo apt-get install -y python3-pip && pip3 install Flask"

# Transfering all web files.
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "mkdir WebApp && mkdir WebApp/templates && mkdir WebApp/static && mkdir WebApp/static/css"
scp -r -i $PRIVATE_KEY ../WebApp/* $USER_NAME@$HOST:WebApp/

# Transfering all node files.
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "mkdir NodeFiles"
scp -i $PRIVATE_KEY ../NodeFiles/* $USER_NAME@$HOST:NodeFiles

# Installing node modules.
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "cd NodeFiles && npm install eth-crypto && npm install eth-ecies"

# Enabling the webapp port
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "sudo firewall-cmd --zone=public --add-port=5000/tcp --permanent"
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "sudo systemctl reload firewalld"

# Starting up the server.
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "cd WebApp && nohup python3 server.py" &

# To ensure that firewalld is loaded
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "sudo systemctl start firewalld"
echo "Completed webapp setup."