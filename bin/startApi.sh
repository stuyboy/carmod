#!/bin/bash

cd ../server/bin
pkill api
nohup ./api &
