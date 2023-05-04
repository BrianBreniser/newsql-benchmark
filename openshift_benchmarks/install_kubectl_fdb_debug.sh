#!/usr/bin/env bash

#check if kubectl fdb is installed
if ! kubectl plugin list | grep -q fdb; then
    echo "kubectl fdb is not installed, installing it now"
    curl -sLO "https://github.com/FoundationDB/fdb-kubernetes-operator/releases/download/v1.16.0/kubectl-fdb_v1.16.0_Linux_x86_64" 
    echo "downloaded kubectl-fdb_v1.16.0_Linux_x86_64"
    chmod +x kubectl-fdb_v1.16.0_Linux_x86_64
    mv kubectl-fdb_v1.16.0_Linux_x86_64 /usr/local/bin/kubectl-fdb 
    if ! kubectl plugin list | grep -q fdb; then
        echo "kubectl fdb is still not installed, exiting"
        exit 1
    else
        echo "kubectl fdb is installed"
    fi
    exit 1
else
    echo "kubectl fdb is installed"
fi
