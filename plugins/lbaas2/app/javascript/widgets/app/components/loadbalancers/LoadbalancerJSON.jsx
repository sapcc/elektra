import React, { useState, useEffect } from "react"
import useLoadbalancer from "../../lib/hooks/useLoadbalancer"
import Log from "../shared/logger"
import { matchPath } from "react-router-dom"
import JsonView from "../shared/JsonView"
import {
  sortObjectByKeys,
  matchParams,
  searchParamsToString,
} from "../../helpers/commonHelpers"
import { fetchLoadbalancer } from "../../actions/loadbalancer"

const LoadbalancerJSON = (props) => {
  const [jsonObject, setJsonObject] = useState({
    isLoading: false,
    error: null,
    item: null,
  })
  const [loadbalancerID, setLoadbalancerID] = useState(null)

  useEffect(() => {
    Log.debug("fetching loadbalancer to show JSON")
    loadObject()
  }, [])

  const loadObject = () => {
    // get the lb
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    setLoadbalancerID(lbID)
    // fetch the loadbalancer to edit
    setJsonObject({ ...jsonObject, isLoading: true, error: null })
    fetchLoadbalancer(lbID)
      .then((data) => {
        setJsonObject({
          ...jsonObject,
          isLoading: false,
          item: sortObjectByKeys(data.loadbalancer),
          error: null,
        })
      })
      .catch((error) => {
        setJsonObject({ ...jsonObject, isLoading: false, error: error })
      })
  }

  /*
   * Modal stuff
   */
  const [show, setShow] = useState(true)

  const close = (e) => {
    if (e) e.stopPropagation()
    setShow(false)
  }

  const restoreUrl = () => {
    if (!show) {
      const isRequestFromDetails = matchPath(
        props.location.pathname,
        "/loadbalancers/:loadbalancerID/show/json"
      )
      if (isRequestFromDetails && isRequestFromDetails.isExact) {
        props.history.replace(
          `/loadbalancers/${loadbalancerID}/show?${searchParamsToString(props)}`
        )
      } else {
        props.history.replace("/loadbalancers")
      }
    }
  }

  const title = "Load Balancer JSON"

  return (
    <JsonView
      show={show}
      close={close}
      restoreUrl={restoreUrl}
      title={title}
      jsonObject={jsonObject}
      loadObject={loadObject}
    />
  )
}

export default LoadbalancerJSON
