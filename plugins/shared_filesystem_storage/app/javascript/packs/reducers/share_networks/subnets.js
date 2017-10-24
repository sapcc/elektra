import * as constants from '../../constants';

const requestSubnets=function(state,{networkId}){
  const newState = Object.assign({},state);
  const subnets = newState[networkId] || {};

  newState[networkId] = Object.assign({},subnets,{isFetching:true});
  return newState;
};

const receiveSubnets=function(state,{networkId,receivedAt,subnets}){
  const newState = Object.assign({},state);
  newState[networkId] = {
    isFetching: false,
    receivedAt,
    items: subnets
  };
  return newState;
};

const requestSubnetsFailure=function(state,...rest){
  const obj = rest[0];
  const newState = Object.assign({},state);
  const subnets = newState[networkId] || {};

  newState[networkId] = Object.assign({},subnets,{isFetching:false});
  return newState;
};

//######################## SUBNETS #########################
// {networkId: {items:Array, isFetching: Bool, receivedAt: Date} }

const initialState = {};

export const subnets = function(state, action) {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.RECEIVE_SUBNETS: return receiveSubnets(state,action);
    case constants.REQUEST_SUBNETS: return requestSubnets(state,action);
    case constants.REQUEST_SUBNETS_FAILURE: return deleteSubnetsFailure(state,action);
    default: return state;
  }
};
