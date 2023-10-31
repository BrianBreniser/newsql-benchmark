#!/usr/bin/env bash

checkAllStarted="true"
notify-send "Starting log loop"
start_time=$(date +%s)
gatherLatencyMetrics="true"

while true; do
    pods=$(oc get pods | rg -i benchmark | awk '{print $1}')
    allDone="true"
    allStarted="true"
    echo ""
    echo "Starting =========================="
    echo ""

    for pod in $pods; do
        result=$(oc logs "$pod" | tail -n 1)
        echo "$pod: $result"
        if [[ "$result" != *"finished"* ]]; then
            allDone="false"
        fi

        if [[ "$checkAllStarted" == "true" ]]; then
            if [[ "$result" != *"current ops"* ]]; then
                allStarted="false"
            fi
        fi

    done

    # If all pods have started, then wait 2 minutes for pods to warm up
    # Then collect metrics from fdbcli
    if [[ "$allStarted" == "true" && "$checkAllStarted" == "true" ]]; then
        notify-send "All pods started"
        checkAllStarted="false"
        notify-send "Waiting 10 seconds for pods to warm up"
        echo "Waiting 10 seconds for pods to warm up"
        sleep 10
        notify-send "Collecting metrics from fdbcli"
        echo "Collecting metrics from fdbcli"
        #fdb exec -c fdb-cluster-1 -- fdbcli --exec "status details" | rg Redundancy >> results.txt
        #echo "" >> results.txt
        # Had some broken pipe problems without using a tmp file.
        fdb exec -c fdb-cluster-1 -- fdbcli --exec "status details" > tmp.txt
        head -50 tmp.txt >> results.txt
        rm tmp.txt
        echo "" >> results.txt
    fi


    # If all pods are done, then break out of the loop
    if [[ "$allDone" == "true" ]]; then
        echo "All pods finished, now collecting metrics into results.txt"
        notify-send "All pods finished, now collecting metrics into results.txt"
        python3 collect_ycsb_metrics.py >> results.txt
        break
    fi

    # Needs to run last, because of the 'continue' statement that skips the rest of the loop
    # If 30 seconds have passed, then collect latency metrics
    current_time=$(date +%s)
    if (( current_time > start_time + 120 )); then
        if [[ "$gatherLatencyMetrics" == "true" ]]; then
            echo "2 minutes have passed, saving latency probe and grv_latency metrics into results.txt"
            notify-send "2 minutes have passed, saving latency probe and grv_latency metrics into results.txt"

            echo "latency probes after 5 minutes of running" >> results.txt
            echo "" >> results.txt
            fdb exec -c fdb-cluster-1 -- fdbcli --exec "status json" > tmp.txt
            cat tmp.txt | jq '{latency_probe: .cluster.latency_probe}' >> results.txt
            fdb exec -c fdb-cluster-1 -- fdbcli --exec "status json" > tmp.txt
            cat tmp.txt | jq '.cluster.processes[].roles[].grv_latency_statistics' | grep -v '^null$' >> results.txt

            gatherLatencyMetrics="false"
        fi
    fi

    sleep 30
done

echo "Run completely finished"
notify-send "Run completely finished"

