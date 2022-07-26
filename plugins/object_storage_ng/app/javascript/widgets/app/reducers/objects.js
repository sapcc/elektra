// objects state is a map: containerName -> objects
// example:
// {
//   "test1": {
//     items: [], isFetching: false, error: null, updatedAt: 123456789
//   },
//   "test2": {
//     items: [], isFetching: false, error: null, updatedAt: 123456789
//   }
// }
const initialState = {
  items: [],
  isFetching: false,
  error: null,
  updatedAt: null,
}

export default (state = {}, action = {}) => {
  // action must provide containerName
  const containerObjectsState = {
    ...initialState,
    ...state[action.containerName],
  }

  switch (action.type) {
    case "REQUEST_CONTAINER_OBJECTS":
      containerObjectsState.isFetching = true
      containerObjectsState.error = null

      return { ...state, [action.containerName]: containerObjectsState }

    case "RECEIVE_CONTAINER_OBJECTS":
      containerObjectsState.isFetching = false
      containerObjectsState.items = action.items
      containerObjectsState.updatedAt = Date.now()

      return { ...state, [action.containerName]: containerObjectsState }
    // case "RECEIVE_CONTAINER_OBJECT_METADATA": {
    //   const newItems = containerObjectsState.items.slice()
    //   const index = newItems.findIndex((i) => i.name === action.name)
    //   if (index < 0) return state
    //   newItems[index] = { ...newItems[index], metadata: action.metadata }
    //   containerObjectsState.items = newItems

    //   return { ...state, [action.containerName]: containerObjectsState }
    // }
    case "RECEIVE_CONTAINER_OBJECTS_ERROR":
      containerObjectsState.isFetching = false
      containerObjectsState.error = action.error

      return { ...state, [action.containerName]: containerObjectsState }
    default:
      return state
  }
}
