import * as constants from '../constants';

//########################## RULES ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false
};

const requestRules=(state,{requestedAt})=> (
  {... state, isFetching: true, requestedAt}
)

const requestRulesFailure = (state,...rest) =>(
  {... state, isFetching: false }
)

const receiveRules=(state,{subnets,receivedAt}) => (
  {... state, isFetching: false, items: subnets, receivedAt}
)

export const rules = function(state, action) {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.RECEIVE_RULES: return receiveRules(state,action);
    case constants.REQUEST_RULES: return requestRules(state,action);
    case constants.REQUEST_RULES_FAILURE: return requestRulesFailure(state,action);
    default: return state;
  }
};
