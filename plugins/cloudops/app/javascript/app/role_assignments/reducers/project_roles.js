import * as constants from '../constants';

//########################## PROJECTS ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false
};

const requestProjectRoles=(state,{projectId, requestedAt})=> {
  const newState = {...state}
  newState[projectId] = Object.assign({},initialState,newState[projectId],{
    isFetching: true,
    requestedAt
  });
  return newState;
}

const requestProjectRolesFailure=(state, {projectId}) => {
  const newState = {...state}
  newState[projectId] = Object.assign({},initialState,newState[projectId],{
    isFetching: false
  });
  return newState;
}

const receiveProjectRoles=(state,{projectId,roles,receivedAt})=> {
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
    case constants.RECEIVE_PROJECT_ROLES: return receiveProjectRoles(state,action);
    case constants.REQUEST_PROJECT_ROLES: return requestProjectRoles(state,action);
    case constants.REQUEST_PROJECT_ROLES_FAILURE: return requestProjectRolesFailure(state,action);
    default: return state;
  }
};
