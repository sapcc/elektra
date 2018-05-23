import * as constants from '../constants';

//########################## PROJECTS ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false
};

const requestProjectUserRoles=(state,{projectId, requestedAt})=> {
  const newState = {...state}
  newState[projectId] = Object.assign({},initialState,newState[projectId],{
    isFetching: true,
    requestedAt
  });
  return newState;
}

const requestProjectUserRolesFailure=(state, {projectId}) => {
  const newState = {...state}
  newState[projectId] = Object.assign({},initialState,newState[projectId],{
    isFetching: false
  });
  return newState;
}

const receiveProjectUserRoles=(state,{projectId,roles,receivedAt})=> {
  const newState = {...state}
  newState[projectId] = Object.assign({},initialState,newState[projectId],{
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
    case constants.RECEIVE_PROJECT_USER_ROLES: return receiveProjectUserRoles(state,action);
    case constants.REQUEST_PROJECT_USER_ROLES: return requestProjectUserRoles(state,action);
    case constants.REQUEST_PROJECT_USER_ROLES_FAILURE: return requestProjectUserRolesFailure(state,action);
    default: return state;
  }
};
