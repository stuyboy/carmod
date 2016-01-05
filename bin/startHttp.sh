#!/bin/bash

cd ../server/bin

#AWS EC2 Instance
export OPENSHIFT_GO_IP=172.31.17.151
export OPENSHIFT_GO_PORT=8888

pkill http
nohup ./http &
