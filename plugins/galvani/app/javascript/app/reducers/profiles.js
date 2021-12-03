const initialState = {
  items: [],
  isLoading: false,
  updatedAt: null,
  searchTerm: null,
  error: null,

  marker: null,
  hasNext: true,
  limit: 20,
  sortKey: "name",
  sortDir: "asc",
}

const requestTags = (state) => ({
  ...state,
  isLoading: true,
  error: null,
})

const receiveTags = (state, { tags, has_next, limit, sort_key, sort_dir }) => {
  let newItems = (state.items.slice() || []).concat(tags)
  // filter duplicated items
  newItems = newItems.filter(
    (item, pos, arr) => arr.findIndex((i) => i.id == item.id) == pos
  )
  // create marker before sorting just in case there is any difference
  const marker = tags.length > 0 ? tags[tags.length - 1].id : null
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

const requestTagsFailure = (state, { error }) => {
  return { ...state, isLoading: false, error: error }
}

const receiveTag = (state, { tag }) => {
  // prevent ok responses without content
  if (!tag || !tag.id) {
    return state
  }

  const index = state.items.findIndex((item) => item.id == tag.id)
  let items = state.items.slice()
  if (index >= 0) {
    items[index] = tag
  } else {
    items.push(tag)
  }
  // sort
  items = items.sort((a, b) => a.name.localeCompare(b.name))
  return { ...state, items: items, isLoading: false, error: null }
}

const setSearchTerm = (state, { searchTerm }) => {
  return { ...state, searchTerm }
}

const removeTag = (state, { id }) => {
  const index = state.items.findIndex((item) => item.id == id)
  if (index < 0) {
    return state
  }
  let newItems = state.items.slice()
  newItems.splice(index, 1)
  return { ...state, items: newItems }
}

export default (state = initialState, action) => {
  switch (action.type) {
    case "REQUEST_TAGS":
      return requestTags(state, action)
    case "RECEIVE_TAGS":
      return receiveTags(state, action)
    case "REQUEST_TAGS_FAILURE":
      return requestTagsFailure(state, action)
    case "RECEIVE_TAG":
      return receiveTag(state, action)
    case "SET_TAG_SEARCH_TERM":
      return setSearchTerm(state, action)
    case "REMOVE_TAG":
      return removeTag(state, action)
    default:
      return state
  }
}
