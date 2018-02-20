import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';
import { kubernikusAjaxHelper } from '../kubernikus_ajax_helper';
import { confirm } from 'lib/dialogs';
import { addNotice, addError } from 'lib/flashes';

import { ErrorsList } from 'lib/elektra-form/components/errors_list';


//################### CLUSTER LIST ACTIONS #########################

const requestClusters= () =>
  ({
    type: constants.REQUEST_CLUSTERS,
    requestedAt: Date.now()
  })
;

const requestClustersFailure= (error) =>
  ({
    type: constants.REQUEST_CLUSTERS_FAILURE,
    error: error
  })
;

const receiveClusters= (items) =>
  ({
    type: constants.RECEIVE_CLUSTERS,
    clusters: items,
    receivedAt: Date.now()
  })
;


const fetchClusters= () =>
  function(dispatch,getState) {
    dispatch(requestClusters());

    return kubernikusAjaxHelper.get('/api/v1/clusters').then( (response) => {
      if (response.data.errors) {
        addError(React.createElement(ErrorsList, {errors: response.data.errors}))
      } else {
        dispatch(receiveClusters(response.data));
      }
    })
    .catch( (error) => {
      dispatch(requestClustersFailure());
      addError(`Could not load clusters (${error.message})`)
    });
  }
;


  // loadClusters = () ->
  //   (dispatch, getState) ->
  //     currentState    = getState()
  //     clusters        = currentState.clusters
  //     isFetching      = clusters.isFetching
  //
  //
  //     return if isFetching # don't fetch if we're already fetching
  //     dispatch(requestClusters())
  //
  //     app.ajaxHelper.get '/api/v1/clusters',
  //       contentType: 'application/json'
  //       success: (data, textStatus, jqXHR) ->
  //         dispatch(receiveClusters(data))
  //       error: ( jqXHR, textStatus, errorThrown) ->
  //         errorMessage =  if typeof jqXHR.responseJSON == 'object'
  //                           jqXHR.responseJSON.message
  //                         else
  //                           if jqXHR.responseText.length > 0
  //                             jqXHR.responseText
  //                           else
  //                             "The backend is currently slow to respond. Please try again later. We are on it."
  //
  //
  //         dispatch(requestClustersFailure(errorMessage))




// const shouldFetchShares= function(state) {
//   const { shares } = state.shared_filesystem_storage;
//   if (shares.isFetching || shares.requestedAt) {
//     return false;
//   } else {
//     return true;
//   }
// };
//
// const fetchSharesIfNeeded= () =>
//   function(dispatch, getState) {
//     if (shouldFetchShares(getState())) { return dispatch(fetchShares()); }
//   }
// ;
//
//
//
// const requestDelete=shareId =>
//   ({
//     type: constants.REQUEST_DELETE_SHARE,
//     shareId
//   })
// ;
//
// const deleteShareFailure=shareId =>
//   ({
//     type: constants.DELETE_SHARE_FAILURE,
//     shareId
//   })
// ;
//
// const removeShare=shareId =>
//   ({
//     type: constants.DELETE_SHARE_SUCCESS,
//     shareId
//   })
// ;
//
// const deleteShare= shareId =>
//   function(dispatch, getState) {
//     const shareSnapshots = [];
//     // check if there are dependent snapshots.
//     // Problem: the snapshots may not be loaded yet
//     const { snapshots } = getState().shared_filesystem_storage;
//     if (snapshots && snapshots.items) {
//       for (let snapshot of snapshots.items) {
//         if (snapshot.share_id===shareId) { shareSnapshots.push(snapshot); }
//       }
//     }
//
//     if (shareSnapshots.length > 0) {
//       return addNotice(`Share still has ${shareSnapshots.length} dependent snapshots. Please remove dependent snapshots first.`)
//     }
//
//     confirm(`Do you really want to delete the share ${shareId}?`).then(() => {
//       dispatch(requestDelete(shareId));
//       ajaxHelper.delete(`/shares/${shareId}`).then((response) => {
//         if (response.data && response.data.errors) {
//           addError(React.createElement(ErrorsList, {errors: response.data.errors}));
//           dispatch(deleteShareFailure(shareId))
//         } else {
//           dispatch(removeShare(shareId));
//           dispatch(removeShareRules(shareId));
//         }
//       }).catch((error) => {
//         dispatch(deleteShareFailure(shareId))
//         addError(React.createElement(ErrorsList, {errors: error.message}));
//       })
//     }).catch((aborted) => null)
//   }
// ;



export {
  fetchClusters
}
