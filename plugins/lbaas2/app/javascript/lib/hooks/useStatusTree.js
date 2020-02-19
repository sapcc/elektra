import { useEffect } from 'react'
import { useDispatch } from '../../app/components/StateProvider'
import { ajaxHelper } from 'ajax_helper';

const useStatusTree = ({lbId}) => {
  const dispatch = useDispatch()
  const errorMessage = (error) =>
    error.response && error.response.data && (error.response.data.errors || error.response.data.error) ||
    error.message

    let polling = null

    useEffect(() => {
      startPolling()
      // Specify how to clean up after this effect:
      return function cleanup() {
        stopPolling()
      };
    });
  
    const startPolling = () => {   
      console.log("start polling for id -->", lbId, " polling:",polling)
      // do not create a new polling interval if already polling
      if(polling) return;
      polling = setInterval(() =>
        reloadStatus(), 5000
      )
    }
  
    const stopPolling = () => {
      clearInterval(polling)
      polling = null
    }
  
    const reloadStatus = () => {
      console.log("reload status for id -->", lbId)
      dispatch({type: 'REQUEST_LB_STATUS_TREE', lbId: lbId })
      ajaxHelper.get(`/loadbalancers/` +lbId + `/status-tree`).then((response) => {
        dispatch({type: 'RECEIVE_LB_STATUS_TREE',  lbId: lbId, tree: response.data.statuses})
      })
      .catch( (error) => {
        console.log("error loading status tree -->" + error.response.data.error)
        dispatch({type: 'REQUEST_LB_STATUS_TREE_FAILURE', lbId: lbId, error: errorMessage(error)})
      })
    }
}

export default useStatusTree