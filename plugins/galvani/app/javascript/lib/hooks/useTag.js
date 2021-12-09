import React from "react"

const getTopologyTags = (cfg, tags) => {
  console.log("tags: ", tags, " cfg: ", cfg)

  // predefined access profiles
  const profiles = Object.keys(cfg)
  console.log(profiles)
  return null
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
