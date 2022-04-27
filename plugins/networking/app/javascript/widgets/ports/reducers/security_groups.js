import * as constants from '../constants';

//########################## NETWORKS ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false
};

const request=(state,{requestedAt})=> (
  {... state, isFetching: true, requestedAt}
)

const requestFailure = (state,...rest) => (
  {... state, isFetching: false}
)

const receive=(state,{securityGroups,receivedAt}) => (
  {... state, isFetching: false, items: securityGroups, receivedAt}
)

export const securityGroups = function(state, action) {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.RECEIVE_SECURITY_GROUPS: return receive(state,action);
    case constants.REQUEST_SECURITY_GROUPS: return request(state,action);
    case constants.REQUEST_SECURITY_GROUPS_FAILURE: return requestFailure(state,action);
    default: return state;
  }
};
