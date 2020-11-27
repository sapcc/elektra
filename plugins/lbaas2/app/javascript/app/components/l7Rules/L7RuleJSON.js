import React, { useState, useEffect } from "react"
import useL7Rule from "../../../lib/hooks/useL7Rule"
import useCommons from "../../../lib/hooks/useCommons"
import Log from "../shared/logger"
import JsonView from "../shared/JsonView"

const L7RuleJSON = (props) => {
  const {
    fetchL7Rule
  } = useL7Rule()
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
  const [listenerID, setListenerID] = useState(null)
  const [l7policyID, setL7policyID] = useState(null)
  const [l7ruleID, setl7ruleID] = useState(null)

  useEffect(() => {
    // get the lb
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    const ltID = params.listenerID
    const l7pID = params.l7policyID
    const l7rID = params.l7ruleID
    setLoadbalancerID(lbID)
    setListenerID(ltID)
    setL7policyID(l7pID)
    setl7ruleID(l7rID)
  }, [])

  useEffect(() => {
    if (l7ruleID) {
      Log.debug("fetching L7Rule to show JSON")
      loadObject()
    }
  }, [l7ruleID])

  const loadObject = () => {
    setJsonObject({ ...jsonObject, isLoading: true,  error: null })
    fetchL7Rule(loadbalancerID, listenerID, l7policyID, l7ruleID)
      .then((data) => {
        setJsonObject({
          ...jsonObject,
          isLoading: false,
          item: data.l7rule,
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

  const title = "L7 Rule JSON"

  return (

    <JsonView show={show} close={close} restoreUrl={restoreUrl} title={title} jsonObject={jsonObject} loadObject={loadObject}/>

  )
}

export default L7RuleJSON