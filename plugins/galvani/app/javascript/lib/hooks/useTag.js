import React from "react"

// remove service params from the key
// Ex
// dns_reader --> name: dns_reader, hasVars: false
// dns_edit_zone:$1 --> name: dns_edit_zone, hasVars: true
// TODO: need to test
export const getServiceParams = (service) => {
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

const sortMapElements = (map) => {
  return Object.keys(map)
    .sort()
    .reduce(
      (acc, key) => ({
        ...acc,
        [key]: map[key],
      }),
      {}
    )
}

const getTopologyTags = (cfg, tags) => {
  const topo = { profiles: {}, totalCount: 0 }

  // loop over access prefixes
  Object.keys(cfg).forEach((profileKey) => {
    // remove xs: prefix
    const profileName = profileKey.split(":")[1] || profileKey
    if (!topo.profiles[profileName]) topo.profiles[profileName] = {}

    // loop over services in the access prefix
    Object.keys(cfg[profileKey]).forEach((serviceKey) => {
      const serviceParams = getServiceParams(serviceKey)
      // add service
      topo.profiles[profileName][serviceParams.name] = {
        description: cfg[profileKey][serviceKey]["description"],
        displayName: cfg[profileKey][serviceKey]["display_name"],
        tags: [],
      }

      // find tags with this access prefix
      tags.forEach((tag) => {
        const prefix = `${profileKey}:${serviceParams.name}`
        if (tag.startsWith(prefix)) {
          const value = tag.split(`${prefix}:`)[1] || null
          topo.profiles[profileName][serviceParams.name]["tags"].push({
            tag: tag,
            value: value,
          })
          topo.profiles[profileName][serviceParams.name]["tags"].push({
            tag: tag,
            value: `${value}2`,
          })
        }
      })

      // sort tags in the profile service by value
      topo.profiles[profileName][serviceParams.name]["tags"] = topo.profiles[
        profileName
      ][serviceParams.name]["tags"].sort((a, b) =>
        a.value.localeCompare(b.value)
      )

      // count tags
      topo.totalCount +=
        topo.profiles[profileName][serviceParams.name]["tags"].length
    })

    // sort sevices in the profile
    topo.profiles[profileName] = sortMapElements(topo.profiles[profileName])
  })

  // TODO: need to sort the profiles?

  console.log("topo: ", topo)

  return topo
}

const useTag = (cfg, tags) => {
  return React.useMemo(() => {
    if (!cfg) return null
    // check undefined input
    if (!tags) tags = []

    return getTopologyTags(cfg, tags)
  }, [JSON.stringify(tags), JSON.stringify(cfg)])
}

export default useTag
