const initialState = {
  payload: {},
  isFetching: false,
  error: null,
  updatedAt: null,
}

export default (state = initialState, action = {}) => {
  switch (action.type) {
    case "request":
      return { ...state, isFetching: true, error: null }
    case "receive":
      return {
        ...state,
        payload: action.payload,
        isFetching: false,
        updatedAt: Date.now(),
      }
    case "error":
      return {
        ...state,
        isFetching: false,
        error: action.error,
      }
    default:
      return state
  }
}
