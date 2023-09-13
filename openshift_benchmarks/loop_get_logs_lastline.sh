#!/usr/bin/env bash

checkAllStarted="true"
notify-send "Starting log loop"

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

    if [[ "$allStarted" == "true" && "$checkAllStarted" == "true" ]]; then
        notify-send "All pods started"
        checkAllStarted="false"
        notify-send "Waiting 2 minutes for pods to warm up"
        echo "Waiting 2 minutes for pods to warm up"
        sleep 120
        notify-send "Collecting metrics from fdbcli"
        echo "Collecting metrics from fdbcli"
        fdb exec -c fdb-cluster-2 -- fdbcli --exec "status details" | rg Redundancy >> results.txt
        echo "" >> results.txt
        # Had some broken pipe problems without using a tmp file.
        fdb exec -c fdb-cluster-2 -- fdbcli --exec "status details" > tmp.txt
        grep cpu tmp.txt | head >> results.txt
        rm tmp.txt
        echo "" >> results.txt
    fi

    if [[ "$allDone" == "true" ]]; then
        echo "All pods finished, now collecting metrics into results.txt"
        notify-send "All pods finished, now collecting metrics into results.txt"
        python3 collect_ycsb_metrics.py >> results.txt
        break
    fi

    sleep 30
done

echo "Completely finished"
notify-send "Completely finished"

