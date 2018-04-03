import * as constants from '../constants';

const initialState = {
  data: null,
  requestedAt: null,
  receivedAt: null,
  isFetching: false,
  error: null
};

const requestGroupMembers= function(state,{groupId, requestedAt}) {
  state[groupId] = Object.assign(
    {}, initialState, state[groupId], {isFetching: true, requestedAt, data: null, error: null}
  )

  return {...state}
};

const receiveGroupMembers= function(state,{data, receivedAt, groupId}) {
  state[groupId] = Object.assign(
    {}, initialState, state[groupId], {isFetching: false, receivedAt, data, error: null}
  )

  return {...state}
};

const requestGroupMembersFailure= function(state, {groupId, error}) {
  state[groupId] = Object.assign(
    {}, initialState, state[groupId], {isFetching: false,  data: null, error}
  )

  return {...state}
};

const resetGroupMembers= (state, {}) => ({...initialState})

export const groupMembers = function(state, action) {
  state = state || {}
  switch (action.type) {
    case constants.REQUEST_GROUPMEMBERS: return requestGroupMembers(state,action);
    case constants.REQUEST_GROUPMEMBERS_FAILURE: return requestGroupMembersFailure(state,action);
    case constants.RECEIVE_GROUPMEMBERS: return receiveGroupMembers(state,action);
    case constants.RESET_STORE: return resetGroupMembers(state, action);

    default: return state;
  }
};
