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

//#################### RULES
const removeSecurityGroupRule = (state,{securityGroupId, id}) => {
  const securityGroupIndex = state.items.findIndex((item) => item.id==securityGroupId);
  if(securityGroupIndex<0) return state

  let securityGroup = state.items[securityGroupIndex]
  const index = securityGroup.security_group_rules.findIndex((item) => item.id==id);
  if (index<0) { return state; }

  let newItems = securityGroup.security_group_rules.slice()
  newItems.splice(index,1)
  securityGroup = {...securityGroup, security_group_rules: newItems}
  const newSecurityGroupItems = state.items.slice()
  newSecurityGroupItems[securityGroupIndex] = securityGroup
  return {...state, items: newSecurityGroupItems}
}

const receiveSecurityGroupRule = (state,{securityGroupId, securityGroupRule}) => {
  const securityGroupIndex = state.items.findIndex((item) => item.id==securityGroupId);

  if(securityGroupIndex<0) return state

  let securityGroup = state.items[securityGroupIndex]

  const index = securityGroup.security_group_rules.findIndex((item) => item.id==securityGroupRule.id);

  let newItems = securityGroup.security_group_rules.slice()
  if (index>=0) { newItems[index]=securityGroupRule; } else { newItems.push(securityGroupRule); }
  securityGroup = {...securityGroup, security_group_rules: newItems}
  const newSecurityGroupItems = state.items.slice()
  newSecurityGroupItems[securityGroupIndex] = securityGroup
  return {...state, items: newSecurityGroupItems}
}

const requestSecurityGroupRuleDelete = (state,{securityGroupId, id}) => {
  const securityGroupIndex = state.items.findIndex((item) => item.id==securityGroupId);
  if(securityGroupIndex<0) return state

  let securityGroup = state.items[securityGroupIndex]
  const index = securityGroup.security_group_rules.findIndex((item) => item.id==id);
  if (index<0) { return state; }

  let newItems = securityGroup.security_group_rules.slice()
  newItems[index].status = 'deleting'
  securityGroup = {...securityGroup, security_group_rules: newItems}
  const newSecurityGroupItems = state.items.slice()
  newSecurityGroupItems[securityGroupIndex] = securityGroup
  return {...state, items: newSecurityGroupItems}
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
    case constants.REMOVE_SECURITY_GROUP_RULE: return removeSecurityGroupRule(state,action);
    case constants.RECEIVE_SECURITY_GROUP_RULE: return receiveSecurityGroupRule(state,action);
    case constants.REQUEST_SECURITY_GROUP_RULE_DELETE: return requestSecurityGroupRuleDelete(state,action);
    default: return state;
  }
};
