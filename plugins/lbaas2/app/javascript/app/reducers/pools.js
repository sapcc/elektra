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

const initPools = (state) => {
  return { ...initialState }
}

const requestPools = (state) => ({...state, isLoading: true, error: null})

const receivePools = (state,{items,hasNext}) => {
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

const requestPoolsFailure = (state, {error}) => { 
  const err = error.response || error
  return {...state, isLoading: false, error: err}
}

export default (state = initialState, action) => {
  switch (action.type) {
    case 'INIT_POOLS':
      return initPools(state,action)    
    case 'REQUEST_POOLS':
      return requestPools(state,action)
    case 'RECEIVE_POOLS':
      return receivePools(state,action)      
    case 'REQUEST_POOLS_FAILURE':
      return requestPoolsFailure(state,action)
    default:
      return state
  }
}