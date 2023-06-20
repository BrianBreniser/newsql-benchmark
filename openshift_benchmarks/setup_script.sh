#!/usr/bin/env bash
set -eu # -e for exit on error, -u for error on unset variables
set -o pipefail # fail if one part of a pipe fails (From manpage: If  set, the return value of a pipeline is the value of the last (rightmost) command to exit with a non-zero status, or zero if all commands in the pipeline exit successfully.  This option is disabled by default.)

######################
## Helper functiohs ##
######################

function log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1"
}

###################
## Alter runtime ##
###################

# check if the DEBUG environment variable is set
if [[ -n "${DEBUG:-}" ]]; then
    log "DEBUG is set, setting -xv"
    set -xv # -x for print commands, -v for print shell input lines
fi

#########################
## Installer Functions ##
#########################

function install_prometheus() {
    # Only install prometheus if it is not already installed
    log "Checking if prometheus is already installed"
    if ! helm list | grep -q prometheus; then
        log "Installing prometheus"
        helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
        helm repo update
        helm install prometheus prometheus-community/prometheus
        log "exposing the route"
        oc expose svc/prometheus-server
    else
        log "Prometheus is already installed"
    fi
}

# TODO: Determine if this is better than just installing with helm
function install_prometheus_operator() {
    # Only install prometheus operator if it is not already installed
    # TODO: Is this the right name for the operator???
    log "Checking if prometheus operator is already installed"
    if ! helm list | grep -q prometheus-operator; then
        log "Installing prometheus operator"
        helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
        helm repo update
        helm install prometheus-operator prometheus-community/kube-prometheus-stack
        # TODO: expose the route (Have not installed using the operator yet, so don't know what the route is called)
    else
        log "Prometheus operator is already installed"
    fi
}

# TODO: this is tempoarary, I'm just keeping this here for now, I may not use it
function install_grafana() {
    # Only install grafana if it is not already installed
    log "Checking if grafana is already installed"
    if ! helm list | grep -q grafana; then
        log "Installing grafana"
        helm repo add grafana https://grafana.github.io/helm-charts
        helm repo update
        helm install grafana grafana/grafana
        log "exposing the route"
        oc expose svc/grafana
    else
        log "Grafana is already installed"
    fi
}

function install_local_storage_operator() {
    # create the openshift-local-storage namespace if it doesn't already exist
    log "Checking if openshift-local-storage namespace exists"
    if ! oc get namespace | grep -q openshift-local-storage; then
        log "Creating openshift-local-storage namespace"
        oc create namespace openshift-local-storage
    else
        log "openshift-local-storage namespace already exists"
    fi

    # Only install local storage operator if it is not already installed
    log "Checking if local storage operator is already installed"
    if ! oc get Subscription -n openshift-local-storage | grep -q local-storage-operator; then
        log "Installing local storage operator"
        # OC_VERSION=$(oc version -o yaml | rg openshiftVersion | grep -o '[0-9]*[.][0-9]*' | head -1)
        oc apply -f local_storage_operator.yaml
    else
        log "Local storage operator is already installed"
    fi
}

# function install_fdb_operator() {
#     # Only install fdb if it is not already installed
#     log "Checking if fdb is already installed"
#     if ! helm list | grep -q fdb-kubernetes-operator; then
#         log "Installing fdb"
#         helm install fdb-kubernetes-operator fdb-kubernetes-operator/charts/fdb-operator
#     else
#         log "FDB is already installed"
#     fi
# }
function install_fdb_operator() {
    oc apply -f https://raw.githubusercontent.com/FoundationDB/fdb-kubernetes-operator/main/config/crd/bases/apps.foundationdb.org_foundationdbclusters.yaml
    oc apply -f https://raw.githubusercontent.com/FoundationDB/fdb-kubernetes-operator/main/config/crd/bases/apps.foundationdb.org_foundationdbbackups.yaml
    oc apply -f https://raw.githubusercontent.com/FoundationDB/fdb-kubernetes-operator/main/config/crd/bases/apps.foundationdb.org_foundationdbrestores.yaml
    oc apply -f https://raw.githubusercontent.com/foundationdb/fdb-kubernetes-operator/main/config/samples/deployment.yaml
}

function install_fdb_cluster() {
    log "Checking if fdb cluster is already installed"
    if ! oc get foundationdbcluster | grep -q fdb-cluster; then
        log "Installing fdb cluster"
        oc apply -f fdb.yaml
    else
        log "FDB cluster is already installed"
    fi
}

function run_ycsb_pod() {
    log "Checking if ycsb pod is already running"
    if ! oc get deployment | grep -q ycsb-deployment; then
        log "Running ycsb pod"
        oc apply -f ycsb_deployment.yaml
    else
        log "ycsb pod is already running"
    fi
}

####################
# Helper functions #
####################

function check_args() {
    # if -h or --help is passed, show the help
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        echo "Usage: ./setup_script.sh"
        echo "Or: ./setup_script.sh -h|--help"
        echo "Use this script after running ./apply_templating.py if you updated the template files."
        echo "This script will install the following:"
        echo "  - Prometheus"
        echo "  - Grafana (Currently disabled, used only for testing)"
        echo "  - Local Storage Operator (currently disabled, used only for testing)"
        echo "  - FoundationDB Operator"
        echo "  - FoundationDB Cluster"
        exit 0
    fi
}

##########
## Main ##
##########

# if the number of arguments is more than 1
if [[ "$#" -gt 0 ]]; then
    check_args "$@"
fi

# install_prometheus # TODO: Determine if this, or the operator, is better
# install_grafana
# install_local_storage_operator
install_fdb_operator
install_fdb_cluster
# run_ycsb_pod
# ycsb is next

