#!/bin/env bash


# Get ycsb setup

ycsbsetup=$(cat 'ycsb_statefulset.yaml' | rg 'update_proportion|read_proportion|num_keys|value_size_bytes|batch_size|num_clients|threads_per_process|process_per_host|max_execution_time_seconds')

echo "YCSB Setup:" >> results.txt
echo "$ycsbsetup" >> results.txt
echo "" >> results.txt

# Get the FDB setup
proccesscounts=$(oc get fdb fdb-cluster-1 -o yaml | yq e '.spec.processCounts')
databaseconfig=$(oc get fdb fdb-cluster-1 -o yaml | yq e '.spec.databaseConfiguration')

echo "Database Config:" >> results.txt
echo "$proccesscounts" >> results.txt
echo "" >> results.txt

echo "Process Counts:" >> results.txt
echo "$databaseconfig" >> results.txt
echo "" >> results.txt

