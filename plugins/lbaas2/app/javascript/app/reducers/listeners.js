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

const requestListeners = (state) => ({...state, isLoading: true, error: null})

const receiveListeners = (state,{items,hasNext}) => {
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

const requestListenersFailure = (state, {error}) => { 
  const err = error.response || error
  return {...state, isLoading: false, error: err}
}

const receiveListener = (state, {listener}) => {
  const index = state.items.findIndex((item) => item.id==listener.id);
  let items = state.items.slice();
  // update or add listener
  if (index>=0) { items[index]=listener; } else { items.push(listener); }
  // sort
  items = items.sort((a, b) => a.name.localeCompare(b.name))
  return {... state, items: items, isLoading: false, error: null}
}

const removeListener = (state, {id}) => {
  const index = state.items.findIndex((item) => item.id==id);
  if (index<0) { return state; }
  let newItems = state.items.slice()
  newItems.splice(index,1)
  return {...state, items: newItems}
}

export default (state = initialState, action) => {
  switch (action.type) {
    case 'REQUEST_LISTENERS':
      return requestListeners(state,action)
    case 'RECEIVE_LISTENERS':
      return receiveListeners(state,action)      
    case 'REQUEST_LISTENERS_FAILURE':
      return requestListenersFailure(state,action)
    case 'RECEIVE_LISTENER':
      return receiveListener(state,action)
    case 'REMOVE_LISTENER':
      return removeListener(state,action)
    default:
      return state
  }
}