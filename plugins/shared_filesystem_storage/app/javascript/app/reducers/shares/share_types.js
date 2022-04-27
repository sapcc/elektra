import * as constants from '../../constants';

//########################## SHARES ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false
};

const requestShareTypes=(state,{requestedAt})=>
  Object.assign({},state,{isFetching: true, requestedAt});

const requestShareTypesFailure=function(state){
  return Object.assign({},state,{isFetching: false});
};

const receiveShareTypess=(state,{shareTypes,receivedAt})=>
  Object.assign({},state,{
    isFetching: false,
    items: shareTypes,
    receivedAt
  })
;

// networks reducer
export const shareTypes = function(state, action) {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.RECEIVE_SHARE_TYPES: return receiveShareTypess(state,action);
    case constants.REQUEST_SHARE_TYPES: return requestShareTypes(state,action);
    case constants.REQUEST_SHARE_TYPES_FAILURE: return requestShareTypesFailure(state,action);
    default: return state;
  }
};
