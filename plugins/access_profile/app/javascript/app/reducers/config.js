const initialState = {
  profiles: null,
  isLoading: false,
  updatedAt: null,
  error: null,
}

const requestConfig = (state) => ({
  ...state,
  isLoading: true,
  error: null,
})

const receiveConfig = (state, { config }) => {
  return {
    ...state,
    isLoading: false,
    profiles: config,
    error: null,
    updatedAt: Date.now(),
  }
}

const requestConfigFailure = (state, { error }) => {
  return { ...state, isLoading: false, error: error }
}

export default (state = initialState, action) => {
  switch (action.type) {
    case "REQUEST_CONFIG":
      return requestConfig(state, action)
    case "RECEIVE_CONFIG":
      return receiveConfig(state, action)
    case "REQUEST_CONFIG_FAILURE":
      return requestConfigFailure(state, action)
    default:
      return state
  }
}
