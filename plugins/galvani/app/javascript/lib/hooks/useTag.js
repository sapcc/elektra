import React from "react"

export const BASE_PREFIX = "xs"

// remove service params from the key
// Ex
// dns_reader --> name: dns_reader, hasVars: false
// dns_edit_zone:$1 --> name: dns_edit_zone, hasVars: true
// TODO: need to test
export const getServiceParams = (service) => {
  const newService = service || ""
  const params = newService.split(":") || []
  let name = params[0] || ""
  let hasVars = false
  let vars = []
  // check for attr
  if (params.length > 0) {
    const attrs = params.slice(1)
    attrs.forEach((attr) => {
      if (attr.includes("$")) {
        hasVars = true
        vars.push(attr)
      }
    })
  }
  return { key: newService, name: name, hasVars: hasVars, vars: vars }
}

export const composeTag = ({ profile, service, attrs }) => {
  let tag = `${BASE_PREFIX}:${profile}:${service.value}`
  Object.keys(attrs).forEach((key) => {
    tag = `${tag}:${attrs[key]}`
  })
  return tag
}

// use the config to find the description of the attr to validate
export const validateForm = (cfg, { profile, service, attrs }) => {
  const invalidItems = {}

  // find the profileKey with the root prefix 'xs'
  const foundProfileKey = Object.keys(cfg).find((i) => i.includes(profile))

  // service vars are the variables extracted with getServiceParams
  if (service.vars.length > 0) {
    service.vars.forEach((varKey) => {
      // check if var exist as attr given from the inputs
      if (!attrs[varKey] || attrs[varKey].length === 0) {
        if (!invalidItems[varKey]) invalidItems[varKey] = []
        invalidItems[varKey].push(`Attribute can't be blank`)
      }
      // max attrs length: 50 for prefixes and the rest for attr.
      // xs:internet:keppel_account_push: --> 32 chars
      // keystone tag max length --> 255
      if (attrs[varKey] && attrs[varKey].length > 200) {
        if (!invalidItems[varKey]) invalidItems[varKey] = []
        invalidItems[varKey].push(`Attribute is too long. Max 200 chars.`)
      }
    })
  } else {
    const numbAttrs = Object.keys(attrs) || []
    // check for non attribute
    if (numbAttrs && numbAttrs.length > 0) {
      if (!invalidItems["attr"]) invalidItems["attr"] = []
      invalidItems["attr"].push(
        `Attributes ${JSON.stringify(numbAttrs)} not allowed`
      )
    }
  }

  return invalidItems
}

export const errorMessage = (error) => {
  const err = error.response || error
  if (
    err &&
    err.data &&
    err.data.errors &&
    Object.keys(err.data.errors).length
  ) {
    return err.data.errors
  } else {
    return error.message
  }
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
