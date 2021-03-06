#!/bin/bash

IDENTITY_HOST="${IDENTITY_HOST:-localhost}"
CONTROLLER_HOST="${CONTROLLER_HOST:-localhost}"

sed -i.bak s/CONTROLLER_HOST/$CONTROLLER_HOST/g /root/ciaorc
sed -i.bak s/IDENTITY_HOST/$IDENTITY_HOST/g /root/ciaorc

# compile the code before running it
go install github.com/01org/ciao/...
cp -f $GOBIN/* /usr/bin

mkdir -p /root/ciao-data
cd /root/ciao-data
cp -r /root/go/src/github.com/01org/ciao/ciao-controller/tables .
cp -r /root/go/src/github.com/01org/ciao/ciao-controller/workloads .

if [ ! -d "/etc/ssl" ] ; then
    hash=`c_hash /etc/ca-certs/cacert.pem | cut -d ' ' -f1`
    ln -s /etc/ca-certs/cacert.pem /etc/ca-certs/$hash
    mkdir -p /etc/ssl
    ln -s /etc/ca-certs/ /etc/ssl/certs
    ln -s /etc/ca-certs/cacert.pem /usr/share/ca-certs/$hash
    cat  /etc/pki/ciao/controller_cert.pem  >> /etc/ca-certs/cacert.pem
    cat  /etc/pki/ciao/ciao-image_cert.pem  >> /etc/ca-certs/cacert.pem
fi

# Starting the controller
$GOBIN/ciao-controller -logtostderr -v=3
