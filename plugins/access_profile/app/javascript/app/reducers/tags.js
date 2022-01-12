const initialState = {
  items: [],
  isLoading: false,
  updatedAt: null,
  searchTerm: null,
  error: null,
}

const requestTags = (state) => ({
  ...state,
  isLoading: true,
  error: null,
})

const receiveTags = (state, { tags }) => {
  // sort
  const newItems = tags.sort((a, b) => a.localeCompare(b))

  return {
    ...state,
    isLoading: false,
    items: newItems,
    error: null,
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

  const index = state.items.findIndex((item) => item == tag)
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

const removeTag = (state, { tag }) => {
  const index = state.items.findIndex((item) => item == tag)
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
