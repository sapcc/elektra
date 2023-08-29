import { pluginAjaxHelper } from "lib/ajax_helper"

import { Scope, getBaseURL } from "../scope"

// the global `ajaxHelper` is set up in init.js to talk to the Limes API, so we
// need a separate AJAX helper for talking to Elektra
const ajaxHelper = pluginAjaxHelper("resources", {
  //TODO FIXME: pluginAjaxHelper() does not recognize domain scope correctly
  baseURL: getBaseURL(),
  headers: {
    "X-Requested-With": "XMLHttpRequest",
    //TODO FIXME: not sure why this is necessary, pluginAjaxHelper() should insert it automagically
    "X-CSRF-Token": [...document.querySelectorAll("meta")].find(
      (n) => n.name.toLowerCase() == "csrf-token"
    ).content,
  },
})

const elektraErrorMessage = (error) => error.data?.errors || error.message

export const sendQuotaRequest = (scopeData, requestBody) => {
  const scope = new Scope(scopeData)

  return new Promise((resolve, reject) =>
    ajaxHelper
      .post(`/request/${scope.level()}`, requestBody)
      .then((response) => {
        if (response.data?.errors) {
          reject(response.data?.errors)
        } else {
          resolve(response.data)
        }
      })
      .catch((error) => reject({ errors: elektraErrorMessage(error) }))
  )
}

export const getBigvmResources = () => {
  return new Promise((resolve, reject) =>
    ajaxHelper
      .get(`/project/bigvm_resources`)
      .then((response) => {
        if (response.data?.errors) {
          reject(response.data?.errors)
        } else {
          let availabilityZones =
            response.data?.placeable_vms?.result_per_availability_zone
          if (!availabilityZones) {
            resolve([])
          } else {
            const result = Object.keys(availabilityZones)
              .sort()
              .map((az) => {
                const entry = { availabilityZone: az, flavors: [] }
                const flavors = availabilityZones[az]?.placeable_vms
                if (!flavors) {
                  return entry
                }
                Object.keys(flavors)
                  .sort()
                  .forEach((fname) => {
                    if (fname.startsWith("hana_") && flavors[fname] > 0) {
                      entry.flavors.push({ [fname]: flavors[fname] })
                    }
                  })
                return entry
              })
            resolve(result)
          }
        }
      })
      .catch((error) => reject({ errors: elektraErrorMessage(error) }))
  )
}
