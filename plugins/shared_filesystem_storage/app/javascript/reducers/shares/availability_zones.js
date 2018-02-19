import * as constants from '../../constants';

//########################## SHARES ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false
};

const requestAvailableZones=(state,{requestedAt})=>
  Object.assign({},state,{isFetching: true, requestedAt});

const requestAvailableZonesFailure=function(state,...rest){
  return Object.assign({},state,{isFetching: false});
};

const receiveAvailableZones=(state,{availabilityZones,receivedAt})=>
  Object.assign({},state,{
    isFetching: false,
    items: availabilityZones,
    receivedAt
  })
;

// networks reducer
export const availabilityZones = function(state, action) {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.RECEIVE_AVAILABLE_ZONES: return receiveAvailableZones(state,action);
    case constants.REQUEST_AVAILABLE_ZONES: return requestAvailableZones(state,action);
    case constants.REQUEST_AVAILABLE_ZONES_FAILURE: return requestAvailableZonesFailure(state,action);
    default: return state;
  }
};
