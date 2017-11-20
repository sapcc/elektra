import * as constants from '../../constants';

//########################## SECURITY_SERVICES ##############################
const initialSecurityServicesState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false
};

const requestSecurityServices=(state,{requestedAt}) =>
  Object.assign({},state,{isFetching: true, requestedAt});

const requestSecurityServicesFailure=function(state){
  return Object.assign({},state,{isFetching: false});
};

const receiveSecurityServices=(state,{securityServices,receivedAt})=>
  Object.assign({},state,{
    isFetching: false,
    items: securityServices,
    receivedAt
  })
;

const requestSecurityService= function(state,{securityServiceId,requestedAt}) {
  const index = state.items.findIndex((item) => item.id==securityServiceId );
  if (index<0) { return state; }

  const newState = Object.assign({},state);
  newState.items[index].isFetching = true;
  newState.items[index].requestedAt = requestedAt;
  return newState;
};

const requestSecurityServiceFailure=function(state,{securityServiceId}){
  const index = state.items.findIndex((item) => item.id==securityServiceId );
  if (index<0) { return state; }

  const newState = Object.assign({},state);
  newState.items[index].isFetching = false;
  return newState;
};

const receiveSecurityService= function(state,{securityService}) {
  const index = state.items.findIndex((item) => item.id==securityService.id );
  const items = state.items.slice();
  // update or add
  if (index>=0) { items[index]=securityService; } else { items.push(securityService); }
  return Object.assign({},state,{items});
};

const requestDeleteSecurityService= function(state,{securityServiceId}) {
  const index = state.items.findIndex((item) => item.id==securityServiceId );
  if (index<0) { return state; }

  const items = state.items.slice();
  items[index].isDeleting = true;
  return Object.assign({},state,{items});
};

const deleteSecurityServiceFailure= function(state,{securityServiceId}) {
  const index = state.items.findIndex((item) => item.id==securityServiceId );
  if (index<0) { return state; }

  const newState = Object.assign({},state);
  newState.items[index].isDeleting = false;
  return newState;
};

const deleteSecurityServiceSuccess= function(state,{securityServiceId}) {
  const index = state.items.findIndex((item) => item.id==securityServiceId );
  if (index<0) { return state; }
  const items = state.items.slice();
  items.splice(index,1);
  return Object.assign({},state,{items});
};


// securityServices reducer
export const securityServices = function(state, action) {
  if (state == null) { state = initialSecurityServicesState; }
  switch (action.type) {
    case constants.RECEIVE_SECURITY_SERVICES: return receiveSecurityServices(state,action);
    case constants.REQUEST_SECURITY_SERVICES: return requestSecurityServices(state,action);
    case constants.REQUEST_SECURITY_SERVICES_FAILURE: return requestSecurityServicesFailure(state,action);
    case constants.REQUEST_SECURITY_SERVICE: return requestSecurityService(state,action);
    case constants.REQUEST_SECURITY_SERVICE_FAILURE: return requestSecurityServiceFailure(state,action);
    case constants.RECEIVE_SECURITY_SERVICE: return receiveSecurityService(state,action);
    case constants.REQUEST_DELETE_SECURITY_SERVICE: return requestDeleteSecurityService(state,action);
    case constants.DELETE_SECURITY_SERVICE_FAILURE: return deleteSecurityServiceFailure(state,action);
    case constants.DELETE_SECURITY_SERVICE_SUCCESS: return deleteSecurityServiceSuccess(state,action);
    default: return state;
  }
};
