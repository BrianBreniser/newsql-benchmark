# Quickstart

Just need to know how to run it and how to get results? This is the section for you!

There are 3 main parts to know how about to run this:
- `loop_through_all_tests` - This is the main script that runs the tests, you run it like this:
    - `./loop_through_all_tests <config name>`, those <config name>'s come from the `templates/values.json` file
- `values.json` file: This is a big key/value file in json that stores the configuration for ycsb that will run
    - Read this file to learn about all the various configs we've set up, but you can get started by simply running:
        - `./loop_through_all_tests.sh final_md_l_1 final_md_r_20_timed_15 final_md_u_20_timed_15 final_md_w_20_timed_15 final_md_r90rmu10_20_timed_15` for a basic set of tests
- `results.txt`: this file is where the results will be stored. You can rename this file and put it into the results_compiled directory if you want to keep it and run a new set of tests

# I need more information

Sounds good, let's dive in!

## what does values.json do? How does it relate to ycsb_statefulset_template.yaml?

`values.json`: So, values.json holds 4 cofigs, but 3 of them are unused at the moment (Feb 2024). The YCSB config has various options you can read in the file. I recommend starting at final_md_l_1 (Naming things is hard...) and reading from there. You won't get a full explanation of how YCSB works or is configured here, you will need to read about that on your own, but the important bits here is that each of those lines configure are applied in the `templates/ycsb_statefulset_template.yaml` file.

`ycsb_statefulset_template.yaml`: This is a regular kubernets statefulset file, but templated such that all {{keys}} will be filled with values from the values.json file referenced above. Diving into the `containers:` secion, you see that we pull from `quay.io/breniserbrian/ycsb:latest` for our container. The `Dockerfile` that made this is the `Dockerfile` in the base of this directory. The command this containefile runs is `bash` and simply runs what's in the `args` secion, which is one big script. Sorry this is so rough, it's a quick-n-dirty way of running a script like this. Works great but is kind ugly. We set up a bunch of environment variables, which are mostly templatized, and we set up 2 commands, load_phase() and run_phase(). We switch which command we run based on the {{ycsb_load_or_run_phase}} template item. We wrap this call in a loop that runs 1 or more processes and backgrounds them, waits for all of them to finish, and outputs a final log item that we look for in our YCSB log 

`results.txt`: So what do we put in the results.txt file? You can follow the scripts and their log outputs by starting with `loop_through_all_tests.sh` and reading each command it uses, the details of these commands are below, but the important thing is that the results.txt file will contain sections based on each ycsb config ran, it will dump the YCSB config (parts of the yaml file applied to the cluster), the `fdb status details` , and keep dumping `fdbcli status details` at various points in the run. Finally, when all YCSB pods are finished (Based on that `finished...` line being present) We run a pythong script to grab all ycsb logs off of all pods, pull them to your local machine, and finally combine them, and dump that output to the end of the log in results.txt

A general note, the reason that all the commands are just runnable commands in the directory is that for debugging it was easier building up these commands one at a time. I've slowly added functionality and features, abstracted away details, and automated more and more, until we got to this point. Since there was no clear ending from the beginning, it turned out this way. The good news is that you can run each script separately to see how it works and figure things out by example. Let's dive into how this all works next.

# Knowledge about each file and directory

## apply_templating.py

- Uses Python3 in #!/usr/bin/env python3, this should find the python3 interpreter on your system.
- RUN: `./apply_templating.py <config name>` from this directory.
    - WARNING: This will overwrite the yaml files in this directory. If you have made changes to them, they will be lost.
    - To find the config options, open the templates/values.json directory. It's the top level keys in the json file.
    - The [other README.md](templates/README.md) in the templates directory has more information on how the templates work
- This script was hand-written for its task, and is not a generic templating script. It is not intended to be used for other purposes. It serves its purpose well
- Running the script will dump the output of the yaml files in the current directory
- These yaml files are used by setup_script.sh to install the components on the openshift cluster

## setup_script.sh

NOTE: * **DEPRECATED** * This script is no longer used, but is left here for reference

- The setup script runs `oc` commands to instll the necessary components on the openshift cluster.
- RUN: Log into the openshift cluster using the `oc login` command. run './setup_script.sh' from thid directory.
- Some components in this script do not require YAML files, and are installed directly using the `oc` command. Or are operators that are installed using the operator hub.

## notify-send.sh

- Let's explain this one first, I use a command called 'notify-send' to send myself desktop notifications on linux
- if you don't have this app, the scripts fail, but really they don't need too, becuase it's just a notification
- so this script wraps the call, if you have it, it calls it, if not, it echo's the same arguments to the terminal

## loop_through_all_tests.sh

