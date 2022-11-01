import React, { useState, useEffect } from "react"
import useL7Policy from "../../lib/hooks/useL7Policy"
import Log from "../shared/logger"
import JsonView from "../shared/JsonView"
import {
  sortObjectByKeys,
  matchParams,
  searchParamsToString,
} from "../../helpers/commonHelpers"

const L7PolicyJSON = (props) => {
  const { fetchL7Policy } = useL7Policy()

  const [jsonObject, setJsonObject] = useState({
    isLoading: false,
    error: null,
    item: null,
  })
  const [loadbalancerID, setLoadbalancerID] = useState(null)
  const [listenerID, setListenerID] = useState(null)
  const [l7policyID, setL7policyID] = useState(null)

  useEffect(() => {
    // get the lb
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    const ltID = params.listenerID
    const l7pID = params.l7policyID
    setLoadbalancerID(lbID)
    setListenerID(ltID)
    setL7policyID(l7pID)
  }, [])

  useEffect(() => {
    if (l7policyID) {
      Log.debug("fetching L7Policy to show JSON")
      loadObject()
    }
  }, [l7policyID])

  const loadObject = () => {
    setJsonObject({ ...jsonObject, isLoading: true, error: null })
    fetchL7Policy(loadbalancerID, listenerID, l7policyID)
      .then((data) => {
        setJsonObject({
          ...jsonObject,
          isLoading: false,
          item: sortObjectByKeys(data.l7policy),
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

  const title = "L7 Policy JSON"

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

export default L7PolicyJSON
