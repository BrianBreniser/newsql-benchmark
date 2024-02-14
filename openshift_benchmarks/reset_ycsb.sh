#!/usr/bin/env bash

# cleanup our cluster
oc delete statefulset ycsb-benchmark

echo "Waiting for pods to terminate"

# apply our templating
./apply_templating.py "$1"
echo "Templating $1 applied"

echo "Gathering ycsb and fdb output"
./get_ycsb_fdb_setup.sh # gets ycsb and fdb output and puts it in results.txt automatically

# Wait for the old pods to be deleted
echo "Waiting for pods to terminate"
non_running_pods=$(oc get pods | grep -i terminating | wc -l)

while [ "$non_running_pods" -gt 0 ]
do
    sleep 5
    non_running_pods=$(oc get pods | grep -i terminating | wc -l)
done

./notify-send.sh "All pods terminated"

sleep 10

# Finally, run our ycsb benchmark
oc apply -f ycsb_statefulset.yaml

# I always run this after anyways
./notify-send.sh "ycsb benchmark started"

sleep 10

./loop_get_logs_lastline.sh

