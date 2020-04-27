const initialState = {
  item: null,
  isLoading: false,
  receivedAt: null,
  error: null
}

const requestHealthmonitor = (state) => ({...state, isLoading: true, error: null})

const receiveHealthmonitor = (state, {healthmonitor}) => {
  return {... state, item: healthmonitor, isLoading: false, error: null}
}

const requestHealthmonitorFailure = (state, {error}) => { 
  const err = error.response || error
  return {...state, isLoading: false, error: err}
}

const removeHealthmonitor = (state, {id}) => {
  return {...state, item: null}
}

const resetHealthmonitors = (state) => {
  return {...state, 
    item: null,
    isLoading: false,
    receivedAt: null,
    error: null}
}

export default (state = initialState, action) => {
  switch (action.type) {
    case 'REQUEST_HEALTHMONITOR':
      return requestHealthmonitor(state,action)
    case 'RECEIVE_HEALTHMONITOR':
      return receiveHealthmonitor(state,action)
    case 'REQUEST_HEALTHMONITOR_FAILURE':
      return requestHealthmonitorFailure(state,action)
    case 'REMOVE_HEALTHMONITOR':
      return removeHealthmonitor(state,action)
    case 'RESET_HEALTHMONITORS':
      return resetHealthmonitors(state,action)
    default:
      return state
  }
}