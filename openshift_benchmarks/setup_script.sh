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

function install_fdb_operator() {
    # Only install fdb if it is not already installed
    log "Checking if fdb is already installed"
    if ! helm list | grep -q fdb-kubernetes-operator; then
        log "Installing fdb"
        helm install fdb-kubernetes-operator fdb-kubernetes-operator/charts/fdb-operator
    else
        log "FDB is already installed"
    fi
}

function install_fdb_cluster() {
    log "Checking if fdb cluster is already installed"
    if ! oc get foundationdbcluster | grep -q test-cluster; then
        log "Installing fdb cluster"
        oc apply -f fdb_cluster.yaml
    else
        log "FDB cluster is already installed"
    fi
}

##########
## Main ##
##########

install_prometheus # TODO: Determine if this, or the operator, is better
install_grafana
install_fdb_operator
install_fdb_cluster

