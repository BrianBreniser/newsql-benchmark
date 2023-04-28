#!/usr/bin/env bash

oc delete deployment ycsb-deployment
./apply_templating.py
./setup_script.sh

