#!/usr/bin/env bash

checkAllStarted="true"
./notify-send.sh "Starting log loop"
start_time=$(date +%s)
gatherLatencyMetrics_2="true"
gatherLatencyMetrics_10="true"
exporterpod=$(oc get pods | grep "fdbexplorer" | awk '{print $1}') # I know it's not explorer, but it's the corret pod on 01

while true; do
    pods=$(oc get pods | grep -i benchmark | awk '{print $1}')
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
        ./notify-send.sh "All pods started"
        checkAllStarted="false"
        echo "Waiting 10 seconds for pods to warm up"
        sleep 10
        echo "Collecting metrics from fdbcli"

        # Let's get fdbcli status details one last time
        echo "Probes after all pods have started and 10 seconds have passed" >> results.txt
        echo "" >> results.txt

        oc exec "$exporterpod" -- fdbcli --exec "status details" | grep Redundancy >> results.txt
        echo "" >> results.txt
        # Had some broken pipe problems without using a tmp file.
        oc exec "$exporterpod" -- fdbcli --exec "status details" > tmp.txt
        head -60 tmp.txt >> results.txt
        rm tmp.txt
        echo "" >> results.txt
    fi


    # If all pods are done, then break out of the loop
    if [[ "$allDone" == "true" ]]; then
        echo "All pods finished, now collecting metrics into results.txt"

        # Let's get fdbcli status details one last time
        echo "Probes after all pods are finished" >> results.txt
        echo "" >> results.txt

        oc exec "$exporterpod" -- fdbcli --exec "status details" > tmp.txt # This gets around some broken pipe issues
        cat tmp.txt >> results.txt

        echo "" >> results.txt

        ./notify-send.sh "All pods finished, now collecting metrics into results.txt"
        python3 collect_ycsb_metrics.py >> results.txt
        break
    fi

    # If time limit has passed, then collect latency metrics
    current_time=$(date +%s)
    if (( current_time > start_time + 120 )); then
        if [[ "$gatherLatencyMetrics_2" == "true" ]]; then
            echo "2 minutes have passed, saving latency probe and grv_latency metrics into results.txt"

            echo "Probes after 2 minutes of running" >> results.txt
            echo "" >> results.txt

            oc exec "$exporterpod" -- fdbcli --exec "status details" > tmp.txt # This gets around some broken pipe issues
            cat tmp.txt >> results.txt

            oc exec "$exporterpod" -- fdbcli --exec "status json" > tmp.txt # This get's around some broken pipe issues
            cat tmp.txt | jq '{latency_probe: .cluster.latency_probe}' >> results.txt

            oc exec "$exporterpod" -- fdbcli --exec "status json" > tmp.txt # This get's around some broken pipe issues
            cat tmp.txt | jq '.cluster.processes[].roles[].grv_latency_statistics' | grep -v '^null$' >> results.txt

            echo "" >> results.txt

            gatherLatencyMetrics_2="false"
        fi
    fi

    if (( current_time > start_time + 600 )); then
        if [[ "$gatherLatencyMetrics_10" == "true" ]]; then
            echo "10 minutes have passed, saving latency probe and grv_latency metrics into results.txt"

            echo "Probes after 10 minutes of running" >> results.txt
            echo "" >> results.txt

            oc exec "$exporterpod" -- fdbcli --exec "status details" > tmp.txt # This gets around some broken pipe issues
            cat tmp.txt >> results.txt

            oc exec "$exporterpod" -- fdbcli --exec "status json" > tmp.txt # This get's around some broken pipe issues
            cat tmp.txt | jq '{latency_probe: .cluster.latency_probe}' >> results.txt

            oc exec "$exporterpod" -- fdbcli --exec "status json" > tmp.txt # This get's around some broken pipe issues
            cat tmp.txt | jq '.cluster.processes[].roles[].grv_latency_statistics' | grep -v '^null$' >> results.txt

            echo "" >> results.txt

            gatherLatencyMetrics_10="false"
        fi
    fi

    sleep 30
done

echo "Run completely finished"
./notify-send.sh "Run completely finished"

