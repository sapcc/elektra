import * as constants from '../constants';

const initialState = {
  data: null,
  requestedAt: null,
  receivedAt: null,
  isFetching: false,
  error: null
};

const requestGroups= function(state,{requestedAt}) {
  return {...state, requestedAt, isFetching: true, data: null, error: null};
};

const receiveGroups= function(state,{data, receivedAt}) {
  return {...state, data, receivedAt, isFetching: false, error: null};
};

const requestGroupsFailure= function(state, error) {
  return {...state, error, isFetching: false, data: null};
};

export const groups = function(state, action) {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.REQUEST_GROUPS: return requestGroups(state,action);
    case constants.REQUEST_GROUPS_FAILURE: return requestGroupsFailure(state,action);
    case constants.RECEIVE_GROUPS: return receiveGroups(state,action);

    default: return state;
  }
};
