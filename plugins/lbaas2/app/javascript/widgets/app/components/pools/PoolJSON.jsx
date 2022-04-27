import React, { useState, useEffect } from "react"
import usePool from "../../lib/hooks/usePool"
import useCommons from "../../lib/hooks/useCommons"
import Log from "../shared/logger"
import JsonView from "../shared/JsonView"

const PoolJSON = (props) => {
  const { fetchPool } = usePool()
  const { matchParams, searchParamsToString, sortObjectByKeys } = useCommons()
  const [jsonObject, setJsonObject] = useState({
    isLoading: false,
    error: null,
    item: null,
  })
  const [loadbalancerID, setLoadbalancerID] = useState(null)
  const [poolID, setPoolID] = useState(null)

  useEffect(() => {
    // get the lb
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    const plID = params.poolID
    setLoadbalancerID(lbID)
    setPoolID(plID)
  }, [])

  useEffect(() => {
    if (poolID) {
      Log.debug("fetching listener to show JSON")
      loadObject()
    }
  }, [poolID])

  const loadObject = () => {
    setJsonObject({ ...jsonObject, isLoading: true, error: null })
    fetchPool(loadbalancerID, poolID)
      .then((data) => {
        setJsonObject({
          ...jsonObject,
          isLoading: false,
          item: sortObjectByKeys(data.pool),
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
      // get the lb
      const params = matchParams(props)
      const lbID = params.loadbalancerID
      props.history.replace(
        `/loadbalancers/${lbID}/show?${searchParamsToString(props)}`
      )
    }
  }

  const title = "Pool JSON"

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

export default PoolJSON
