const initialState = {
  items: [],
  isLoading: false,
  receivedAt: null,
  hasNext: true,
  marker: null,
  searchTerm: null,
  error: null,
  selected: null
}

const requestL7Rules = (state) => ({...state, isLoading: true, error: null})

const receiveL7Rules = (state,{items,hasNext}) => {
  // sort
  const newItems = items.sort((a, b) => a.type.localeCompare(b.type))
  return {...state, 
    isLoading: false, 
    items: newItems, 
    error: null,
    hasNext,
    marker: items[items.length-1],
    receivedAt: Date.now()}
}

const requestL7RulesFailure = (state, {error}) => { 
  const err = error.response || error
  return {...state, isLoading: false, error: err}
}

const resetL7Rules = (state) => {
  return {...state, 
    items: [],
    isLoading: false,
    receivedAt: null,
    hasNext: true,
    marker: null,
    searchTerm: null,
    error: null,
    selected: null}
}

const receiveL7Rule = (state, {l7Rule}) => {
  if(!l7Rule || !l7Rule.id){
    return state
  }
  const index = state.items.findIndex((item) => item.id==l7Rule.id);
  let items = state.items.slice();
  // update or add l7Rule
  if (index>=0) { items[index]=l7Rule; } else { items.push(l7Rule); }
  // sort
  const newItems = items.sort((a, b) => a.type.localeCompare(b.type))
  return {... state, items: newItems, isLoading: false, error: null}
}

const requestL7RuleDelete = (state, {id})=> {
  const index = state.items.findIndex((item) => item.id==id);
  if (index<0) { return state; }
  let newItems = state.items.slice()
  newItems[index].provisioning_status = 'PENDING_DELETE'
  return {...state, items: newItems}
}

const removeL7Rule = (state, {id}) => {
  const index = state.items.findIndex((item) => item.id==id);
  if (index<0) { return state; }
  let newItems = state.items.slice()
  newItems.splice(index,1)
  return {...state, items: newItems}
}

const setSearchTerm= (state,{searchTerm}) => (
  {...state, searchTerm}
);

const setSelectedItem= (state,{selected}) => (
  {...state, selected}
);

export default (state = initialState, action) => {
  switch (action.type) {
    case 'REQUEST_L7RULES':
      return requestL7Rules(state,action)
    case 'RECEIVE_L7RULES':
      return receiveL7Rules(state,action)      
    case 'REQUEST_L7RULES_FAILURE':
      return requestL7RulesFailure(state,action)
    case 'RESET_L7RULES':
      return resetL7Rules(state,action)      
    case 'RECEIVE_L7RULE':
      return receiveL7Rule(state,action)
    case 'REQUEST_REMOVE_L7RULE':
      return requestL7RuleDelete(state,action)
    case 'REMOVE_L7RULE':
      return removeL7Rule(state,action)
    case 'SET_L7RULES_SEARCH_TERM':
      return setSearchTerm(state,action)
    case 'SET_L7RULES_SELECTED_ITEM':
      return setSelectedItem(state,action)
    default:
      return state
  }
}