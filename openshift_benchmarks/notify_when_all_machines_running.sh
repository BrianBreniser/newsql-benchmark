#!/bin/bash

not_running=$(oc get machines -n openshift-machine-api --no-headers | grep -vc Running)

# while not running is greater than 0, sleep
while [ $not_running -gt 0 ]; do
    echo "Machines not running: $not_running"
    sleep 30
    not_running=$(oc get machines -n openshift-machine-api --no-headers | grep -vc Running)
done

while true; do
    notify-send "All machines are now Running"
    sleep 30
done

