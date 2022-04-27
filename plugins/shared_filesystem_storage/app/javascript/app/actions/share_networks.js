import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';
import { confirm } from 'lib/dialogs';
import { addNotice, addError  } from 'lib/flashes';
import { ErrorsList } from 'lib/elektra-form';

//################### SHARE_NETWORKS #########################
const requestShareNetworks= () => (
  {
    type: constants.REQUEST_SHARE_NETWORKS,
    requestedAt: Date.now(),
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
        dispatch(requestShareNetworksFailure());
        addError(React.createElement(ErrorsList, {errors: error.message}));
      })
  }
;

const shouldFetchShareNetworks= function(getState) {
  const shareNetworks = getState().shareNetworks;
  if (!shareNetworks.isFetching && !shareNetworks.requestedAt) {
    return true;
  }
  return false
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
    const networkShares = [];
    const state = getState();
    if (state.shares && state.shares.items) {
      for (let s of state.shares.items) {
        if (s.share_network_id===shareNetworkId) { networkShares.push(s); }
      }
    }

    if (networkShares.length>0) {
      addNotice(`Please delete dependent shares(${networkShares.length}) first!`)
      return
    }
    confirm('Do you really want to delete this share network?').then(() => {
      dispatch(requestDelete(shareNetworkId));
      ajaxHelper.delete(`/share-networks/${shareNetworkId}`).then(response => {
        if (response.data && response.data.errors) {
          addError(React.createElement(ErrorsList, {errors: response.data.errors}))
          dispatch(deleteShareNetworkFailure(shareNetworkId))
        } else {
          return dispatch(removeShareNetwork(shareNetworkId));
        }
      }).catch(error => {
        addError(React.createElement(ErrorsList, {errors: error.message}));
      })
    }).catch((aborted) => null)
  }
;


//################ SHARSHARE_NETWORKE FORM ###################

const submitNewShareNetworkForm= (values) =>
  (dispatch, getState) =>
    new Promise((handleSuccess,handleErrors) => {
      ajaxHelper.post(`/share-networks`, { share_network: values }).then(response => {
        if (response.data.errors) handleErrors({errors: response.data.errors})
        else {
          dispatch(receiveShareNetwork(response.data));
          dispatch(toggleShareNetworkIsNewStatus(response.data.id,true))
          handleSuccess()
        }
      }).catch(error => handleErrors({errors: error.message}))
    })
;

const submitEditShareNetworkForm= (values) =>
  (dispatch, getState) =>
    new Promise((handleSuccess,handleErrors) => {
      ajaxHelper.put(
        `/share-networks/${values.id}`,
        { share_network: values }
      ).then(response => {
        if (response.data.errors) handleErrors({errors: response.data.errors})
        else {
          dispatch(receiveShareNetwork(response.data));
          handleSuccess()
        }
      }).catch(error => handleErrors({errors: error.message}))
    })
;

//####################### NETWORKS ###########################
// Neutron Networks, Not Share Networks!!!
const shouldFetchNetworks= function(state) {
  const { networks } = state;
  if (!networks.isFetching && !networks.requestedAt) return true
  return false
};
const requestNetworks= () => ({
  type: constants.REQUEST_NETWORKS,
  requestedAt: Date.now()
});

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
    return ajaxHelper.get('/share-networks/networks').then(response => {
      return dispatch(receiveNetworks(response.data));
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
    requestedAt: Date.now(),
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

const requestNetworkSubnetsFailure= (networkId) => ({
  type: constants.REQUEST_SUBNETS_FAILURE,
  networkId
});

const fetchNetworkSubnets= networkId =>
  function(dispatch) {
    dispatch(requestNetworkSubnets(networkId));
    ajaxHelper.get("/share-networks/subnets", {
      params: {network_id: networkId}
    }).then(response=>{
      dispatch(receiveNetworkSubnets(networkId,response.data))
    }).catch(error=>{
      dispatch(requestNetworkSubnetsFailure(networkId))
    })
  }
;

const shouldFetchNetworkSubnets= function(state, networkId) {
  if (!networkId) return false
  const subnets = state.subnets;

  return (!subnets[networkId] || (!subnets[networkId].isFetching && !subnets[networkId].requestedAt))
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
  submitNewShareNetworkForm,
  submitEditShareNetworkForm
}
