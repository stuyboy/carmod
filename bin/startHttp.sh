#!/bin/bash

cd ../server/bin

export OPENSHIFT_GO_IP=171.31.17.151
export OPENSHIFT_GO_PORT=80

nohup ./http &
