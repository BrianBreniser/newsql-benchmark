#!/usr/bin/env bash

# cleanup our cluster
oc delete statefulset ycsb-benchmark

notify-send "Waiting for pods to terminate"

# apply our templating
./apply_templating.py "$1"

notify-send "Templating $1 applied"

notify-send "Gathering ycsb and fdb output"
echo "Gathering ycsb and fdb output"
./get_ycsb_fdb_setup.sh # gets ycsb and fdb output and puts it in results.txt automatically

# Wait for the old pods to be deleted
echo "Waiting for pods to terminate"
non_running_pods=$(oc get pods | rg -i terminating | wc -l)

while [ "$non_running_pods" -gt 0 ]
do
    sleep 5
    non_running_pods=$(oc get pods | rg -i terminating | wc -l)
done

notify-send "All pods terminated"

sleep 10

# Finally, run our ycsb benchmark
oc apply -f ycsb_statefulset.yaml

# I always run this after anyways
notify-send "ycsb benchmark started"

sleep 10

./loop_get_logs_lastline.sh

