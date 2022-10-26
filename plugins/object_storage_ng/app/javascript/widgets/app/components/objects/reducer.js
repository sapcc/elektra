const initialState = { items: [], isFetching: false, error: null }

function reducer(state, action) {
  const { type, ...props } = action
  switch (type) {
    case "REQUEST_ITEMS":
      return { ...state, isFetching: true, error: null }
    case "RECEIVE_ITEMS":
      return { ...state, isFetching: false, error: null, items: props.items }
    case "RECEIVE_ITEM": {
      const items = state.items.slice()
      items.unshift(props.item)
      return { ...state, items }
    }
    case "REMOVE_ITEM": {
      const items = state.items.slice()
      const index = items.findIndex(
        (i) => i.name === props.name || i.subdir === props.name
      )
      if (index >= 0) items.splice(index, 1)
      return { ...state, items }
    }
    case "REMOVE_ITEMS": {
      const items = state.items.slice()
      items.filter(
        (i) =>
          action.items.indexOf(i.name) < 0 || action.items.indexOf(i.subdir) < 0
      )
      return { ...state, items }
    }
    case "UPDATE_ITEM": {
      const items = state.items.slice()
      const index = items.findIndex(
        (i) => i.name === props.name || i.subdir === props.name
      )
      if (index < 0) return state
      items[index] = { ...items[index], ...props }
      return { ...state, items }
    }
    case "RECEIVE_ERROR":
      return { ...state, isFetching: false, error: props.error }
    default:
      throw new Error()
  }
}

export { reducer, initialState }
