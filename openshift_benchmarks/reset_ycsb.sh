#!/usr/bin/env bash

oc delete statefulset ycsb-benchmark
./apply_templating.py 3_read
oc apply -f ycsb_statefulset.yaml

