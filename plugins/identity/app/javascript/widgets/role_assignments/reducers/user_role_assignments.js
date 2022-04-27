import * as constants from '../constants';

//########################## PROJECTS ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false
};

const requestUserRoleAssignments=(state,{userId, requestedAt})=> {
  const newState = {...state}
  newState[userId] = Object.assign({},initialState,newState[userId],{
    isFetching: true,
    requestedAt
  });
  return newState;
}

const requestUserRoleAssignmentsFailure=(state, {userId}) => {
  const newState = {...state}
  newState[userId] = Object.assign({},initialState,newState[userId],{
    isFetching: false
  });
  return newState;
}

const receiveUserRoleAssignments=(state,{userId,roles,receivedAt})=> {
  const newState = {...state}
  newState[userId] = Object.assign({},initialState,newState[userId],{
    isFetching: false,
    receivedAt,
    items: roles
  });
  return newState;
}

// entries reducer
export default (state, action) => {
  if (state == null) { state = {}; }
  switch (action.type) {
    case constants.RECEIVE_USER_ROLE_ASSIGNMENTS: return receiveUserRoleAssignments(state,action);
    case constants.REQUEST_USER_ROLE_ASSIGNMENTS: return requestUserRoleAssignments(state,action);
    case constants.REQUEST_USER_ROLE_ASSIGNMENTS_FAILURE: return requestUserRoleAssignmentsFailure(state,action);
    default: return state;
  }
};
