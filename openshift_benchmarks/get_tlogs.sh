#!/bin/bash

# Setup log file
tmp_logfile="tmp_tlogs.txt"
rm -f "$tmp_logfile"
touch "$tmp_logfile"

# Get tlogs from all pods in all namespaces
namespace_list="dc1 dc2 dc3"

for namespace in $namespace_list; do
    for pod in $(oc get pods -n "$namespace" | grep storage | awk '{print $1}'); do
        echo "STARTED: Getting tlogs from pod $pod in namespace $namespace"
        printf "\nANCHOR: pod %s in namespace %s\n\n" "$pod" "$namespace" >> "$tmp_logfile"
        exactlogfile=$(oc exec -c foundationdb -n "$namespace" "$pod" -- sh -c "ls /var/log/fdb-trace-logs/fdbmonitor*")
        oc rsh -c foundationdb -n "$namespace" "$pod" cat "$exactlogfile" >> "$tmp_logfile"
    done
done

datetime=$(date +%Y%m%d-%H%M%S)
mv "$tmp_logfile" "tlogs_history/tlogs-$datetime.txt"

