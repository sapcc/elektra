const initialState = {
  items: [],
  isLoading: false,
  updatedAt: null,
  searchTerm: null,
  error: null,
  selected: null,
  marker: null,
  hasNext: true,
  limit: 20,
  sortKey: "name",
  sortDir: "asc"
}

const requestLoadbalancers = (state) => ({...state, isLoading: true, error: null})

const receiveLoadbalancers = (state,{loadbalancers, has_next, limit, sort_key, sort_dir}) => {
  let newItems = (state.items.slice() || []).concat(loadbalancers);
  // filter duplicated items
  newItems = newItems.filter( (item, pos, arr) =>
    arr.findIndex(i => i.id == item.id)==pos
  );
  // create marker before sorting just in case there is any difference
  const marker = loadbalancers.length > 0 ? loadbalancers[loadbalancers.length-1].id : null
  // sort
  newItems = newItems.sort((a, b) => a.name.localeCompare(b.name))

  return {...state, 
    isLoading: false, 
    items: newItems, 
    error: null,
    marker: marker,
    hasNext: has_next,
    limit: limit,
    sortKey: sort_key,
    sortDir: sort_dir,
    updatedAt: Date.now()}
}

const requestLoadbalancersFailure = (state, {error}) => { 
  return {...state, isLoading: false, error: error}
}

const receiveLoadbalancer = (state, {loadbalancer}) => {
  // prevent ok responses without content
  if (!loadbalancer || !loadbalancer.id) { 
    return state
  }

  const index = state.items.findIndex((item) => item.id==loadbalancer.id);
  let items = state.items.slice();
  // update or add loadbalancer
  if (index>=0) { items[index]=loadbalancer; } else { items.push(loadbalancer); }
  // sort
  items = items.sort((a, b) => a.name.localeCompare(b.name))
  return {... state, items: items, isLoading: false, error: null}
}

const selectLoadbalancer = (state, {selected}) => {
  return {... state, selected: selected}
}

const setSearchTerm= (state,{searchTerm}) => {
  return {...state, searchTerm}
}

const removeLoadbalancer = (state, {id}) => {
  const index = state.items.findIndex((item) => item.id==id);
  if (index<0) { return state; }
  let newItems = state.items.slice()
  newItems.splice(index,1)
  return {...state, items: newItems}
}

const requestLoadbalancerDelete = (state, {id})=> {
  const index = state.items.findIndex((item) => item.id==id);
  if (index<0) { return state; }
  let newItems = state.items.slice()
  newItems[index].provisioning_status = 'PENDING_DELETE'
  return {...state, items: newItems}
}

const requestLoadbalancerFloatingIP = (state, {id})=> {
  const index = state.items.findIndex((item) => item.id==id);
  if (index<0) { return state; }
  let newItems = state.items.slice()
  newItems[index].provisioning_status = 'PENDING_UPDATE'
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
    case 'RECEIVE_LOADBALANCER':
      return receiveLoadbalancer(state,action)
    case 'SET_LOADBALANCERS_SELECTED_ITEM':
      return selectLoadbalancer(state,action)
    case 'SET_LOADBALANCER_SEARCH_TERM':
      return setSearchTerm(state,action)
    case 'REMOVE_LOADBALANCER':
      return removeLoadbalancer(state,action)
    case 'REQUEST_REMOVE_LOADBALANCER':
      return requestLoadbalancerDelete(state,action)
    case 'REQUEST_FLOATINGIP_LOADBALANCER':
      return requestLoadbalancerFloatingIP(state,action)
    default:
      return state
  }
}