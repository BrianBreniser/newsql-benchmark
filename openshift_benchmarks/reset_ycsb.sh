#!/usr/bin/env bash

# cleanup our cluster
oc delete statefulset ycsb-benchmark

# apply our templating
./apply_templating.py "$1"

# Wati for the old pods to be deleted
non_running_pods=$(oc get pods | rg -i terminating | wc -l)

while [ "$non_running_pods" -gt 0 ]
do
    sleep 5
    non_running_pods=$(oc get pods | rg -i terminating | wc -l)
done

# Finally, run our ycsb benchmark
oc apply -f ycsb_statefulset.yaml

