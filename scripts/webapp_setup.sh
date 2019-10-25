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
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "sudo apt-get install -y python3-pip && pip3 install Flask"

# Transfering all web files.
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "mkdir WebApp && mkdir WebApp/templates"
scp -i $PRIVATE_KEY ../WebApp/upload.py $USER_NAME@$HOST:WebApp
scp -i $PRIVATE_KEY ../WebApp/templates/* $USER_NAME@$HOST:WebApp/templates

# Enabling the webapp port
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "sudo firewall-cmd --zone=public --add-port=5000/tcp --permanent"
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "sudo systemctl reload firewalld"

# Starting up the server.
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "nohup python3 WebApp/upload.py" &

# To ensure that firewalld is loaded
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "sudo systemctl start firewalld"
echo "Completed webapp setup."