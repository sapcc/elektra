const initialState = {
  items: [],
  isLoading: false,
  receivedAt: null,
  hasNext: true,
  marker: null,
  searchTerm: null,
  error: null
}

const request = (state) => ({...state, isLoading: true, error: null})

const receive = (state,{items,hasNext}) => {
  let newItems = (state.items.slice() || []).concat(items);
  // filter duplicated items
  newItems = newItems.filter( (item, pos, arr) =>
    arr.findIndex(i => i.id == item.id)==pos
  );

  return {...state, 
    isLoading: false, 
    items: newItems, 
    error: null,
    hasNext,
    marker: items[items.length-1],
    updatedAt: Date.now()}
}

const requestFailure = (state, {error}) => { 
  console.log("request failure -->", error)
  const err = error.response || error
  return {...state, isLoading: false, error: err}
}

export default (state = initialState, action) => {
  switch (action.type) {
    case 'REQUEST_LOADBALANCERS':
      return request(state,action)
    case 'RECEIVE_LOADBALANCERS':
      return receive(state,action)      
    case 'REQUEST_LOADBALANCERS_FAILURE':
      return requestFailure(state,action)
    default:
      return state
  }
}