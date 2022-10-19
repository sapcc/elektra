const initialState = {
  items: [],
  isLoading: false,
  updatedAt: null,
  searchTerm: null,
  error: null,
  selected: null,
  marker: null,
  hasNext: true,
  limit: 20,
  sortKey: "name",
  sortDir: "asc",
}

const requestPools = (state) => ({ ...state, isLoading: true, error: null })

const receivePools = (
  state,
  { items, has_next, limit, sort_key, sort_dir }
) => {
  let newItems = (state.items.slice() || []).concat(items)
  // filter duplicated items
  newItems = newItems.filter(
    (item, pos, arr) => arr.findIndex((i) => i.id == item.id) == pos
  )
  const marker = items.length > 0 ? items[items.length - 1].id : null
  // sort
  newItems = newItems.sort((a, b) => a.name.localeCompare(b.name))

  return {
    ...state,
    isLoading: false,
    items: newItems,
    error: null,
    marker: marker,
    hasNext: has_next,
    limit: limit,
    sortKey: sort_key,
    sortDir: sort_dir,
    updatedAt: Date.now(),
  }
}

const requestPoolsFailure = (state, { error }) => {
  return { ...state, isLoading: false, error }
}

const resetPools = (state) => {
  return {
    ...state,
    items: [],
    isLoading: false,
    receivedAt: null,
    hasNext: true,
    marker: null,
    searchTerm: null,
    error: null,
    selected: null,
  }
}

const receivePool = (state, { pool }) => {
  if (!pool || !pool.id) {
    return state
  }
  const index = state.items.findIndex((item) => item.id == pool.id)
  let items = state.items.slice()
  // update or add Pool
  if (index >= 0) {
    items[index] = pool
  } else {
    items.push(pool)
  }
  // sort
  items = items.sort((a, b) => a.name.localeCompare(b.name))
  return { ...state, items: items, isLoading: false, error: null }
}

const removePool = (state, { id }) => {
  const index = state.items.findIndex((item) => item.id == id)
  if (index < 0) {
    return state
  }
  let newItems = state.items.slice()
  newItems.splice(index, 1)
  return { ...state, items: newItems }
}

const requestPoolDelete = (state, { id }) => {
  const index = state.items.findIndex((item) => item.id == id)
  if (index < 0) {
    return state
  }
  let newItems = state.items.slice()
  newItems[index].provisioning_status = "PENDING_DELETE"
  return { ...state, items: newItems }
}

const setSearchTerm = (state, { searchTerm }) => ({ ...state, searchTerm })

const setSelectedItem = (state, { selected }) => ({ ...state, selected })

export default (state = initialState, action) => {
  switch (action.type) {
    case "REQUEST_POOLS":
      return requestPools(state, action)
    case "RECEIVE_POOLS":
      return receivePools(state, action)
    case "REQUEST_POOLS_FAILURE":
      return requestPoolsFailure(state, action)
    case "RESET_POOLS":
      return resetPools(state, action)
    case "RECEIVE_POOL":
      return receivePool(state, action)
    case "REMOVE_POOL":
      return removePool(state, action)
    case "REQUEST_REMOVE_POOL":
      return requestPoolDelete(state, action)
    case "SET_POOLS_SEARCH_TERM":
      return setSearchTerm(state, action)
    case "SET_POOLS_SELECTED_ITEM":
      return setSelectedItem(state, action)
    default:
      return state
  }
}
