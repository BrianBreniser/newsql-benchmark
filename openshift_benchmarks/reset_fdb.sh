#!/usr/bin/env bash

# cleanup our cluster
oc delete statefulset ycsb-benchmark
oc delete fdb/fdb-cluster

# apply our templating
./apply_templating.py "$1"

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
non_running_pods=$(oc get pods | grep -c Running)

while [ "$non_running_pods" -gt 1 ] # the header counts as the only line, -gt 1 means no pods are in a non-running state
do
    sleep 5
    non_running_pods=$(oc get pods | grep -c Running)
done

sleep 120 # Possibly something still needs to load even after the pods are up

# Every 2 minutes send out a notifcation
while true
do
    sleep 120
    notify-send "Reminder: FDB is now up and running"
done

