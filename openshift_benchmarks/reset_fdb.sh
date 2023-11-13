#!/usr/bin/env bash

# cleanup our cluster
oc delete statefulset ycsb-benchmark
oc delete fdb/fdb-cluster-eastus2-1
oc delete fdb/fdb-cluster-eastus2-2
oc delete fdb/fdb-cluster-eastus2-3

# wait for the cluster to come down completely
pods=$(oc get pods | grep -c "fdb-cluster")

while [ "$pods" -gt 0 ] # No header line becuase of the grep fdb-cluster
do
    sleep 5
    pods=$(oc get pods | grep -c "fdb-cluster")
done

# Set up our new cluster
oc apply -f fdbbackup1.yaml
oc apply -f fdbbackup2.yaml
oc apply -f fdbbackup3.yaml

# Wait for thew new cluster to come up completely
non_running_pods=$(oc get pods | grep "fdb-cluster" | grep -vc Running)

while [ "$non_running_pods" -gt 0 ] # No header line becuase of the grep fdb-cluster
do
    sleep 5
    non_running_pods=$(oc get pods | grep "fdb-cluster" | grep -vc Running)
done

sleep 120 # it's possible something still needs to load even after the pods are up

for i in $(oc get pods | rg "explorer|exporter" | awk '{print $1}'); do
    oc delete pod $i;
done

sleep 120; # just wait for the pods to come back up statically

while true
do
    sleep 60
    notify-send "Reminder: FDB is now up and running"
done

