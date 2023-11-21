#!/bin/bash

machines=$(oc get machines -n openshift-machine-api | grep -c stateless)
running=$(oc get machines -n openshift-machine-api | grep stateless | grep -c Running)


while [ "$machines" -ne "$running" ]; do
    running=$(oc get machines -n openshift-machine-api | grep stateless | grep -c Running)
    echo "machines: $machines, running: $running"
    sleep 10
done

while true; do
    notify-send "Stateless machines are up"
    sleep 30
done

