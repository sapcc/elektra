import React, { useState, useEffect } from "react"
import useMember from "../../lib/hooks/useMember"
import useCommons from "../../lib/hooks/useCommons"
import Log from "../shared/logger"
import JsonView from "../shared/JsonView"

const MemberJSON = (props) => {
  const { fetchMember } = useMember()
  const { matchParams, searchParamsToString, sortObjectByKeys } = useCommons()
  const [jsonObject, setJsonObject] = useState({
    isLoading: false,
    error: null,
    item: null,
  })
  const [loadbalancerID, setLoadbalancerID] = useState(null)
  const [poolID, setPoolID] = useState(null)
  const [memberID, setMemberID] = useState(null)

  useEffect(() => {
    // get the lb
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    const plID = params.poolID
    const mID = params.memberID
    setLoadbalancerID(lbID)
    setPoolID(plID)
    setMemberID(mID)
  }, [])

  useEffect(() => {
    if (memberID) {
      Log.debug("fetching member to show JSON")
      loadObject()
    }
  }, [memberID])

  const loadObject = () => {
    setJsonObject({ ...jsonObject, isLoading: true, error: null })
    fetchMember(loadbalancerID, poolID, memberID)
      .then((data) => {
        setJsonObject({
          ...jsonObject,
          isLoading: false,
          item: sortObjectByKeys(data.member),
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

  const title = "Member JSON"

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

export default MemberJSON
