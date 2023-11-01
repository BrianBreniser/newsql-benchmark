echo "general_workload_quos"
read -rp "press enter to continue"
maim -s fdb_grafana_general_workload_quos_$1.png

echo "data_read"
read -rp "press enter to continue"
maim -s fdb_grafana_data_$1.png

echo "storage_graphs"
read -rp "press enter to continue"
maim -s fdb_grafana_storage_graphs_$1.png

echo "log_graphs"
read -rp "press enter to continue"
maim -s fdb_grafana_log_graphs_$1.png

echo "latency_probe"
read -rp "press enter to continue"
maim -s fdb_grafana_latency_probe_$1.png

echo "recovery_state"
read -rp "press enter to continue"
maim -s fdb_grafana_recovery_state_$1.png

echo "storage processes"
read -rp "press enter to continue"
maim -s fdb_grafana_storage_processes_$1.png

echo "not storage processes"
read -rp "press enter to continue"
maim -s fdb_grafana_not_storage_processes_$1.png
