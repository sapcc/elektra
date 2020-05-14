const initialState = {
  items: [],
  isLoading: false,
  receivedAt: null,
  searchTerm: null,
  error: null,
  selected: null
}

const requestMembers = (state) => ({...state, isLoading: true, error: null})


const receiveMembers = (state,{items,hasNext}) => {
  // sort
  const newItems = items.sort((a, b) => a.name.localeCompare(b.name))

  return {...state, 
    isLoading: false, 
    items: newItems, 
    error: null,
    receivedAt: Date.now()}
}

const requestMembersFailure = (state, {error}) => { 
  const err = error.response || error
  return {...state, isLoading: false, error: err}
}

const resetMembers = (state) => {
  return {...state, 
    items: [],
    isLoading: false,
    receivedAt: null,
    searchTerm: null,
    error: null,
    selected: null}
}

export default (state = initialState, action) => {
  switch (action.type) {
    case 'REQUEST_MEMBERS':
      return requestMembers(state,action)
    case 'RECEIVE_MEMBERS':
      return receiveMembers(state,action)      
    case 'REQUEST_MEMBERS_FAILURE':
      return requestMembersFailure(state,action)
    case 'RESET_MEMBERS':
      return resetMembers(state,action)
    default:
      return state
  }
}