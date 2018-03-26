import * as constants from '../constants';

const initialState = {
  data: null,
  requestedAt: null,
  receivedAt: null,
  isFetching: false,
  error: null
};

const requestUsers= function(state,{requestedAt}) {
  return {...state, requestedAt, isFetching: true, data: null, error: null};
};

const receiveUsers= function(state,{data, receivedAt}) {
  return {...state, data, receivedAt, isFetching: false, error: null};
};

const requestUsersFailure= function(state, error) {
  return {...state, error, isFetching: false, data: null};
};

export const users = function(state, action) {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.REQUEST_USERS: return requestUsers(state,action);
    case constants.REQUEST_USERS_FAILURE: return requestUsersFailure(state,action);
    case constants.RECEIVE_USERS: return receiveUsers(state,action);

    default: return state;
  }
};
