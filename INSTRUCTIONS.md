# Automated benchmark tool for NewSQL databases

Currently suported DBs
- Foundation DB
- Cockroach DB
- TiDB

Currently supported workload generators
- YCSB

## Steps to run
### Install required packages
| Tool      | Version  |
|-----------|----------|
| Python    | 3.x      |
| Terraform | 0.14.2   |
| Ansible   | 2.10.3_1 |
| Azure CLI | 2.16.0   |
| GNU Tar   | 1.32     |
*[on local machine]*
```shell script
brew install terraform ansible azure-cli gnu-tar
brew upgrade terraform ansible azure-cli gnu-tar
```
### Login to Azure
**Make sure that you are logged into the Adobe San Jose VPN**
Visit http://sanjose-ssh-out.corp.adobe.com/

*[on local machine]*
```shell script
az login
# Follow instructions to complete login
az account list --output table
az account set --subscription 60631e84-1bf3-42ca-bacc-c5242b586725
# use the subcription id for the R&D subscription ^
```

### Update Harness specification files
*[on local machine]*

This file lists various experiments to run. 
Each experiment specifies a database to benchmark and various workload to run on it. 
```shell script 
vim harness/harness-experiments.json
```
This file lists various clusters to use. 
The harness-experiments.json file makes reference to these clusters.
```shell script 
vim harness/harness-clusters.json
```
### Update grafana password
- Navigate to newsql-benchmark/ansible/common_install_monitoring.yaml
- Update the grafana_security section and add the following
      admin_password: <enter_your_password>
      
### Run script to provision control machine. 
Provide a unique prefix to use to name all provisioned Azure resources. Set this in an environment variable `DBEVAL_PREFIX`.
The recommended value for this prefix is `uis-dbeval-<username>-<dbname>`
*[on local machine]*
```
export DBEVAL_PREFIX=uis-dbeval-arsriram-fdb
sh start-control-machine.sh
```

### Steps to login to control machine and run benchmarks
#### SSH to control machine
*[on local machine]*
-     export CONTROL_MACHINE_IP=\`cat ansible/inventory-cm.yaml| grep '\[control\]' -A 1| tail -n1\` ; ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i terraform/out/id_rsa_tf -L 3000:localhost:3000 fdb@\$CONTROL_MACHINE_IP"
#### Run benchmarks on control machine
This command will run all specified benchmarks and will create tar files on the control machine in the ~/results directory.
The tar archive will include the following 
  1. Benchmark report generated by the Harness program (<workingDir>/results/<experiment-name>.csv)
  2. Log file for the Harness program (harness.log). This file shows all the ansible/terraform/shell commands that were run at each step.
  3. Log files generated by each loadgen process, organized by host.

**NOTE**: This command can leave the last specified cluster running if the keepAlive option is specified. **Remember to turn off your unused clusters.**
  
*[on control machine]*
-     az login
      az account set --subscription 60631e84-1bf3-42ca-bacc-c5242b586725"
      # start a tmux session
      tmux
      # run harness program
      cd ~/harness ; python3 harness.py 
      # hit ctrl+b,c to create a new window in tmux
      tail -f harness.log
      # hit ctrl+b,c to create a new window in tmux
      cat ~/harness/workingDir/<run-id>/results/<experiment_name>.csv
      
      cat fdb-experiment-5node-100m.results.csv | cut -d"," -f2,4,5,13,15,17,
      18 |  column -s, -t | less
      
      
*[on local machine]*
- Open http://localhost:3000 in your browser to access grafana. Use username:admin, password:<enter_your_password>. If port is not open, use the following command
   
- ```export CONTROL_MACHINE_IP=`cat ansible/inventory-cm.yaml| grep '\[control\]' -A 1| tail -n1` ; ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i terraform/out/id_rsa_tf -L 3000:localhost:3000 fdb@$CONTROL_MACHINE_IP```
- The Node exporter dashboard comes pre-installed and can be used to monitor cluster health.
   For FDB, you can import the dashboard in ansible/files/FDB-Grafana-Dashboard.json
   
### SCP the results from the control machine to your local machine"
*[on control machine]*

   ```tar -cvzf ~/results ~/results.tgz```
   
*[on local machine]*

```export CONTROL_MACHINE_IP=`cat ansible/inventory-cm.yaml| grep '\[control\]' -A 1| tail -n1` ```
```scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i terraform/out/id_rsa_tf fdb@\$CONTROL_MACHINE_IP:./results.tgz .```


### Destroy all resources
*[on control machine]*
-     export DBEVAL_PREFIX=uis-dbeval-<username>-<dbname>
-     cd ~/terraform; terraform apply -auto-approve -var prefix=$DBEVAL_PREFIX -var 'override_ascluster_map={vm_type="Standard_L8s_v2", vm_count="0", disks_per_vm="0"}' -var 'override_loadgencluster_map={vm_type="Standard_F8s_v2", vm_count="0"}'
*[on local machine]*
-     export DBEVAL_PREFIX=uis-dbeval-<username>-<dbname>
-     cd terraform;  terraform destroy -auto-approve -var prefix=$DBEVAL_PREFIX

## How to Run Ansible Playbooks
### Run Ansible Playbooks against control machine
*[on local machine]*
```shell script
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i ansible/inventory.yaml -i ansible/inventory-cm.yaml --user fdb --private-key terraform/out/id_rsa_tf ansible/<play-book-name>.yaml
```

### Run Ansible Playbooks against DB/loadgen machines
*[on control machine]*
```shell script
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i ansible/inventory.yaml -i ansible/inventory-cm.yaml --user fdb --private-key terraform/out/id_rsa_tf ansible/<play-book-name>.yaml
```
## How to Run adhoc commands on cluster using Ansible
### Run Ansible adhoc commands on all db nodes in the cluster
*[on control machine]*
```shell script
export ANSIBLE_HOST_KEY_CHECKING=False
ansible -i ansible/inventory.yaml -i ansible/inventory-cm.yaml -i ansible/inventory.yaml -u fdb --private-key terraform/out/id_rsa_tf as -m shell -a 'COLUMNS=120 top -o %CPU -b -c -d1 -n1 | head -n5'
```
### Run Ansible adhoc commands on all loadgen nodes in the cluster
```shell script
export ANSIBLE_HOST_KEY_CHECKING=False
ansible -i ansible/inventory.yaml -i ansible/inventory-cm.yaml -i ansible/inventory.yaml -u fdb --private-key terraform/out/id_rsa_tf loadgen -m shell -a 'COLUMNS=120 top -o %CPU -b -c -d1 -n1 | head -n5'
```