- one big loop that
    - echo's the test being run
    - applies the templating
    - runs `./reset_ycsb.sh` script for that test

## reset_ycsb.sh

- deletes the statefulset
- waits for the statefulset pods to be deleted
- gets the statefulset info and puts it in results.txt
- applies the templating
- runs `./loop_get_logs_lastline.sh`

## loop_get_logs_lastline.sh

- This one is big, but it's pretty straightforward
- loops through all pods and gets the last line of the log file and prints it
- once all pods are started, it collects metrics from fdbcli
- it does that again after various times have passed (2 minutes and 10 minutes as of Feb 2024)

## get_ycsb_fdb_setup.sh

- is run near the beginning of the test
- gets a subset of items from the ycsb yaml file
- gets a subset of info from fdbcli

# Debugging scrips

## get_tlogs.sh

- grab the tlogs from the fdb cluster

## loop_get_logs.sh

- gets *all* the logs from *all* the pods. This is a lot of data, but it's useful for debugging

## azure_localstorage_setup_config/

NOTE: * **DEPRECATED** * This script is no longer used, but is left here for reference

- Was used in testing to setup a local storage operator on Azure L-Series vms. This is not needed for the demo, but is left here for reference.

## fdb-kubernetes-operator/

NOTE: * **DEPRECATED** * This script is no longer used, but is left here for reference

- This is the foundationdb operator that is installed on the openshift cluster.
- I embedded the entire project here, because the operator is not available anywhere else, and Apples site where the operator should be hosted (according to the README files in the source code) is no longer up and hosting the files.

## templates/

- Holds the tempates and values.json file that are used by the apply_templating.py script

## *.yaml

- All yaml files in this directory are generated by the apply_templating.py script. They should not be edited directly. The templates should be edited instead and the `apply_templating.py` command run to replace them.

## How to add a new name_template.yaml file

- Some steps are required to adda a new templated yaml file to the list of generated files
    - 1: Add the new name_template.yaml file to the `templates` directory
    - 2: Update the tempate_list in the `apply_templating.py` script to include the new template files (All values will be in values.json for now, even though it is configurable)
    - 3: Add the config options to the templates/values.json file with any template values you added to the name_template.yaml file
    - 4: Add the new yaml file (The final name) to the .gitignore file (so you don't keep committing minor edits to git)

## YCSB notes

### Found these in the ansible configs
- ycsb_cmd: "sh {{ycsb_dir}}/bin/ycsb.sh
    - {{ycsb_operation}} // probably load or run based on loadgen_workload_name being 'insert' or not
    - {{ycsb_binding_name}} // 'fdb' 
    - -s -P {{ycsb_dir}}/workloads/{{ycsb_workload_name}} // either 'workloada' or 'workloadb' // based on loadgen_workload_name being 'insert' or not
    - {{ycsb_params}} >> {{loadgen_log_file}} 2>&1" // see below

- ycsb_params: 
    - {{ycsb_db_specific_params}} // -p foundationdb.apiversion=620 -p foundationdb.clusterfile=/etc/foundationdb/fdb.cluster -p foundationdb.batchsize=100'
        - is 620 still a correct apiversion?
    - {{ycsb_insert_params}}
        - ycsb_insert_params: "{% if loadgen_workload_name == 'insert' %} -p insertstart={{ loadgen_start_key_per_host_process | int }} -p insertcount={{ loadgen_keys_per_process| int }} -p operationcount={{( (loadgen_keys_per_process | int) / loadgen_batch_size | int) |int}}{% else %} -p operationcount={{ ycsb_op_count }} {% endif %}"
            - loadgen_keys_per_process: "{{ ((loadgen_keys_per_host | int)/ (loadgen_process_per_host|int)) | int}}"
    - -p recordcount={{loadgen_num_keys}} // 1000000
    - -p readproportion={{ycsb_read_proportion}} // workoad config, 0-1, what % of operations are read (example, 0.9)
    - -p updateproportion={{ycsb_update_proportion}} // workoad config, 0-1, what % of operations are write (example 0.1)
        - These two values should equal 1, 0.9+0.1, 1.0+0.0, etc.
    - {{ycsb_additional_params}} 
    - -p threadcount={{ loadgen_threads_per_process }} // varied from 1-16 in the configs

- ycsb_additional_params:
    - -p requestdistribution=uniform 
    - -p maxexecutiontime={{ ycsb_max_execution_time_seconds }} // 60 * 60 * 24 * 14 // 2 weeks
    - -p table=usertable
    - -p insertorder=hashed 
    - -p zeropadding=12 
    - -p fieldlength={{ycsb_field_length}} // 2000 
    - -p fieldcount={{ycsb_field_count}} // 1












