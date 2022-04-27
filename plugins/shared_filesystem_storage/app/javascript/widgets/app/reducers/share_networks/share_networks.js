import * as constants from '../../constants';

//########################## SHARE_NETWORKS ##############################
const initialShareNetworksState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false
};

const toggleShareNetworkIsNewStatus=function(state,{id,isNew}) {
  const index = state.items.findIndex((item) => item.id==id );
  if (index<0) { return state; }

  const items = state.items.slice();
  items[index].isNew = isNew;
  return Object.assign({},state,{items});
};

const requestShareNetworks=function(state,{requestedAt}){
  return Object.assign({},state,{isFetching: true, requestedAt});
};

const requestShareNetworksFailure=function(state){
  return Object.assign({},state,{isFetching: false});
};

const receiveShareNetworks=(state,{shareNetworks,receivedAt})=>
  Object.assign({},state,{
    isFetching: false,
    receivedAt,
    items: shareNetworks
  })
;

const requestShareNetwork= function(state,{shareNetworkId}) {
  const index = state.items.findIndex((item) => item.id==shareNetworkId );
  if (index<0) { return state; }

  const items = state.items.slice();
  items[index].isFetching = true;
  return Object.assign({},state,{items});
};

const requestShareNetworkFailure=function(state,{shareNetworkId}){
  const index = state.items.findIndex((item) => item.id==shareNetworkId );
  if (index<0) { return state; }

  const items = state.items.slice();
  items[index].isFetching = false;
  return Object.assign({},state,{items});
};

const receiveShareNetwork= function(state,{shareNetwork}) {
  const index = state.items.findIndex((item) => item.id==shareNetwork.id );
  const items = state.items.slice();
  // update or add
  if (index>=0) { items[index]=shareNetwork; } else { items.push(shareNetwork); }
  return Object.assign({},state,{items});
};

const requestDeleteShareNetwork= function(state,{shareNetworkId}) {
  const index = state.items.findIndex((item) => item.id==shareNetworkId );
  if (index<0) { return state; }

  const items = state.items.slice();
  items[index].isDeleting = true;
  return Object.assign({},state,{items});
};

const deleteShareNetworkFailure= function(state,{shareNetworkId}) {
  const index = state.items.findIndex((item) => item.id==shareNetworkId );
  if (index<0) { return state; }
  const items = state.items.slice();
  items[index].isDeleting=false;
  return Object.assign({},state,{items});
};

const deleteShareNetworkSuccess= function(state,{shareNetworkId}) {
  const index = state.items.findIndex((item) => item.id==shareNetworkId );
  if (index<0) { return state; }
  const items = state.items.slice();
  items.splice(index,1);
  return Object.assign({},state,{items});
};

// shareNetworks reducer
export const shareNetworks = function(state, action) {
  if (state == null) { state = initialShareNetworksState; }
  switch (action.type) {
    case constants.RECEIVE_SHARE_NETWORKS: return receiveShareNetworks(state,action);
    case constants.REQUEST_SHARE_NETWORKS: return requestShareNetworks(state,action);
    case constants.REQUEST_SHARE_NETWORKS_FAILURE: return requestShareNetworksFailure(state,action);
    case constants.REQUEST_SHARE_NETWORK: return requestShareNetwork(state,action);
    case constants.REQUEST_SHARE_NETWORK_FAILURE: return requestShareNetworkFailure(state,action);
    case constants.RECEIVE_SHARE_NETWORK: return receiveShareNetwork(state,action);
    case constants.REQUEST_DELETE_SHARE_NETWORK: return requestDeleteShareNetwork(state,action);
    case constants.DELETE_SHARE_NETWORK_FAILURE: return deleteShareNetworkFailure(state,action);
    case constants.DELETE_SHARE_NETWORK_SUCCESS: return deleteShareNetworkSuccess(state,action);
    case constants.TOGGLE_SHARE_NETWORK_IS_NEW_STATUS: return toggleShareNetworkIsNewStatus(state,action);
    default: return state;
  }
};
