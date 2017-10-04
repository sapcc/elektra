import * as constants from '../constants';
import axios from 'axios'

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
    axios.get('share-networks')
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

const count = 0;
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

const showDeleteShareNetworkError=(shareNetworkId,message)=>
  function(dispatch) {
    dispatch(deleteShareNetworkFailure(shareNetworkId));
    return dispatch(app.showErrorDialog({title: 'Could not delete share network', message}));
  }
;

const deleteShareNetwork= shareNetworkId =>
  function(dispatch, getState) {
    dispatch(requestDelete(shareNetworkId));
    return app.ajaxHelper.delete(`/share-networks/${shareNetworkId}`, {
      success(data, textStatus, jqXHR) {
        if (data && data.errors) {
          return dispatch(showDeleteShareNetworkError(shareNetworkId,ReactFormHelpers.Errors(data)));
        } else {
          return dispatch(removeShareNetwork(shareNetworkId));
        }
      },
      error( jqXHR, textStatus, errorThrown) {
        return dispatch(showDeleteShareNetworkError(shareNetworkId,jqXHR.responseText));
      }
    }
    );
  }
;


const openDeleteShareNetworkDialog=function(shareNetworkId, options) {
  if (options == null) { options = {}; }
  return function(dispatch, getState) {
    const networkShares = [];
    const { shares } = getState();
    if (shares && shares.items) {
      for (let s of Array.from(shares.items)) {
        if (s.share_network_id===shareNetworkId) { networkShares.push(s); }
      }
    }

    if (networkShares.length===0) {
      return dispatch(app.showConfirmDialog({
        message: options.message || 'Do you really want to delete this share network?' ,
        confirmCallback() { return dispatch(deleteShareNetwork(shareNetworkId)); }
      }));
    } else {
      return dispatch(app.showInfoDialog({title: 'Existing Dependencies', message: `Please delete dependent shares(${networkShares.length}) first!`}));
    }
  };
};

const openNewShareNetworkDialog=()=>
  function(dispatch) {
    dispatch(shareNetworkFormForCreate());
    return dispatch(newShareNetworkModal());
  }
;

const openEditShareNetworkDialog=shareNetwork=>
  function(dispatch) {
    dispatch(shareNetworkFormForUpdate(shareNetwork));
    return dispatch(editShareNetworkModal());
  }
;

//################ SHARSHARE_NETWORKE FORM ###################
const resetShareNetworkForm=()=> ({type: constants.RESET_SHARE_NETWORK_FORM});

var shareNetworkFormForCreate=()=>
  ({
    type: constants.PREPARE_SHARE_NETWORK_FORM,
    method: 'post',
    action: "/share-networks"
  })
;

var shareNetworkFormForUpdate=shareNetwork =>
  ({
    type: constants.PREPARE_SHARE_NETWORK_FORM,
    data: shareNetwork,
    method: 'put',
    action: `/share-networks/${shareNetwork.id}`
  })
;

const shareNetworkFormFailure=errors =>
  ({
    type: constants.SHARE_NETWORK_FORM_FAILURE,
    errors
  })
;

const updateShareNetworkForm= (name,value) =>
  ({
    type: constants.UPDATE_SHARE_NETWORK_FORM,
    name,
    value
  })
;

const submitShareNetworkForm= (successCallback=null) =>
  function(dispatch, getState) {
    const { shareNetworkForm } = getState();
    if (shareNetworkForm.isValid) {
      dispatch({type: app.SUBMIT_SHARE_NETWORK_FORM});
      return app.ajaxHelper[shareNetworkForm.method](shareNetworkForm.action, {
        data: { share_network: shareNetworkForm.data },
        success(data, textStatus, jqXHR) {
          if (data.errors) {
            return dispatch(shareNetworkFormFailure(data.errors));
          } else {
            dispatch(receiveShareNetwork(data));
            if (shareNetworkForm.method==='post') { dispatch(toggleShareNetworkIsNewStatus(data.id,true)); }
            dispatch(resetShareNetworkForm());
            if (successCallback) { return successCallback(); }
          }
        },
        error( jqXHR, textStatus, errorThrown) {
          return dispatch(app.showErrorDialog({title: 'Could not save share network', message:jqXHR.responseText}));
        }
      }
      );
    }
  }
;

//####################### NETWORKS ###########################
// Neutron Networks, Not Share Networks!!!
const shouldFetchNetworks= function(state) {
  const { networks } = state;
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
    return app.ajaxHelper.get('/share-networks/networks', {
      success(data, textStatus, jqXHR) {
        return dispatch(receiveNetworks(data));
      },
      error( jqXHR, textStatus, errorThrown) {
        return dispatch(requestNetworksFailure());
      }
    }
    );
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
    return app.ajaxHelper.get("/share-networks/subnets", {
      data: {network_id: networkId},
      success(data, textStatus, jqXHR) {
        return dispatch(receiveNetworkSubnets(networkId,data));
      },
      error( jqXHR, textStatus, errorThrown) {
        return dispatch(requestNetworkSubnetsFailure(networkId));
      }
    }
    );
  }
;

const shouldFetchNetworkSubnets= function(state, networkId) {
  const subnets = state.subnets[networkId];
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

  shareNetworkFormForCreate,
  shareNetworkFormForUpdate,
  submitShareNetworkForm,
  updateShareNetworkForm,
  toggleShareNetworkIsNewStatus,
}
