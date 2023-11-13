#!/bin/bash

echo "deleting machines"
# Delete MachineSets
for i in $(oc get machinesets -n openshift-machine-api | rg stateless | awk '{print $1}'); do
    oc delete machineset -n openshift-machine-api "$i"
done

# Check if machines are in the process of being deleted
sleep 5 # Ensure that any machine deletion has started
deleting=$(oc get machines -n openshift-machine-api | grep "stateless" | grep -c "Deleting")

# Wait for the machines to be deleted, but only if there were machines deleting
echo "waiting for machines to be deleted"
if [ "$deleting" -gt 0 ]; then
    while [ "$deleting" -gt 0 ]; do
        sleep 5
        deleting=$(oc get machines -n openshift-machine-api | grep "stateless" | grep -c "Deleting")
    done
else
    echo "No stateless machines were found in the process of being deleted."
fi

echo "Remdinding you every 30 seconds that stateless machines have been deleted"
while true; do
    sleep 30
    notify-send "Reminder: Stateless machines have been deleted"
done



