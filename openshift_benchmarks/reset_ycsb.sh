#!/usr/bin/env bash

# cleanup our cluster
oc delete fdb/fdb-cluster
oc delete statefulset ycsb-benchmark

# apply our templating
./apply_templating.py testing

# wait for the cluster to come down completely
pods=$(oc get pods | wc -l)

while [ "$pods" -gt 2 ]
do
    sleep 5
    pods=$(oc get pods | wc -l)
done

# Set up our new cluster
oc apply -f fdb.yaml

# Wati for thew new cluster to come up completely
non_running_pods=$(oc get pods | grep -v Running | wc -l)

while [ "$non_running_pods" -gt 1 ] # the header counts as the only line, -gt 1 means no pods are in a non-running state
do
    sleep 5
    non_running_pods=$(oc get pods | grep -v Running | wc -l)
done

sleep 10 # Possibly something still needs to load even after the pods are up

# Finnally, run our ycsb benchmark
oc apply -f ycsb_statefulset.yaml

