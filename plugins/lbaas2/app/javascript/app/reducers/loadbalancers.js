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
    marker: marker,
    updatedAt: Date.now()}
}

const requestLoadbalancersFailure = (state, {error}) => { 
  const err = error.response || error
  return {...state, isLoading: false, error: err}
}

const requestLoadbalancer = (state) => ({...state, isLoading: true, error: null})

const receiveLoadbalancer = (state, {loadbalancer}) => {
  const index = state.items.findIndex((item) => item.id==loadbalancer.id);
  let items = state.items.slice();
  // update or add loadbalancer
  if (index>=0) { items[index]=loadbalancer; } else { items.push(loadbalancer); }
  // sort
  items = items.sort((a, b) => a.name.localeCompare(b.name))
  return {... state, items: items}
}

const selectLoadbalancer = (state, {loadbalancer}) => {
  return {... state, selected: loadbalancer}
}

const setSearchTerm= (state,{searchTerm}) => (
  {...state, searchTerm}
);

const removeLoadbalancer = (state, {id}) => {
  const index = state.items.findIndex((item) => item.id==id);
  if (index<0) { return state; }
  let newItems = state.items.slice()
  newItems.splice(index,1)
  return {...state, items: newItems}
}

export default (state = initialState, action) => {
  switch (action.type) {
    case 'REQUEST_LOADBALANCERS':
      return requestLoadbalancers(state,action)
    case 'RECEIVE_LOADBALANCERS':
      return receiveLoadbalancers(state,action)      
    case 'REQUEST_LOADBALANCERS_FAILURE':
      return requestLoadbalancersFailure(state,action)
      case 'REQUEST_LOADBALANCER':
        return requestLoadbalancer(state,action)
    case 'RECEIVE_LOADBALANCER':
      return receiveLoadbalancer(state,action)
    case 'SELECT_LOADBALANCER':
      return selectLoadbalancer(state,action)
    case 'SET_LOADBALANCER_SEARCH_TERM':
      return setSearchTerm(state,action)
    case 'REMOVE_LOADBALANCER':
      return removeLoadbalancer(state,action)
    default:
      return state
  }
}