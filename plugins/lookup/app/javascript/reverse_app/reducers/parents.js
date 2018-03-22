import * as constants from '../constants';

const initialState = {
  data: null,
  requestedAt: null,
  receivedAt: null,
  isFetching: false,
  error: null
};

const requestParents= function(state,{requestedAt}) {
  return {...state, requestedAt, isFetching: true, data: null, error: null};
};

const receiveParents= function(state,{data, receivedAt}) {
  return {...state, data, receivedAt, isFetching: false, error: null};
};

const requestParentsFailure= function(state, error) {
  return {...state, error, isFetching: false, data: null};
};

export const parents = function(state, action) {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.REQUEST_PARENTS: return requestParents(state,action);
    case constants.REQUEST_PARENTS_FAILURE: return requestParentsFailure(state,action);
    case constants.RECEIVE_PARENTS: return receiveParents(state,action);

    default: return state;
  }
};
