// default initial state
const initialState = {
  isFetching: false,
  error: null,
  updatedAt: null,
}

/**
 * This is a universal reducer that can manage the typical actions
 * "add", "remove", "update", "request", "receive" and "error" and "reserError".
 *
 * The payload can be an array or an object. With update, add or remove you have
 * to specify with the action attribute "name" which field is meant.
 * @param {object} state
 * @param {object} action
 * @returns
 */
const reducer = (state = initialState, action = {}) => {
  switch (action.type) {
    case "request":
      return { ...state, isFetching: true, error: null }
    case "receive":
      const { type, ...payload } = action
      return {
        ...state,
        ...payload,
        isFetching: false,
        updatedAt: Date.now(),
      }

    case "update": {
      const attrName = action.name
      const payload = state[attrName]

      let items
      if (Array.isArray(payload)) {
        items = payload.slice()
        const index = items.findIndex((i) => i.id === action.item.id)

        if (index < 0) return state
        items[index] = action.item
      } else {
        items = { ...payload }
        if (!items[action.item.id]) return state
        items[action.item.id] = action.item
      }

      return {
        ...state,
        [attrName]: items,
        updatedAt: Date.now(),
      }
    }
    case "add": {
      const attrName = action.name
      const payload = state[attrName]

      let items
      if (Array.isArray(payload)) {
        items = payload.slice()
        const index = items.findIndex((i) => i.id === action.item.id)
        if (index >= 0) items[index] = action.item
        else items.unshift(action.item)
      } else {
        items = { ...payload }
        items[action.item.id] = action.item
      }

      return {
        ...state,
        [attrName]: items,
        updatedAt: Date.now(),
      }
    }
    case "remove": {
      const attrName = action.name
      const payload = state[attrName]

      let items
      if (Array.isArray(payload)) {
        items = payload.slice()
        const index = items.findIndex((i) => i.id === action.id)
        if (index < 0) return state
        items.splice(index, 1)
      } else {
        items = { ...payload }
        delete items[action.id]
      }

      return {
        ...state,
        [attrName]: items,
        updatedAt: Date.now(),
      }
    }
    case "error":
      return {
        ...state,
        isFetching: false,
        error: action.error,
      }
    case "resetError":
      return { ...state, error: null }
    default:
      return state
  }
}

export default reducer
