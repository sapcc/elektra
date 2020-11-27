import React, { useState, useEffect } from "react"
import useHealthmonitor from "../../../lib/hooks/useHealthMonitor"
import useCommons from "../../../lib/hooks/useCommons"
import Log from "../shared/logger"
import JsonView from "../shared/JsonView"

const HealthmonitorJSON = (props) => {
  const {
    fetchHealthmonitor
  } = useHealthmonitor()
  const {
    matchParams,
    searchParamsToString
  } = useCommons()
  const [jsonObject, setJsonObject] = useState({
    isLoading: false,
    error: null,
    item: null,
  })
  const [loadbalancerID, setLoadbalancerID] = useState(null)
  const [poolID, setPoolID] = useState(null)
  const [healthmonitorID, setHealthmonitorID] = useState(null)

  useEffect(() => {
    // get the lb
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    const plID = params.poolID
    const hmID = params.healthmonitorID
    setLoadbalancerID(lbID)
    setPoolID(plID)
    setHealthmonitorID(hmID)
  }, [])

  useEffect(() => {
    if (poolID) {
      Log.debug("fetching Healthmonitor to show JSON")
      loadObject()
    }
  }, [poolID])

  const loadObject = () => {
    setJsonObject({ ...jsonObject, isLoading: true,  error: null })
    fetchHealthmonitor(loadbalancerID, poolID, healthmonitorID)
      .then((data) => {
        setJsonObject({
          ...jsonObject,
          isLoading: false,
          item: data.healthmonitor,
          error: null,
        })
        init_json_editor()
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
      // get the lb
      const params = matchParams(props)
      const lbID = params.loadbalancerID
      props.history.replace(
        `/loadbalancers/${lbID}/show?${searchParamsToString(props)}`
      )
    }
  }

  const title = "Health Monitor JSON"

  return (

    <JsonView show={show} close={close} restoreUrl={restoreUrl} title={title} jsonObject={jsonObject} loadObject={loadObject}/>

  )
}

export default HealthmonitorJSON