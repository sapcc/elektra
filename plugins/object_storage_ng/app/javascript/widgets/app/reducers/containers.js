const initialState = {
  items: [],
  isFetching: false,
  error: null,
  updatedAt: null,
}

export default (state = initialState, action = {}) => {
  switch (action.type) {
    case "REQUEST_CONTAINERS":
      return { ...state, isFetching: true, error: null }
    case "RECEIVE_CONTAINERS":
      return {
        ...state,
        items: action.items,
        isFetching: false,
        updatedAt: Date.now(),
      }
    case "RECEIVE_CONTAINERS_ERROR":
      return {
        ...state,
        isFetching: false,
        error: action.error,
      }
    case "REMOVE_CONTAINER": {
      const items = state.items.slice()
      const index = items.findIndex((i) => i.name === action.name)
      if (index >= 0) items.splice(index, 1)
      return {
        ...state,
        items,
        isFetching: false,
        updatedAt: Date.now(),
      }
    }

    default:
      return state
  }
}
