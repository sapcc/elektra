import * as constants from '../constants';

const initialState = {
  data: null,
  requestedAt: null,
  receivedAt: null,
  isFetching: false,
  error: null
};

const requestProject= function(state,{requestedAt}) {
  return {...state, requestedAt, isFetching: true, data: null, error: null};
};

const receiveProject= function(state,{data, receivedAt}) {
  return {...state, data, receivedAt, isFetching: false, error: null};
};

const requestProjectFailure= function(state, {error}) {
  return {...state, error, isFetching: false, data:null};
};

const resetProject= (state, {}) => ({...initialState})

export const project = function(state, action) {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.REQUEST_PROJECT: return requestProject(state,action);
    case constants.REQUEST_PROJECT_FAILURE: return requestProjectFailure(state,action);
    case constants.RECEIVE_PROJECT: return receiveProject(state,action);
    case constants.RESET_STORE: return resetProject(state, action);

    default: return state;
  }
};
