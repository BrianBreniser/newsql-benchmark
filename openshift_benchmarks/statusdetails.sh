oc exec $(oc get pods | rg 'fdbexplorer|fdbexporter' | head -1 | awk "{print $1}") -- fdbcli --exec "status details"
