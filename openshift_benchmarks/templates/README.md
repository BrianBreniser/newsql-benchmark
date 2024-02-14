# Values.json

Let's dive into values and what each section means

- for each key name, I use a system, let's break it down
    - `final`, naming things is hard, after many iterations, final is what I call this one
    - `_md_` is medium, 300 million operations, `_sm_` is usually 10 or 20 million, and `_lg_` is 1 billion
    - `_l_, _w_, _r_, _u_, _r90rmu10_`
        - `l` is for load, `w` is for write, `r` is for read, `u` is for update, and `r90rmu10` is for 90% read, 10% 'read-modify-update'
        - These correspond to the workload types that are used in ycsb
    - `_10_`, `_20_`, `_30_`, `_40_`, `_50_`
        - These are the number of nodes, so 10 ycsb nodes, 20 ycsb nodes, etc
    - `_timed_15_` means it's a test that will run for 15 minutes. This keeps our test turnaround time reasonable
        - Note: we always have to load every item, this can take about 4 hours for 300 million items, then with 4 15 minute tests, we get around 5 hours turnaround time. I've run them overnight/weekend with 10 pods, 20 pods, up to 50 pods, when doing everything we get about 10 hours to run tests
- Some of the older tests were named `_20_...`, those were before my "final" naming scheme. I recommend sticking to the 'final' tests as they are the most used/consistent

## FDB

```
"ycsb-statefulset": {
      "ycsb_load_or_run_phase": "load_phase",
      "replicas": 1,
      "num_keys": 300000000,
      "override_operation_count": "false",
      "threads_per_process": 16,
      "batch_size": 100,
      "read_proportion": 0.0,
      "update_proportion": 0.0,
      "insert_proportion": 1.0,
      "read_modify_write_proportion": 0.0,
      "max_execution_time_seconds": 200000
}
```
- `ycsb_load_or_run_phase`: This is the phase of the test, `load_phase` is for loading the database, `run_phase` is for running the test
- `replicas`: This is the number of pods that will be created
- `num_keys`: This is the number of keys that will be loaded into the database, and describes the key range used in run tests
- `override_operation_count`: This is a boolean, if true, it will override the operation count, if false, it will use the default operation count
    - This is necessary to ensure we have enough tests to fill a 15 minute run
- `threads_per_process`: This is the number of threads that will be used in the ycsb test
- `batch_size`: This is the batch size that will be used in the ycsb test
- `read_proportion`: This is the proportion of reads that will be used in the ycsb test
- `update_proportion`: This is the proportion of updates that will be used in the ycsb test
- `insert_proportion`: This is the proportion of inserts that will be used in the ycsb test
- `read_modify_write_proportion`: This is the proportion of read-modify-write that will be used in the ycsb test
- `max_execution_time_seconds`: This is the maximum execution time in seconds that the ycsb test will run for
    - this number is very high when I don't want a time limit, and is 900 for a 15 minute test

# fdb_template.yaml, machineset_template.yaml, and local_storage_operator_template.yaml

- NOTE: * **DEPRECATED** *: No longer being used

