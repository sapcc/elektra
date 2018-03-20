import * as constants from '../constants';

const initialState = {
  data: null,
  requestedAt: null,
  receivedAt: null,
  isFetching: false
};

const requestProject= function(state,{requestedAt}) {
  return {...state, requestedAt, isFetching: true};
};

const receiveProject= function(state,{data, receivedAt}) {
  return {...state, data, receivedAt, isFetching: false};
};

const requestProjectFailure= function(state) {
  return {...state, isFetching: false};
};

export const project = function(state, action) {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.REQUEST_PROJECT: return requestProject(state,action);
    case constants.REQUEST_PROJECT_FAILURE: return requestProjectFailure(state,action);
    case constants.RECEIVE_PROJECT: return receiveProject(state,action);

    default: return state;
  }
};
