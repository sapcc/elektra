import * as constants from '../constants';

//########################## ROLES ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false
};

const requestRoles=(state,{requestedAt})=> (
  {...state, isFetching: true, requestedAt}
)

const requestRolesFailure=(state) => (
  {...state, isFetching: false}
)

const receiveRoles=(state,{roles,receivedAt})=> (
  {...state, isFetching: false, items: roles, receivedAt}
)

// entries reducer
export default (state, action) => {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.RECEIVE_ROLES: return receiveRoles(state,action);
    case constants.REQUEST_ROLES: return requestRoles(state,action);
    case constants.REQUEST_ROLES_FAILURE: return requestRolesFailure(state,action);
    default: return state;
  }
};
