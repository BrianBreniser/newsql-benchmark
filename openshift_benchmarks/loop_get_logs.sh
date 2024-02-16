#!/usr/bin/env bash

while true; do
    pods=$(oc get pods | grep -i benchmark | awk '{print $1}')
    for pod in $pods; do
        oc logs "$pod"
    done
    sleep 10
done

