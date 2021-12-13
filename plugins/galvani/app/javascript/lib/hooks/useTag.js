import React from "react"

// given --> dns:reader, dns_edit_zone:$1
const getServiceParams = (service) => {
  const params = service.split(":")
  let name = params[0] || ""
  let hasVars = false
  if (params[1]) {
    // TODO we still need this check??
    if (params[1].includes("$")) {
      hasVars = true
    } else {
      name = `${name}:${params[1]}`
    }
  }
  return { name: name, hasVars: hasVars }
}

const getTopologyTags = (cfg, tags) => {
  console.log("tags: ", tags, " cfg: ", cfg)

  const topo = {}
  // loop over access prefixes
  Object.keys(cfg).forEach((profileKey) => {
    if (!topo[profileKey]) topo[profileKey] = {}

    // loop over services from in the access prefix
    Object.keys(cfg[profileKey]).forEach((serviceKey) => {
      const serviceParams = getServiceParams(serviceKey)
      topo[profileKey][serviceParams.name] = {
        description: cfg[profileKey][serviceKey]["description"],
        items: [],
      }

      // find tags with this access prefix
      tags.forEach((tag) => {
        if (tag.startsWith(`${profileKey}:${serviceParams.name}`)) {
          topo[profileKey][serviceParams.name]["items"].push(tag)
        }
      })

      // sort tags in the service
      topo[profileKey][serviceParams.name]["items"] = topo[profileKey][
        serviceParams.name
      ]["items"].sort((a, b) => a.localeCompare(b))
    })
  })

  console.log("topo: ", topo)

  return topo
}

const useTag = (cfg, tags) => {
  return React.useMemo(() => {
    if (!cfg) return null
    // check undefined input
    if (!tags) tags = []
    // inforce inputs as array
    if (!Array.isArray(tags)) tags = [tags]

    return getTopologyTags(cfg, tags)
  }, [JSON.stringify(tags), JSON.stringify(cfg)])
}

export default useTag
