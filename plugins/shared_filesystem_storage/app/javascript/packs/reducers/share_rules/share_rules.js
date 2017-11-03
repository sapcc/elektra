import * as constants from '../../constants'

const requestShareRules=function(state,{shareId,requestedAt}){
  const newState = Object.assign({},state);
  const rules = newState[shareId] || {};

  newState[shareId] = Object.assign({},rules,{isFetching:true,requestedAt});
  return newState;
};

const receiveShareRules=function(state,{shareId,receivedAt,rules}){
  const newState = Object.assign({},state);
  newState[shareId] = Object.assign({},newState[shareId],{
    isFetching: false,
    receivedAt,
    items: rules
  });
  return newState;
};

const receiveShareRule=function(state,{shareId,rule}){
  // return old state unless rules entry exists
  if (!state[shareId]) {
    return receiveShareRules(state,{shareId,rules: [rule]});
  }

  // copy current rules
  const rules = Object.assign({},state[shareId]);
  const ruleIndex = rules.items.findIndex( (r) => r.id == rule.id)
  if (ruleIndex>=0) {
    rules.items[ruleIndex] = rule;
  } else {
    rules.items.push(rule);
  }

  // return new state (copy old state with new rules)
  return Object.assign({},state,{[shareId]: rules});
};


const requestDeleteShareRule=function(state,{shareId,ruleId}){
  // return old state unless rules entry exists
  if (!state[shareId] || !state[shareId].items) { return state; }
  const ruleIndex = state[shareId].items.findIndex((rule) => rule.id == ruleId)
  if (ruleIndex<0) { return state; }

  // copy current rules
  const rules = Object.assign({},state[shareId]);
  // mark as deleting
  rules.items[ruleIndex].isDeleting=true;
  // return new state (copy old state with new rules)
  return Object.assign({},state,{[shareId]: rules});
};

const deleteShareRuleFailure=function(state,{shareId,ruleId}){
  // return old state unless rules entry exists
  if (!state[shareId] || !state[shareId].items) { return state; }
  const ruleIndex = state[shareId].items.findIndex((rule) => rule.id == ruleId);
  if (ruleIndex<0) { return state; }

  // copy current rules
  const rules = Object.assign({},state[shareId]);
  // reset isDeleting flag
  rules.isDeleting=false;
  // return new state (copy old state with new rules)
  return Object.assign({},state,{[shareId]: rules});
};

const deleteShareRuleSuccess=function(state,{shareId,ruleId}){
  // return old state unless rules entry exists
  if (!state[shareId] || !state[shareId].items) { return state; }
  const ruleIndex = state[shareId].items.findIndex((rule) => rule.id == ruleId);
  if (ruleIndex<0) { return state; }

  // copy current rules
  const rules = Object.assign({},state[shareId]);
  // delete rule item
  rules.items.splice(ruleIndex,1);
  // return new state (copy old state with new rules)
  return Object.assign({},state,{[shareId]: rules});
};

const deleteShareRulesSuccess=function(state,{shareId}) {
  const newState = Object.assign({},state);
  delete newState[shareId];
  return newState;
};

//######################## SHARE RULES #########################
// {shareId: {items:Array, isFetching: Bool, receivedAt: Date} }

const initialShareRulesState = {};

export const shareRules = function(state, action) {
  if (state == null) { state = initialShareRulesState; }
  switch (action.type) {
    case constants.RECEIVE_SHARE_RULES: return receiveShareRules(state,action);
    case constants.REQUEST_SHARE_RULES: return requestShareRules(state,action);
    case constants.RECEIVE_SHARE_RULE: return receiveShareRule(state,action);
    case constants.REQUEST_DELETE_SHARE_RULE: return requestDeleteShareRule(state,action);
    case constants.DELETE_SHARE_RULE_FAILURE: return deleteShareRuleFailure(state,action);
    case constants.DELETE_SHARE_RULE_SUCCESS: return deleteShareRuleSuccess(state,action);
    case constants.DELETE_SHARE_RULES_SUCCESS: return deleteShareRulesSuccess(state,action);
    default: return state;
  }
};
