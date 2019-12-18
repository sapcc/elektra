export const REQUEST_DATA         = 'resources/app/REQUEST_DATA';
export const REQUEST_DATA_FAILURE = 'resources/app/REQUEST_DATA_FAILURE';
export const RECEIVE_DATA         = 'resources/app/RECEIVE_DATA';

export const REQUEST_CAPACITY         = 'resources/app/REQUEST_CAPACITY';
export const REQUEST_CAPACITY_FAILURE = 'resources/app/REQUEST_CAPACITY_FAILURE';
export const RECEIVE_CAPACITY         = 'resources/app/RECEIVE_CAPACITY';

export const REQUEST_INCONSISTENCIES         = 'resources/app/REQUEST_INCONSISTENCIES';
export const REQUEST_INCONSISTENCIES_FAILURE = 'resources/app/REQUEST_INCONSISTENCIES_FAILURE';
export const RECEIVE_INCONSISTENCIES         = 'resources/app/RECEIVE_INCONSISTENCIES';

export const SYNC_PROJECT_REQUESTED  = 'resources/app/SYNC_PROJECT_REQUESTED';
export const SYNC_PROJECT_FAILURE    = 'resources/app/SYNC_PROJECT_FAILURE';
export const SYNC_PROJECT_STARTED    = 'resources/app/SYNC_PROJECT_STARTED';
export const SYNC_PROJECT_FINISHED   = 'resources/app/SYNC_PROJECT_FINISHED';

export const REQUEST_AUTOSCALABLE_SUBSCOPES = 'resources/app/REQUEST_AUTOSCALABLE_SUBSCOPES';
export const REQUEST_AUTOSCALABLE_SUBSCOPES_FAILURE = 'resources/app/REQUEST_AUTOSCALABLE_SUBSCOPES_FAILURE';
export const RECEIVE_AUTOSCALABLE_SUBSCOPES = 'resources/app/RECEIVE_AUTOSCALABLE_SUBSCOPES';

export const REQUEST_CASTELLUM_CONFIG = 'resources/app/REQUEST_CASTELLUM_CONFIG';
export const REQUEST_CASTELLUM_CONFIG_FAILURE = 'resources/app/REQUEST_CASTELLUM_CONFIG_FAILURE';
export const RECEIVE_CASTELLUM_CONFIG = 'resources/app/RECEIVE_CASTELLUM_CONFIG';
export const RECEIVE_CASTELLUM_RESOURCE_CONFIG = 'resources/app/RECEIVE_CASTELLUM_RESOURCE_CONFIG';

export const REQUEST_CASTELLUM_OPERATIONS_REPORT = 'resources/app/REQUEST_CASTELLUM_OPERATIONS_REPORT';
export const REQUEST_CASTELLUM_OPERATIONS_REPORT_FAILURE = 'resources/app/REQUEST_CASTELLUM_OPERATIONS_REPORT_FAILURE';
export const RECEIVE_CASTELLUM_OPERATIONS_REPORT = 'resources/app/RECEIVE_CASTELLUM_OPERATIONS_REPORT';

// Please do not use this directly. Use t() from ./utils.js instead.
export const STRINGS = {
    "autoscaling":                 "Autoscaling",
    "availability_zones":          "Availability Zones",
    "block_storage":               "Block Storage",
    "capacity":                    "Capacity",
    "cfm_share_capacity":          "Share Capacity",
    "compute":                     "Compute",
    "cores":                       "Cores",
    "cores_single":                "Core",
    "database":                    "Cloud Frame Manager",
    "dns":                         "DNS",
    "floating_ips":                "Floating IPs",
    "floating_ips_single":         "Floating IP",
    "healthmonitors":              "Health Monitors",
    "healthmonitors_single":       "Health Monitor",
    "images":                      "Images",
    "instances":                   "Instances",
    "instances_single":            "Instance",
    "inconsistencies":             "Inconsistencies",
    "keppel":                      "Container Image Registry",
    "l7policies":                  "L7 Policies",
    "l7policies_single":           "L7 Policy",
    "listeners":                   "Listeners",
    "listeners_single":            "Listener",
    "loadbalancers":               "Load Balancers",
    "loadbalancers_single":        "Load Balancer",
    "loadbalancing":               "Loadbalancing",
    "networking":                  "Network",
    "network":                     "Network",
    "networks":                    "Networks",
    "networks_single":             "Network",
    "object_storage":              "Object Storage",
    "object-store":                "Object Storage",
    "per_flavor":                  "Restricted Flavors",
    "pools":                       "Pools",
    "pools_single":                "Pool",
    "pool_members":                "Pool Members",
    "pool_members_single":         "Pool Member",
    "ports":                       "Ports",
    "ports_single":                "Port",
    "ram":                         "RAM",
    "rbac_policies":               "RBAC Policies",
    "rbac_policies_single":        "RBAC Policy",
    "recordsets":                  "Recordsets per Zone",
    "routers":                     "Routers",
    "routers_single":              "Router",
    "security_group_rules":        "Security Group Rules",
    "security_group_rules_single": "Security Group Rule",
    "security_groups":             "Security Groups",
    "security_groups_single":      "Security Group",
    "share_capacity":              "Share Capacity",
    "shared_filesystem_storage":   "Shared Filesystem Storage",
    "share_networks":              "Share Networks",
    "share_networks_single":       "Share Network",
    "share_snapshots":             "Share Snapshots",
    "share_snapshots_single":      "Share Snapshot",
    "shares":                      "Shares",
    "shares_single":               "Share",
    "sharev2":                     "Shared Filesystem Storage",
    "snapshot_capacity":           "Share Snapshot Capacity",
    "snapshots":                   "Snapshots",
    "snapshots_single":            "Snapshot",
    "storage":                     "Storage",
    "subnet_pools":                "Subnet Pools",
    "subnet_pools_single":         "Subnet Pool",
    "subnets":                     "Subnets",
    "subnets_single":              "Subnet",
    "volumes":                     "Volumes",
    "volumes_single":              "Volume",
    "volumev2":                    "Block Storage",
    "zones":                       "Zones",
    "zones_single":                "Zone",
};

export const WIZARD_RESOURCES = {
    "compute": {
        "preselect": true,
        "resources": { "instances": 5 },
    },
    "networking": {
        "preselect": true,
        "highlight": [ "floating_ips", "networks" ],
        "resources": { "floating_ips": 2, "networks": 1, "ports": 500, "rbac_policies": 5, "security_groups": 20, "security_group_rules": 100 },
    },
    "loadbalancing": {
        "resources": { "loadbalancers": 1 },
    },
    "dns": {
        "resources": { "recordsets": 100 },
    },
    "object-store": {
        "resources": { "capacity": 100 * (1 << 30) }, // 100 GiB
    },
    "volumev2": {
        "resources": { "volumes": 2 },
    },
};
