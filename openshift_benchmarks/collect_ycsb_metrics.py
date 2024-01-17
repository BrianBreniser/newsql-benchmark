"""
Docstring for the py formatter to be happy with
"""

import subprocess
import os
import re

metrics = [
    {
        "grep": "[OVERALL], Throughput",
        "op": "sum",
        "metric": "Throughput (ops/sec)",
        "value": 0,
    },
    {
        "grep": "[OVERALL], RunTime(ms)",
        "op": "sum",
        "metric": "Runtime (ms)",
        "value": 0,
    },
    {
        "grep": "[INSERT], Operations",
        "op": "sum",
        "metric": "OperationCountInsert",
        "value": 0,
    },
    {
        "grep": "[INSERT], Return=ERROR",
        "op": "sum",
        "metric": "ErrorCountInsert",
        "value": 0,
    },
    {
        "grep": "[INSERT], Return=OK",
        "op": "sum",
        "metric": "SuccessCountInsert",
        "value": 0,
    },
    {
        "grep": "[INSERT], Return=BATCHED_OK",
        "op": "sum",
        "metric": "SuccessCountInsertBatched",
        "value": 0,
    },
    {
        "grep": "[INSERT], Return=UNEXPECTED_STATE",
        "op": "sum",
        "metric": "UnknownCountInsert",
        "value": 0,
    },
    {
        "grep": "[INSERT], AverageLatency",
        "op": "max",
        "metric": "AverageInsertLatency",
        "value": 0,
    },
    {
        "grep": "[READ], Operations",
        "op": "sum",
        "metric": "OperationCountRead",
        "value": 0,
    },
    {
        "grep": "[READ], Return=ERROR",
        "op": "sum",
        "metric": "ErrorCountRead",
        "value": 0,
    },
    {
        "grep": "[READ], Return=OK",
        "op": "sum",
        "metric": "SuccessCountRead",
        "value": 0,
    },
    {
        "grep": "[READ], Return=BATCHED_OK",
        "op": "sum",
        "metric": "SuccessCountReadBatched",
        "value": 0,
    },
    {
        "grep": "[READ], Return=UNEXPECTED_STATE",
        "op": "sum",
        "metric": "UnknownCountRead",
        "value": 0,
    },
    {
        "grep": "[READ], AverageLatency",
        "op": "max",
        "metric": "AverageReadLatency",
        "value": 0,
    },
    {
        "grep": "[READ], 95thPercentileLatency",
        "op": "max",
        "metric": "95thPercentileReadLatency",
        "value": 0,
    },
    {
        "grep": "[READ], 99thPercentileLatency",
        "op": "max",
        "metric": "99thPercentileReadLatency",
        "value": 0,
    },
    {
        "grep": "[READ-MODIFY-WRITE], Operations",
        "op": "sum",
        "metric": "OperationCountReadModifyWrite",
        "value": 0,
    },
    {
        "grep": "[READ-MODIFY-WRITE], Return=ERROR",
        "op": "sum",
        "metric": "ErrorCountReadModifyWrite",
        "value": 0,
    },
    {
        "grep": "[READ-MODIFY-WRITE], Return=OK",
        "op": "sum",
        "metric": "SuccessCountReadModifyWrite",
        "value": 0,
    },
    {
        "grep": "[READ-MODIFY-WRITE], Return=BATCHED_OK",
        "op": "sum",
        "metric": "SuccessCountReadModifyWriteBatched",
        "value": 0,
    },
    {
        "grep": "[READ-MODIFY-WRITE], Return=UNEXPECTED_STATE",
        "op": "sum",
        "metric": "UnknownCountReadModifyWrite",
        "value": 0,
    },
    {
        "grep": "[READ-MODIFY-WRITE], AverageLatency",
        "op": "max",
        "metric": "AverageReadModifyWriteLatency",
        "value": 0,
    },
    {
        "grep": "[READ-MODIFY-WRITE], 95thPercentileLatency",
        "op": "max",
        "metric": "95thPercentileReadModifyWriteLatency",
        "value": 0,
    },
    {
        "grep": "[READ-MODIFY-WRITE], 99thPercentileLatency",
        "op": "max",
        "metric": "99thPercentileReadModifyWriteLatency",
        "value": 0,
    },
    {
        "grep": "[UPDATE], Operations",
        "op": "sum",
        "metric": "OperationCountUpdate",
        "value": 0,
    },
    {
        "grep": "[UPDATE], Return=ERROR",
        "op": "sum",
        "metric": "ErrorCountUpdate",
        "value": 0,
    },
    {
        "grep": "[UPDATE], Return=OK",
        "op": "sum",
        "metric": "SuccessCountUpdate",
        "value": 0,
    },
    {
        "grep": "[UPDATE], Return=BATCHED_OK",
        "op": "sum",
        "metric": "SuccessCountUpdateBatched",
        "value": 0,
    },
    {
        "grep": "[UPDATE], Return=UNEXPECTED_STATE",
        "op": "sum",
        "metric": "UnknownCountUpdate",
        "value": 0,
    },
    {
        "grep": "[UPDATE], AverageLatency",
        "op": "max",
        "metric": "AverageUpdateLatency",
        "value": 0,
    },
    {
        "grep": "[UPDATE], 95thPercentileLatency",
        "op": "max",
        "metric": "95thPercentileUpdateLatency",
        "value": 0,
    },
    {
        "grep": "[UPDATE], 99thPercentileLatency",
        "op": "max",
        "metric": "99thPercentileUpdateLatency",
        "value": 0,
    },
]


def parse_log(log):
    # loop though each line in the log
    for line in log.splitlines():
        # if we find the line with the grep, parse it and update the metric
        for metric in metrics:
            if metric["grep"] in line:
                # remove the grepped result from the line becuase 9[5|9]thPercentileLatency is getting the grep result
                line = line.replace(metric["grep"], "")

                match = re.search(r"\d+", line)
                if match:
                    value = int(match.group(0))
                    if metric["op"] == "sum":
                        metric["value"] += value
                    elif metric["op"] == "max":
                        if value > metric["value"]:
                            metric["value"] = value
                    else:
                        print("Unknown operation: " + metric["op"])
                        exit(1)


def get_statefulset_pods(name):
    selector = "app=" + name
    pods = (
        subprocess.check_output(
            ["oc", "get", "pods", "--selector", selector, "-o", "name"]
        )
        .decode("utf-8")
        .strip()
    )
    return pods.split()


def get_pod_logs(namespace, name):
    logs = subprocess.check_output(["oc", "logs", "-n", namespace, name]).decode(
        "utf-8"
    )
    return logs


def aggregate_statefulset_logs(namespace, name):
    pods = get_statefulset_pods(name)
    log_file = "statefulset-logs.txt"

    if os.path.exists(log_file):
        os.remove(log_file)

    with open(log_file, "w") as f:
        for pod in pods:
            log = get_pod_logs(namespace, pod)
            parse_log(log)
            f.write(log)


if __name__ == "__main__":
    NS = "dc1"
    N = "ycsb"

    aggregate_statefulset_logs(NS, N)

    for m in metrics:
        print(m["metric"] + ": " + str(m["value"]))
