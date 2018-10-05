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

const receiveSecurityGroup= function(state,{securityGroup}) {
  const index = state.items.findIndex((item) => item.id==securityGroup.id);
  const items = state.items.slice();
  // update or add
  if (index>=0) { items[index]=securityGroup; } else { items.push(securityGroup); }
  return {... state, items: items}
};

const requestSecurityGroupDelete = (state,{id})=> {
  const index = state.items.findIndex((item) => item.id==id);
  if (index<0) { return state; }
  let newItems = state.items.slice()
  newItems[index].status = 'deleting'
  return {...state, items: newItems}
}

const removeSecurityGroup = (state,{id}) => {
  const index = state.items.findIndex((item) => item.id==id);
  if (index<0) { return state; }
  let newItems = state.items.slice()
  newItems.splice(index,1)
  return {...state, items: newItems}
}

export const securityGroups = function(state, action) {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.RECEIVE_SECURITY_GROUPS: return receive(state,action);
    case constants.REQUEST_SECURITY_GROUPS: return request(state,action);
    case constants.REQUEST_SECURITY_GROUPS_FAILURE: return requestFailure(state,action);
    case constants.RECEIVE_SECURITY_GROUP: return receiveSecurityGroup(state,action);
    case constants.REMOVE_SECURITY_GROUP: return removeSecurityGroup(state,action);
    case constants.REQUEST_SECURITY_GROUP_DELETE: return requestSecurityGroupDelete(state,action);
    default: return state;
  }
};
