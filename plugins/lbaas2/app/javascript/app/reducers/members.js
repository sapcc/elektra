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

const receiveMember = (state, {member}) => {
  if (!member) {return {...state}}
  const index = state.items.findIndex((item) => item.id==member.id);
  let items = state.items.slice();
  // update or add member
  if (index>=0) { items[index]=member; } else { items.push(member); }
  // sort
  items = items.sort((a, b) => a.name.localeCompare(b.name))
  return {... state, items: items, isLoading: false, error: null}
}

const removeMember = (state, {id}) => {
  const index = state.items.findIndex((item) => item.id==id);
  if (index<0) { return state; }
  let newItems = state.items.slice()
  newItems.splice(index,1)
  return {...state, items: newItems}
}

const requestMemberDelete = (state, {id}) => {
  const index = state.items.findIndex((item) => item.id==id);
  if (index<0) { return state; }
  let newItems = state.items.slice()
  newItems[index].provisioning_status = 'PENDING_DELETE'
  return {...state, items: newItems}
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

const setSearchTerm= (state,{searchTerm}) => (
  {...state, searchTerm}
);

export default (state = initialState, action) => {
  switch (action.type) {
    case 'REQUEST_MEMBERS':
      return requestMembers(state,action)
    case 'RECEIVE_MEMBERS':
      return receiveMembers(state,action)      
    case 'REQUEST_MEMBERS_FAILURE':
      return requestMembersFailure(state,action)
    case 'RECEIVE_MEMBER':
      return receiveMember(state,action)
    case 'REMOVE_MEMBER':
      return removeMember(state,action)
    case 'REQUEST_REMOVE_MEMBER':
      return requestMemberDelete(state,action)
    case 'RESET_MEMBERS':
      return resetMembers(state,action)
    case 'SET_MEMBERS_SEARCH_TERM':
      return setSearchTerm(state,action)
    default:
      return state
  }
}