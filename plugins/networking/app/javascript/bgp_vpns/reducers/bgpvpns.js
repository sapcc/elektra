const initialState = {
  items: [],
  isFetching: false,
  error: null,
  updatedAt: null,
}

export default (state = initialState, action = {}) => {
  switch (action.type) {
    case "REQUEST_BGP_VPNS":
      return { ...state, isFetching: true, error: null }
    case "RECEIVE_BGP_VPNS":
      return {
        ...state,
        items: action.items,
        isFetching: false,
        updatedAt: Date.now(),
      }
    case "RECEIVE_BGP_VPNS_ERROR":
      return {
        ...state,
        isFetching: false,
        error: action.error,
      }
    default:
      return state
  }
}
