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

const requestPools = (state) => ({...state, isLoading: true, error: null})

const receivePools = (state,{items,hasNext}) => {
  // sort
  const newItems = items.sort((a, b) => a.name.localeCompare(b.name))
  return {...state, 
    isLoading: false, 
    items: newItems, 
    error: null,
    hasNext,
    marker: items[items.length-1],
    updatedAt: Date.now()}
}

const requestPoolsFailure = (state, {error}) => { 
  const err = error.response || error
  return {...state, isLoading: false, error: err}
}

const resetPools = (state) => {
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

const receivePool = (state, {pool}) => {
  const index = state.items.findIndex((item) => item.id==pool.id);
  let items = state.items.slice();
  // update or add Pool
  if (index>=0) { items[index]=pool; } else { items.push(pool); }
  // sort
  items = items.sort((a, b) => a.name.localeCompare(b.name))
  return {... state, items: items, isLoading: false, error: null}
}

const removePool = (state, {id}) => {
  const index = state.items.findIndex((item) => item.id==id);
  if (index<0) { return state; }
  let newItems = state.items.slice()
  newItems.splice(index,1)
  return {...state, items: newItems}
}

const requestPoolDelete = (state, {id})=> {
  const index = state.items.findIndex((item) => item.id==id);
  if (index<0) { return state; }
  let newItems = state.items.slice()
  newItems[index].provisioning_status = 'PENDING_DELETE'
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
    case 'REQUEST_POOLS':
      return requestPools(state,action)
    case 'RECEIVE_POOLS':
      return receivePools(state,action)      
    case 'REQUEST_POOLS_FAILURE':
      return requestPoolsFailure(state,action)
    case 'RESET_POOLS':
      return resetPools(state,action)   
    case 'RECEIVE_POOL':
      return receivePool(state,action)
    case 'REMOVE_POOL':
      return removePool(state,action)
    case 'REQUEST_REMOVE_POOL':
      return requestPoolDelete(state,action)
    case 'SET_POOLS_SEARCH_TERM':
      return setSearchTerm(state,action)
    case 'SET_POOLS_SELECTED_ITEM':
      return setSelectedItem(state,action)
    default:
      return state
  }
}