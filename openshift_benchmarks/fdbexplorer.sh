oc exec -it $(oc get pods | rg 'fdbexplorer' | head -1 | awk "{print $1}") -- /app/fdbexplorer-linux-amd64
