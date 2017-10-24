import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';

//################### SHARE_NETWORKS #########################
const requestShareNetworks= () => (
  {
    type: constants.REQUEST_SHARE_NETWORKS
  }
);

const requestShareNetworksFailure= () => (
  {
    type: constants.REQUEST_SHARE_NETWORKS_FAILURE
  }
);

const receiveShareNetworks= json =>
  ({
    type: constants.RECEIVE_SHARE_NETWORKS,
    shareNetworks: json,
    receivedAt: Date.now()
  })
;

const requestShareNetwork= shareNetworkId =>
  ({
    type: constants.REQUEST_SHARE_NETWORK,
    shareNetworkId
  })
;

const requestShareNetworkFailure= shareNetworkId =>
  ({
    type: constants.REQUEST_SHARE_NETWORK_FAILURE,
    shareNetworkId
  })
;

const receiveShareNetwork= json =>
  ({
    type: constants.RECEIVE_SHARE_NETWORK,
    shareNetwork: json
  })
;

const toggleShareNetworkIsNewStatus=(shareNetworkId,isNew) =>
  ({
    type: constants.TOGGLE_SHARE_NETWORK_IS_NEW_STATUS,
    id: shareNetworkId,
    isNew
  })
;

const fetchShareNetworks= () =>
  function(dispatch) {
    dispatch(requestShareNetworks());
    ajaxHelper.get('/share-networks')
      .then( (response) =>
        dispatch(receiveShareNetworks(response.data))
      )
      .catch( (error) => {
        console.log('error', error)
        dispatch(requestShareNetworksFailure());
        // dispatch(app.showErrorDialog({title: 'Could not load share networks', message:jqXHR.responseText}));
      })
  }
;

const shouldFetchShareNetworks= function(getState) {
  const shareNetworks = getState().shared_filesystem_storage.shareNetworks;
  if (shareNetworks.isFetching || shareNetworks.receivedAt) {
    return false;
  } else if (!shareNetworks.receivedAt) {
    return true;
  } else {
    return false;
  }
};

const fetchShareNetworksIfNeeded= () =>
  function(dispatch, getState) {
    if (shouldFetchShareNetworks(getState)) { return dispatch(fetchShareNetworks()); }
  }
;

const requestDelete=shareNetworkId =>
  ({
    type: constants.REQUEST_DELETE_SHARE_NETWORK,
    shareNetworkId
  })
;

const deleteShareNetworkFailure=shareNetworkId =>
  ({
    type: constants.DELETE_SHARE_NETWORK_FAILURE,
    shareNetworkId
  })
;

const removeShareNetwork=shareNetworkId =>
  ({
    type: constants.DELETE_SHARE_NETWORK_SUCCESS,
    shareNetworkId
  })
;


const deleteShareNetwork= shareNetworkId =>
  function(dispatch, getState) {
    dispatch(requestDelete(shareNetworkId));
    ajaxHelper.delete(`/share-networks/${shareNetworkId}`).then(response => {
      if (response.data && response.data.errors) {
        React.createElement(ErrorsList, {errors: response.data.errors})
      } else {
        return dispatch(removeShareNetwork(shareNetworkId));
      }
    }).catch(error => {
      showErrorModal(React.createElement(ErrorsList, {errors: error.message}));
    })
  }
;
//
//
// const openDeleteShareNetworkDialog=function(shareNetworkId, options) {
//   if (options == null) { options = {}; }
//   return function(dispatch, getState) {
//     const networkShares = [];
//     const { shares } = getState();
//     if (shares && shares.items) {
//       for (let s of Array.from(shares.items)) {
//         if (s.share_network_id===shareNetworkId) { networkShares.push(s); }
//       }
//     }
//
//     if (networkShares.length===0) {
//       return dispatch(app.showConfirmDialog({
//         message: options.message || 'Do you really want to delete this share network?' ,
//         confirmCallback() { return dispatch(deleteShareNetwork(shareNetworkId)); }
//       }));
//     } else {
//       return dispatch(app.showInfoDialog({title: 'Existing Dependencies', message: `Please delete dependent shares(${networkShares.length}) first!`}));
//     }
//   };
// };

//################ SHARSHARE_NETWORKE FORM ###################

const submitNewShareNetworkForm= (values, {handleSuccess,handleErrors}) =>
  function(dispatch, getState) {
    ajaxHelper.post(`/share-networks`, { share_network: values }).then(response => {
      if (response.data.errors) {
        handleErrors(response.data.errors);
      } else {
        dispatch(receiveShareNetwork(response.data));
        dispatch(toggleShareNetworkIsNewStatus(response.data.id,true))
        handleSuccess()
      }
    }).catch(error => {
      handleErrors(error.message)
    })
  }
;

//####################### NETWORKS ###########################
// Neutron Networks, Not Share Networks!!!
const shouldFetchNetworks= function(state) {
  const { networks } = state.shared_filesystem_storage;
  if (networks.isFetching || networks.receivedAt) {
    return false;
  } else if (!networks.items || !networks.items.length) {
    return true;
  } else {
    return false;
  }
};
const requestNetworks= () => ({type: constants.REQUEST_NETWORKS});

const requestNetworksFailure= () => ({type: constants.REQUEST_NETWORKS_FAILURE});

const receiveNetworks= json =>
  ({
    type: constants.RECEIVE_NETWORKS,
    networks: json,
    receivedAt: Date.now()
  })
;

const fetchNetworks=() =>
  function(dispatch) {
    dispatch(requestNetworks());
    return ajaxHelper.get('/share-networks/networks').then(({data}) => {
      return dispatch(receiveNetworks(data));
    }).catch( (error) => {
      return dispatch(requestNetworksFailure());
    })
  }
;

const fetchNetworksIfNeeded= () =>
  function(dispatch, getState) {
    if (shouldFetchNetworks(getState())) { return dispatch(fetchNetworks()); }
  }
;

//##################### NEUTRON SUBNETS ########################
const requestNetworkSubnets= networkId =>
  ({
    type: constants.REQUEST_SUBNETS,
    networkId
  })
;

const receiveNetworkSubnets= (networkId, json) =>
  ({
    type: constants.RECEIVE_SUBNETS,
    networkId,
    subnets: json,
    receivedAt: Date.now()
  })
;

const fetchNetworkSubnets= networkId =>
  function(dispatch) {
    dispatch(requestNetworkSubnets(networkId));
    ajaxHelper.get("/share-networks/subnets").then(response=>{
      dispatch(receiveNetworkSubnets(networkId,response.data))
    }).catch(error=>{
      dispatch(requestNetworkSubnetsFailure(networkId))
    })
  }
;

const shouldFetchNetworkSubnets= function(state, networkId) {
  const subnets = state.shared_filesystem_storage.subnets[networkId];
  if (!subnets) {
    return true;
  } else if (subnets.isFetching || subnets.receivedAt) {
    return false;
  } else {
    return false;
  }
};

const fetchNetworkSubnetsIfNeeded= networkId =>
  function(dispatch, getState) {
    if (shouldFetchNetworkSubnets(getState(), networkId)) { return dispatch(fetchNetworkSubnets(networkId)); }
  }
;

// export
export {
  fetchNetworksIfNeeded,
  fetchNetworkSubnetsIfNeeded,
  fetchShareNetworks,
  fetchShareNetworksIfNeeded,
  deleteShareNetwork,
  toggleShareNetworkIsNewStatus,
  submitNewShareNetworkForm
}
