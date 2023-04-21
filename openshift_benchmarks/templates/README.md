# Values.json

- As of right now, testing1 and testing2 were just to help me build the tempating system, we can remove those once we are confident everything works properly.
- demo_setup is what we will use for demo.redhat clusers, as we don't want to overwhelm them, since they are not set up for perf testing.
- performance_load_setup_do_not_use_on_demo_system is what we will use for our performance testing (We can change the name later), as we want to see how the system performs under load.
    - We won't know these values for sure until we do some inital testing
    - cluster_controller: The number of cluster controllers to deploy, usually this will only be 1, but we may need more if we split up zones or find it's overloaded
    - storage: The number of storage nodes to deploy, I know we need 60 at some point
    - log: The logging nodes, likely 1 per zone, but we might find out write performance is an issue and need more
    - stateless: A bunch of "other" things according to FDB, Docs look like they recommend 2-3 per zone
    - volume_claim_storage": Up to us, we need to determine how much storage we want to give to the cluster

# fdb_template.yaml

- TODO: determine if more configuration is needed, and if it needs to be templatized
- This template was taken from the foundationdb repo, with slight modifications, and tamplating added
- the process.general.podTemplate.spec.containers.resources.requests.{cpu,memory} do we need to configure these for the foundationdb container? We might find this is limiting, or just fine. Fine tuning this would need to be done at some point
    - Same for the sidebar and init containers. They are currently configured the same, but does that work best?

# local_storage_operator_template.yaml

- TODO: determine if more configuration is needed, and if it needs to be templatized
- This was used to make the operator work on the demo cluster, but I don't think we need Subscriptions, do we need OperatorGroups?

