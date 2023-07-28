#!/usr/bin/env bash

pods=$(oc get pods | rg -i benchmark | awk '{print $1}')

while true; do
    for pod in $pods; do
        oc logs "$pod"
    done
    sleep 10
done

