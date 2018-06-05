module ApiServiceTypes
  # include Services

  KNOWN_TYPES = %w[
    access
    access_list
    agent
    availability_zone
    catalog
    cluster
    domain
    export_location
    flavor
    floatingip
    group
    healthmonitor
    hypervisor
    image
    keypair
    l7policy
    listener
    loadbalancer
    member
    message
    network
    pool
    port
    project
    rbac_policy
    recordset
    role
    router
    security_group
    security_group_rule
    security_service
    server
    share
    share_network
    share_type
    snapshot
    subnet
    transfer_request
    user
    volume
    zone
  ]
end
