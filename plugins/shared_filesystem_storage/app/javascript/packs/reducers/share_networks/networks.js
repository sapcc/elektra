
import * as constants from '../../constants';

const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false
};

const requestNetworks=(state,{requestedAt}) =>
  Object.assign({},state,{isFetching: true, requestedAt});

const requestNetworksFailure=function(state){
  return Object.assign({},state,{isFetching: false});
};

const receiveNetworks=(state,{networks,receivedAt})=>
  Object.assign({},state,{
    isFetching: false,
    items: networks,
    receivedAt
  })
;

// networks reducer
export const networks = function(state, action) {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.RECEIVE_NETWORKS: return receiveNetworks(state,action);
    case constants.REQUEST_NETWORKS: return requestNetworks(state,action);
    case constants.REQUEST_NETWORKS_FAILURE: return requestNetworksFailure(state,action);
    default: return state;
  }
};
