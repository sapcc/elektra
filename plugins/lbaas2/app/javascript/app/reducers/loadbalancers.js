const initialState = {
  items: [],
  isLoading: false,
  updatedAt: null,
  error: null
}

const request = (state) => ({...state, isLoading: true, error: null})

const receive = (state,{items}) => {
  console.log('===')
  console.log('receive loadbalancers')
  console.log(items)
  console.log('===')
  return {...state, isLoading: false, items: items, error: null, updatedAt: Date.now()}
}

const requestFailure = (state, {error}) => ({...state, isLoading: false, error})

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