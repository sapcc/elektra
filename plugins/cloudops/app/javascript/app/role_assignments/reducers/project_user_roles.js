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

const receiveProjectUserRoles=(state,{projectId,userId,roles})=> {
  if(!state[projectId]) return state

  const newState = {...state}
  const items = newState[projectId].items.slice()
  const index = items.findIndex((item) => item.user.id==userId);

  if(roles) {
    if(index<0) items.push(roles)
    else items[index] = roles
  } else {
    if(index>=0) delete(items[index])
  }

  newState[projectId] = Object.assign({},initialState,newState[projectId],{
    items
  });

  return newState
}

// entries reducer
export default (state, action) => {
  if (state == null) { state = {}; }
  switch (action.type) {
    case constants.RECEIVE_PROJECT_ROLES: return receiveProjectRoles(state,action);
    case constants.REQUEST_PROJECT_ROLES: return requestProjectRoles(state,action);
    case constants.REQUEST_PROJECT_ROLES_FAILURE: return requestProjectRolesFailure(state,action);
    case constants.RECEIVE_PROJECT_USER_ROLES: return receiveProjectUserRoles(state,action);
    default: return state;
  }
};
