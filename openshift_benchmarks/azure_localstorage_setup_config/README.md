# Purpose of this directory

- Holds the openshift config files for testing the local-storage-operator on Azure L-series VMs.
- I had "fun" configuring this, my ARO cluster had a handful of problems with the local-storage-operator, so I kept the config files here for future reference.
    - 

# added_file_to_l_series_vm_storage.png

- Success image, though it's only one image, it at least shows that the local-storage-operator worked

# deployment_to_use_l_series_pvc.yaml

- Needed this to use the PVC created by the local-storage-operator
    - It runs an echo command to keep the container up, otherwise it will exit and the pod will be deleted
    - I wrote data to a test file manually to verify that the PVC was working

# local_storage_operator.yaml

- Has an OperatorGroup and Subscription. I think these were unnecessary if your ARO cluster is provisioned with your pull secret in the first place. I had to set this up manually becuase my operatorhub wasn't connected

# local_volume.yaml

- Once the operator is up and running, this is likely the only config needed.
- When this is applied, the local-storage-operator will create a PV for each disk in the devicePaths

# machineset.yml

- This was required to add the L-series VMs to the cluster. By default, on Azure ARO clusters in demo.openshift, you cannot add L-series VMs to the cluster. You only get D-series VMs.

# pvc-local-l-series.yaml

- Necessary after the local_volume.yaml is applied. This creates a PVC that uses the PV created by the local-storage-operator

# redhat-operators.yaml

- Also unnecessary if your ARO cluster is provisioned with your pull secret in the first place. I had to set this up manually becuase my operatorhub wasn't connected.

# Notes (Some data here is repeated from above)

- Directions
    - Create Azure blank environment in demo.redhat.com
    - Use the `az` cli to create an ARO cluster
    - Set up operators to work (see below)
    - Add the local_storage_operator
    - Add the L-series VMs to the cluster using the machineset.yml
    - Create the PVC using the pvc-local-l-series.yaml
    - Create a deployment using the deployment_to_use_l_series_pvc.yaml
        - Mapped the PVC to the deployment in /data
- The test
    - Write data to /data
    - ???
    - Profit
- Results
    - File was writen
    - PNG has a screenshot of the command line output (I always forget vim isn't installed by default)
- Problems
    - Getting my cluster set up in ARO didn't work properly, as it wasn't seeded with my pull secret. I had to manually add the OperatorGroup and Subscription yaml's to get the local-storage-operator to install.

