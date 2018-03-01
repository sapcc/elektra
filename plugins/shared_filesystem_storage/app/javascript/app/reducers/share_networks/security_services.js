import * as constants from '../../constants';

const requestShareNetworkSecurityServices=function(state,{shareNetworkId}){
  const newState = Object.assign({},state);
  const shareNetworkSecurityServices = newState[shareNetworkId] || initialState;

  newState[shareNetworkId] = Object.assign({},shareNetworkSecurityServices,{isFetching:true});
  return newState;
};

const receiveShareNetworkSecurityServices=function(state,{shareNetworkId,receivedAt,securityServices}){
  const newState = Object.assign({},state);
  const shareNetworkSecurityServices = newState[shareNetworkId] || initialState;

  newState[shareNetworkId] = Object.assign({},shareNetworkSecurityServices,{
    isFetching: false,
    receivedAt,
    items: securityServices
  });
  return newState;
};

const receiveShareNetworkSecurityService=function(state,{shareNetworkId,securityService}){
  // return old state unless shareNetworkSecurityServices entry exists
  if (!state[shareNetworkId]) {
    return receiveShareNetworkSecurityServices(state,{shareNetworkId,securityServices: [securityService]});
  }

  // copy current shareNetworkSecurityServices
  const shareNetworkSecurityServices = Object.assign({},state[shareNetworkId]);
  const index = shareNetworkSecurityServices.items.findIndex(i => i.id==securityService.id);
  const items = shareNetworkSecurityServices.items.slice();

  if (index>=0) {
    items[index] = securityService;
  } else {
    items.push(securityService);
  }
  shareNetworkSecurityServices.items = items

  // return new state (copy old state with new shareNetworkSecurityServices)
  return Object.assign({},state,{[shareNetworkId]: shareNetworkSecurityServices});
};


const requestDeleteShareNetworkSecurityService=function(state,{shareNetworkId,securityServiceId}){
  // return old state unless shareNetworkSecurityServices entry exists
  if (!state[shareNetworkId] || !state[shareNetworkId].items) { return state; }
  const index = state[shareNetworkId].items.findIndex(i => i.id==securityServiceId);
  if (index<0) { return state; }

  // copy current shareNetworkSecurityServices
  const shareNetworkSecurityServices = Object.assign({},state[shareNetworkId]);
  const items = shareNetworkSecurityServices.items.slice();

  // mark as deleting
  items[index].isDeleting=true;
  shareNetworkSecurityServices.items = items
  // return new state (copy old state with new shareNetworkSecurityServices)
  return Object.assign({},state,{[shareNetworkId]: shareNetworkSecurityServices});
};

const deleteShareNetworkSecurityServiceFailure=function(state,{shareNetworkId,securityServiceId}){
  // return old state unless shareNetworkSecurityServices entry exists
  if (!state[shareNetworkId] || !state[shareNetworkId].items) { return state; }
  const index = state[shareNetworkId].items.findIndex(i => i.id==securityServiceId);
  if (index<0) { return state; }

  // copy current shareNetworkSecurityServices
  const shareNetworkSecurityServices = Object.assign({},state[shareNetworkId]);
  // reset isDeleting flag
  shareNetworkSecurityServices.isDeleting=false;
  // return new state (copy old state with new shareNetworkSecurityServices)
  return Object.assign({},state,{[shareNetworkId]: shareNetworkSecurityServices});
};

const deleteShareNetworkSecurityServiceSuccess=function(state,{shareNetworkId,securityServiceId}){
  // return old state unless shareNetworkSecurityServices entry exists
  if (!state[shareNetworkId] || !state[shareNetworkId].items) { return state; }
  const index = state[shareNetworkId].items.findIndex(i=> i.id==securityServiceId);
  if (index<0) { return state; }

  // copy current shareNetworkSecurityServices
  const shareNetworkSecurityServices = Object.assign({},state[shareNetworkId]);
  // delete shareNetworkSecurityService item
  shareNetworkSecurityServices.items.splice(index,1);
  // return new state (copy old state with new shareNetworkSecurityServices)
  return Object.assign({},state,{[shareNetworkId]: shareNetworkSecurityServices});
};

const deleteShareNetworkSecurityServicesSuccess=function(state,{shareNetworkId}) {
  const newState = Object.assign({},state);
  delete newState[shareNetworkId];
  return newState;
};

//######################## SHARE RULES #########################
// {shareNetworkId: {items:Array, isFetching: Bool, receivedAt: Date} }

const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false
};

export const shareNetworkSecurityServices = function(state, action) {
  if (state == null) { state = {}; }
  switch (action.type) {
    case constants.RECEIVE_SHARE_NETWORK_SECURITY_SERVICES: return receiveShareNetworkSecurityServices(state,action);
    case constants.REQUEST_SHARE_NETWORK_SECURITY_SERVICES: return requestShareNetworkSecurityServices(state,action);
    case constants.RECEIVE_SHARE_NETWORK_SECURITY_SERVICE: return receiveShareNetworkSecurityService(state,action);
    case constants.REQUEST_DELETE_SHARE_NETWORK_SECURITY_SERVICE: return requestDeleteShareNetworkSecurityService(state,action);
    case constants.DELETE_SHARE_NETWORK_SECURITY_SERVICE_FAILURE: return deleteShareNetworkSecurityServiceFailure(state,action);
    case constants.DELETE_SHARE_NETWORK_SECURITY_SERVICE_SUCCESS: return deleteShareNetworkSecurityServiceSuccess(state,action);
    case constants.DELETE_SHARE_NETWORK_SECURITY_SERVICES_SUCCESS: return deleteShareNetworkSecurityServicesSuccess(state,action);
    default: return state;
  }
};
