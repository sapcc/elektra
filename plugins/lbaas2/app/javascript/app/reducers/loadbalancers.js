const initialState = {
  items: [],
  isLoading: false,
  receivedAt: null,
  hasNext: true,
  marker: null,
  searchTerm: null,
  error: null
}

const requestLoadbalancers = (state) => ({...state, isLoading: true, error: null})

const receiveLoadbalancers = (state,{items,hasNext}) => {
  let newItems = (state.items.slice() || []).concat(items);
  // filter duplicated items
  newItems = newItems.filter( (item, pos, arr) =>
    arr.findIndex(i => i.id == item.id)==pos
  );
  // create marker before sorting just in case there is any difference
  const marker = items[items.length-1]
  // sort
  newItems = newItems.sort((a, b) => a.name.localeCompare(b.name))

  return {...state, 
    isLoading: false, 
    items: newItems, 
    error: null,
    hasNext,
    marker: items[items.length-1],
    updatedAt: Date.now()}
}

const requestLoadbalancersFailure = (state, {error}) => { 
  console.log("request failure -->", error)
  const err = error.response || error
  return {...state, isLoading: false, error: err}
}

const receiveLoadbalancer = (state, {loadbalancer}) => {
  const index = state.items.findIndex((item) => item.id==loadbalancer.id);
  let items = state.items.slice();
  // update or add loadbalancer
  if (index>=0) { items[index]=loadbalancer; } else { items.push(loadbalancer); }
  // sort
  items = items.sort((a, b) => a.name.localeCompare(b.name))
  return {... state, items: items}
}

export default (state = initialState, action) => {
  switch (action.type) {
    case 'REQUEST_LOADBALANCERS':
      return requestLoadbalancers(state,action)
    case 'RECEIVE_LOADBALANCERS':
      return receiveLoadbalancers(state,action)      
    case 'REQUEST_LOADBALANCERS_FAILURE':
      return requestLoadbalancersFailure(state,action)
    case 'RECEIVE_LOADBALANCER':
      return receiveLoadbalancer(state,action)  
    default:
      return state
  }
}