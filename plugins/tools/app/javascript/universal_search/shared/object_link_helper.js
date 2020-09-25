const OBJECT_URL_PATH = {
  server: (id) => `compute/instances/?overlay=${id}`,
  volume: (id) => `block-storage/volumes?overlay=${id}`,
  volume_snapshot: (id) => `block-storage/snapshots?overlay=${id}`,
  image: (id) => `image/ng#/os-images/available/${id}/show`,
  flavor: (id) => `compute/flavors`,
  external_network: (id) => `networking/networks/external?overlay=${id}`,
  network: (id) => `networking/networks/external?overlay=${id}`,
  router: (id) => `networking/routers?overlay=${id}`,
  port: (id) => `networking/ports#/ports/${id}/show`,
  floatingip: (id) => `networking/floating_ips`,
  security_group: (id) => `networking/security_groups/${id}`,
  loadbalancer: (id) => `loadbalancing/loadbalancers/${id}/listeners`,
  zone: (id) => `dns-service/zones/${id}`,
  share: (id) => `shared-filesystem-storage/#/shares/${id}/show`,
  share_network: (id) =>
    `shared-filesystem-storage/#/share-networks/${id}/show`,
  security_service: (id) =>
    `shared-filesystem-storage/#/security-services/${id}/show`,
  share_snapshot: (id) => `shared-filesystem-storage/#/snapshots/${id}/show`,
}

export const projectUrl = (item) => {
  if (!item) return null
  const scope = item.payload.scope || {}
  const isProject = item.cached_object_type == "project"
  let projectLink = null
  if (isProject) {
    projectLink = `/${item.domain_id}/${item.id}/home`
  } else if (scope.domain_id && scope.project_id) {
    projectLink = `/${scope.domain_id}/${scope.project_id}/home`
  }
  return projectLink
}

export const objectUrl = (item) => {
  if (!item) return null
  if (!item.project_id) return null

  let object_type = item.cached_object_type
  if (object_type == "snapshot") {
    if (item.payload.share_id) object_type = "share_snapshot"
    else if (item.payload.volume_id) object_type = "volume_snapshot"
  } else if (object_type == "network") {
    if (item.payload["router:external"]) {
      object_type = "external_network"
    }
  }

  const path = OBJECT_URL_PATH[object_type]
  if (!path) return null
  const scope = item.payload.scope || {}
  return `/${scope.domain_id}/${scope.project_id}/${path(item.id)}`
}

export const vCenterUrl = (item, aggregates) => {
  if (!item || !aggregates || aggregates.length === 0) return null

  let objectType = item.cached_object_type
  if (objectType !== "server") return

  let host = item.payload["OS-EXT-SRV-ATTR:host"]
  if (!host) return
  let az = item.payload["OS-EXT-AZ:availability_zone"]
  if (!az) return

  let vcAggregate = aggregates.find((a) =>
    a.payload && a.payload.hosts ? a.payload.hosts.indexOf(host) >= 0 : false
  )
  if (!vcAggregate) return

  // parse region and zone
  let region = az.slice(0, -1)
  let zone = az.slice(-1)
  let serverID = item.id

  return `https://${vcAggregate.name}.cc.${region}.cloud.sap/ui/#?extensionId=vsphere.core.search.domainView&query=${serverID}&searchType=simple`
  // return `https://vc-${zone}-0.cc.${region}.cloud.sap/ui/#?extensionId=vsphere.core.search.domainView&query=${serverID}&searchType=simple`
}
