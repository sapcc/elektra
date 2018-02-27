import * as constants from '../constants';

//########################## SUBNETS ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false
};

const requestSubnets=(state,{requestedAt})=> (
  {... state, isFetching: true, requestedAt}
)

const requestSubnetsFailure = (state,...rest) =>(
  {... state, isFetching: false }
)

const receiveSubnets=(state,{subnets,receivedAt}) => (
  {... state, isFetching: false, items: subnets, receivedAt}
)

export const subnets = function(state, action) {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.RECEIVE_SUBNETS: return receiveSubnets(state,action);
    case constants.REQUEST_SUBNETS: return requestSubnets(state,action);
    case constants.REQUEST_SUBNETS_FAILURE: return requestSubnetsFailure(state,action);
    default: return state;
  }
};
