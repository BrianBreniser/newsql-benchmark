#!/usr/bin/env bash

while true; do
    pods=$(oc get pods | rg -i benchmark | awk '{print $1}')
    for pod in $pods; do
        oc logs "$pod"
    done
    sleep 10
    pods=$(oc get pods | rg -i benchmark | awk '{print $1}')
done

