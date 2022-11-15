import React from "react"

export const findLoadbalancer = (loadbalancers, lbID) => {
  if (loadbalancers) {
    const index = loadbalancers.findIndex((item) => item.id == lbID)
    if (index >= 0) {
      return loadbalancers[index]
    }
  }
  return null
}
