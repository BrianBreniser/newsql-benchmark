#!/bin/env bash

# build ycsb image
podman build -t quay.io/breniserbrian/ycsb .

# push to docker hub
podman push quay.io/breniserbrian/ycsb
