import * as constants from '../constants';

//########################## TYPES ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false
};

const requestTypes=(state,{requestedAt})=> (
  { ... state, isFetching: true, requestedAt }
);

const requestTypesFailure=(state) => (
  { ...state, isFetching: false }
);

const receiveTypes=(state,{types,receivedAt})=> (
  { ...state, isFetching: false, items: types, receivedAt }
);

// entries reducer
export const types = function(state, action) {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.RECEIVE_TYPES: return receiveTypes(state,action);
    case constants.REQUEST_TYPES: return requestTypes(state,action);
    case constants.REQUEST_TYPES_FAILURE: return requestTypesFailure(state,action);
    default: return state;
  }
};
