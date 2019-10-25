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

## Java Setup
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "sudo apt-get -y update && \
wget -c --header 'Cookie: oraclelicense=accept-securebackup-cookie' http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz && \
tar -xvf jdk-8u131-linux-x64.tar.gz && \
echo 'export JAVA_HOME=~/jdk1.8.0_131' >> .profile && \
echo 'export PATH=\$PATH:\$JAVA_HOME/bin' >> .profile"

# Apache Web Server Setup.
echo "Setting up Apache Web Server on $HOST"
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "wget https://www-eu.apache.org/dist/tomcat/tomcat-9/v9.0.27/bin/apache-tomcat-9.0.27.zip && unzip apache-tomcat-9.0.27.zip && mv apache-tomcat-9.0.27 tomcat && chmod 777 tomcat/bin/*"

# Transfering the server config file.
scp -i $PRIVATE_KEY ../config/server.xml $USER_NAME@$HOST:tomcat/conf

# Transfering all web files.
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "mkdir tomcat/webapps/UI && mkdir tomcat/webapps/UI/scripts"
scp -i $PRIVATE_KEY ../WebApp/index.html $USER_NAME@$HOST:tomcat/webapps/UI
scp -i $PRIVATE_KEY ../WebApp/scripts/* $USER_NAME@$HOST:tomcat/webapps/UI/scripts

# Enabling the webapp port
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "sudo firewall-cmd --zone=public --add-port=8000/tcp --permanent"

ssh -i $PRIVATE_KEY $USER_NAME@$HOST "echo 'JAVA_OPTS=\"\$JAVA_OPTS -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses=true \"' >> tomcat/bin/setenv.sh"

# Starting up the server.
ssh -i $PRIVATE_KEY $USER_NAME@$HOST ". .profile && bash tomcat/bin/startup.sh"

# To ensure that firewalld is loaded
ssh -i $PRIVATE_KEY $USER_NAME@$HOST "sudo systemctl start firewalld"
echo "Completed webapp setup."