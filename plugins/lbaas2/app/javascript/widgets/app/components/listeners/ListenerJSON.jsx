import React, { useState, useEffect } from "react"
import useListener from "../../lib/hooks/useListener"
import useCommons from "../../lib/hooks/useCommons"
import Log from "../shared/logger"
import JsonView from "../shared/JsonView"

const ListenerJSON = (props) => {
  const { fetchListener } = useListener()
  const { matchParams, searchParamsToString, sortObjectByKeys } = useCommons()
  const [jsonObject, setJsonObject] = useState({
    isLoading: false,
    error: null,
    item: null,
  })
  const [loadbalancerID, setLoadbalancerID] = useState(null)
  const [listenerID, setListenerID] = useState(null)

  useEffect(() => {
    // get the lb
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    const ltID = params.listenerID
    setLoadbalancerID(lbID)
    setListenerID(ltID)
  }, [])

  useEffect(() => {
    if (listenerID) {
      Log.debug("fetching listener to show JSON")
      loadObject()
    }
  }, [listenerID])

  const loadObject = () => {
    setJsonObject({ ...jsonObject, isLoading: true, error: null })
    fetchListener(loadbalancerID, listenerID)
      .then((data) => {
        setJsonObject({
          ...jsonObject,
          isLoading: false,
          item: sortObjectByKeys(data.listener),
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

  const title = "Listener JSON"

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

export default ListenerJSON
