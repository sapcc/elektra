import React from "react"

// This module provides the state provider with a default reducer, which is used
// several times. This makes it possible to manage several states dynamically.
// default initial state
const initialState = {
  isFetching: false,
  error: null,
  updatedAt: null,
}

// default reducer
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

/**
 * Hook to create multiple reducers
 * @param {array} reducerKeys
 * @returns {array} state and dispatch function.
 * Dispatch function accepts maxthree parameters but at least two
 * name of state, type, payload. e.g. dispatch("projects", "receive", {items: []}
 */
const useReducers = (reducerKeys) => {
  const state = {}
  const dispatchFunc = {}
  for (let key of reducerKeys) {
    const [s, d] = React.useReducer(reducer, initialState)
    state[key] = s
    dispatchFunc[key] = d
  }

  const dispatch = React.useCallback((name, type, data = {}) => {
    dispatchFunc[name]({ ...data, type })
  }, [])

  return [state, dispatch]
}

const StateContext = React.createContext()
const DispatchContext = React.createContext()

export const useGlobalState = (name) => {
  const state = React.useContext(StateContext)
  return name ? state[name] : state
}

export const useDispatch = () => React.useContext(DispatchContext)

const StateProvider = ({ children, stateKeys }) => {
  // create reducers for each key in stateKeys
  const [state, dispatch] = useReducers(stateKeys)

  return (
    <StateContext.Provider value={state}>
      <DispatchContext.Provider value={dispatch}>
        {children}
      </DispatchContext.Provider>
    </StateContext.Provider>
  )
}

export default StateProvider
