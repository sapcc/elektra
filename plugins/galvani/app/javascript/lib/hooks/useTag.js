import React from "react"

// remove service params from the key
// Ex
// dns_reader --> name: dns_reader, hasVars: false
// dns_edit_zone:$1 --> name: dns_edit_zone, hasVars: true
const getServiceParams = (service) => {
  const params = service.split(":")
  let name = params[0] || ""
  let hasVars = false
  if (params[1]) {
    if (params[1].includes("$")) {
      hasVars = true
    } else {
      name = `${name}:${params[1]}`
    }
  }
  return { key: service, name: name, hasVars: hasVars }
}

const getTopologyTags = (cfg, tags) => {
  console.log("tags: ", tags, " cfg: ", cfg)

  const topo = {}
  // loop over access prefixes
  Object.keys(cfg).forEach((profileKey) => {
    // TODO remove xs: prefix
    const profileName = profileKey.split(":")[1] || profileKey
    if (!topo[profileName]) topo[profileName] = {}

    console.log("profileName: ", profileName)

    // loop over services from in the access prefix
    Object.keys(cfg[profileKey]).forEach((serviceKey) => {
      const serviceParams = getServiceParams(serviceKey)
      // add service
      topo[profileName][serviceParams.name] = {
        description: cfg[profileKey][serviceKey]["description"],
        displayName: cfg[profileKey][serviceKey]["display_name"],
        tags: [],
      }

      // find tags with this access prefix
      tags.forEach((tag) => {
        const prefix = `${profileKey}:${serviceParams.name}`
        if (tag.startsWith(prefix)) {
          const value = tag.split(`${prefix}:`)[1] || null
          topo[profileName][serviceParams.name]["tags"].push({
            tag: tag,
            value: value,
          })
        }
      })

      // sort tags in the service by value
      topo[profileName][serviceParams.name]["tags"] = topo[profileName][
        serviceParams.name
      ]["tags"].sort((a, b) => a.value.localeCompare(b.value))
    })

    // sort sevices
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
