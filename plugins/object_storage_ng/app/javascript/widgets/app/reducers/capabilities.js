const initialState = {
  data: {},
  isFetching: false,
  error: null,
  updatedAt: null,
}

export default (state = initialState, action = {}) => {
  switch (action.type) {
    case "REQUEST_CAPABILITIES":
      return { ...state, isFetching: true, error: null }
    case "RECEIVE_CAPABILITIES":
      return {
        ...state,
        data: action.data,
        isFetching: false,
        updatedAt: Date.now(),
      }
    case "RECEIVE_CAPABILITIES_ERROR":
      return {
        ...state,
        isFetching: false,
        error: action.error,
      }
    default:
      return state
  }
}
