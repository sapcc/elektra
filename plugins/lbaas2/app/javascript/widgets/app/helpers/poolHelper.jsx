import React from "react"

export const findPool = (pools, poolID) => {
  if (pools) {
    const index = pools.findIndex((item) => item.id == poolID)
    if (index >= 0) {
      return pools[index]
    }
  }
  return null
}

export const lbAlgorithmTypes = () => {
  return [
    { label: "LEAST_CONNECTIONS", value: "LEAST_CONNECTIONS" },
    { label: "ROUND_ROBIN", value: "ROUND_ROBIN" },
  ]
}

export const poolProtocolTypes = () => {
  return [
    { label: "HTTP", value: "HTTP" },
    // Disable HTTPS when creating listeners
    // With Octavia, HTTPS is exactly the same as TCP (it’s been meant to be TLS-HTTP passthrough for the backends, but octavia doesn’t really handles them any different than TCP).
    { label: "HTTPS", value: "HTTPS", state: "disabled" },
    { label: "PROXY", value: "PROXY" },
    { label: "TCP", value: "TCP" },
    { label: "UDP", value: "UDP" },
  ]
}

export const POOL_PERSISTENCE_APP_COOKIE = "APP_COOKIE"
export const POOL_PERSISTENCE_HTTP_COOKIE = "HTTP_COOKIE"
export const POOL_PERSISTENCE_SOURCE_IP = "SOURCE_IP"
export const poolPersistenceTypes = () => [
    {
      label: POOL_PERSISTENCE_APP_COOKIE,
      value: POOL_PERSISTENCE_APP_COOKIE,
      description:
        "Use the specified cookie_name send future requests to the same member.",
    },
    {
      label: POOL_PERSISTENCE_HTTP_COOKIE,
      value: POOL_PERSISTENCE_HTTP_COOKIE,
      description:
        "The load balancer will generate a cookie that is inserted into the response. This cookie will be used to send future requests to the same member.",
    },
    {
      label: POOL_PERSISTENCE_SOURCE_IP,
      value: POOL_PERSISTENCE_SOURCE_IP,
      description:
        "The source IP address on the request will be hashed to send future requests to the same member.",
    },
  ]


export const poolProtocolListenerCombinations = (poolProtocol) => {
  switch (poolProtocol) {
    case "HTTP":
      return ["HTTP", "TCP", "TERMINATED_HTTPS"]
    case "HTTPS":
      return ["HTTPS", "TCP"]
    case "PROXY":
      return ["HTTP", "HTTPS", "TCP", "TERMINATED_HTTPS"]
    case "TCP":
      return ["HTTPS", "TCP"]
    case "UDP":
      return ["UDP"]
    default:
      return []
  }
}

export const filterListeners = (listeners, selectedProtocol) => {
  return listeners.filter((i) =>
    poolProtocolListenerCombinations(selectedProtocol).includes(i.protocol)
  )
}
