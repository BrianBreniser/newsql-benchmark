#!/bin/env bash

# Get the exporter pod
exporterpod=$(oc get pods | grep "fdbexplorer" | awk '{print $1}')

# Get ycsb setup
ycsbsetup=$(cat 'ycsb_statefulset.yaml' | rg 'update_proportion|read_proportion|insert_proportion|num_keys|value_size_bytes|batch_size|num_clients|threads_per_process|process_per_host|max_execution_time_seconds|seq|phase')

# Get the YCSB setup
echo "YCSB Setup:" >> results.txt
echo "$ycsbsetup" >> results.txt
echo "" >> results.txt

# Get the FDB setup
echo "FDB Config:" >> results.txt
oc exec "$exporterpod" -- fdbcli --exec "status details" | head -29 >> results.txt
echo "" >> results.txt

