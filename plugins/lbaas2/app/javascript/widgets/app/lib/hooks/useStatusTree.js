import { useEffect } from "react"
import { useDispatch } from "../../components/StateProvider"
import { ajaxHelper } from "lib/ajax_helper"
import Log from "../../components/shared/logger"

const useStatusTree = ({ lbId }) => {
  const dispatch = useDispatch()
  const errorMessage = (error) =>
    error.data?.errors || error.data?.error || error.message

  let polling = null

  useEffect(() => {
    startPolling()
    // Specify how to clean up after this effect:
    return function cleanup() {
      stopPolling()
    }
  })

  const startPolling = () => {
    Log.debug(
      "start status tree polling for id -->",
      lbId,
      " polling:",
      polling
    )
    // do not create a new polling interval if already polling
    if (polling) return
    polling = setInterval(() => reloadStatus(), 15000)
  }

  const stopPolling = () => {
    Log.debug("stop polling for id -->", lbId)
    clearInterval(polling)
    polling = null
  }

  const reloadStatus = () => {
    Log.debug("reload status tree for id -->", lbId)
    ajaxHelper
      .get(`/loadbalancers/` + lbId + `/status-tree`)
      .then((response) => {
        dispatch({
          type: "RECEIVE_LB_STATUS_TREE",
          lbId: lbId,
          tree: response.data.statuses,
        })
      })
      .catch((error) => {
        Log.debug("error loading status tree -->" + errorMessage(error))
        dispatch({
          type: "REQUEST_LB_STATUS_TREE_FAILURE",
          lbId: lbId,
          error: errorMessage(error),
        })
      })
  }
}

export default useStatusTree
