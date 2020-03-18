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

const initListeners = (state) => {
  return { ...initialState }
}

const requestListeners = (state) => ({...state, isLoading: true, error: null})

const receiveListeners = (state,{items,hasNext}) => {
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

const requestListenersFailure = (state, {error}) => { 
  const err = error.response || error
  return {...state, isLoading: false, error: err}
}

export default (state = initialState, action) => {
  switch (action.type) {
    case 'INIT_LISTENERS':
      return initListeners(state,action)    
    case 'REQUEST_LISTENERS':
      return requestListeners(state,action)
    case 'RECEIVE_LISTENERS':
      return receiveListeners(state,action)      
    case 'REQUEST_LISTENERS_FAILURE':
      return requestListenersFailure(state,action)
    default:
      return state
  }
}