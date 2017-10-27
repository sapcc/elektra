import * as constants from '../../constants';

const requestSubnets=function(state,{networkId,requestedAt}){
  const newState = Object.assign({},state);
  const subnets = state[networkId] || initialState;

  newState[networkId] = Object.assign({},subnets,{
    isFetching:true,
    requestedAt
  });

  return newState;
};

const receiveSubnets=function(state,{networkId,receivedAt,subnets}){
  const newState = Object.assign({},state);
  newState[networkId] = Object.assign({}, (newState[networkId] || initialState), {
    isFetching: false,
    receivedAt,
    items: subnets
  })
  return newState;
};

const requestSubnetsFailure=function(state,{networkId}){
  const newState = Object.assign({},state);
  const subnets = newState[networkId] || initialState;

  newState[networkId] = Object.assign({},subnets,{isFetching:false});
  return newState;
};

//######################## SUBNETS #########################
// {networkId: {items:Array, isFetching: Bool, receivedAt: Date} }

const initialState = {
  items: [],
  receivedAt: null,
  requestedAt: null,
  isFetching: false
};

export const subnets = function(state, action) {
  if (state == null) { state = {}; }
  switch (action.type) {
    case constants.RECEIVE_SUBNETS: return receiveSubnets(state,action);
    case constants.REQUEST_SUBNETS: return requestSubnets(state,action);
    case constants.REQUEST_SUBNETS_FAILURE: return requestSubnetsFailure(state,action);
    default: return state;
  }
};
