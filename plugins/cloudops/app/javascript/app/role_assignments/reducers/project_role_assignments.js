import * as constants from '../constants';

//########################## PROJECTS ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false
};

const requestProjectRoleAssignments=(state,{projectId, requestedAt})=> {
  const newState = {...state}
  newState[projectId] = Object.assign({},initialState,newState[projectId],{
    isFetching: true,
    requestedAt
  });
  return newState;
}

const requestProjectRoleAssignmentsFailure=(state, {projectId}) => {
  const newState = {...state}
  newState[projectId] = Object.assign({},initialState,newState[projectId],{
    isFetching: false
  });
  return newState;
}

const receiveProjectRoleAssignments=(state,{projectId,roles,receivedAt})=> {
  const newState = {...state}
  newState[projectId] = Object.assign({},initialState,newState[projectId],{
    isFetching: false,
    receivedAt,
    items: roles
  });
  return newState;
}

const receiveProjectMemberRoleAssignments=(state,{projectId,memberType,memberId,roles})=> {
  if(!state[projectId]) return state

  const newState = {...state}
  const items = newState[projectId].items.slice()
  const index = items.findIndex((item) =>
    item[memberType] && item[memberType].id==memberId
  );

  if(Array.isArray(roles)) roles = roles[0]
  if(roles) {
    if(index<0) items.push(roles)
    else items[index] = roles
  } else {
    if(index>=0) delete(items[index])
  }

  console.log(items)

  newState[projectId] = Object.assign({},initialState,newState[projectId],{
    items
  });

  return newState
}

// entries reducer
export default (state, action) => {
  if (state == null) { state = {}; }
  switch (action.type) {
    case constants.RECEIVE_PROJECT_ROLE_ASSIGNMENTS: return receiveProjectRoleAssignments(state,action);
    case constants.REQUEST_PROJECT_ROLE_ASSIGNMENTS: return requestProjectRoleAssignments(state,action);
    case constants.REQUEST_PROJECT_ROLE_ASSIGNMENTS_FAILURE: return requestProjectRoleAssignmentsFailure(state,action);
    case constants.RECEIVE_PROJECT_MEMBER_ROLE_ASSIGNMENTS: return receiveProjectMemberRoleAssignments(state,action);
    default: return state;
  }
};
