import React from "react"

const initialState = {
  payload: null,
  isFetching: false,
  error: null,
  updatedAt: null,
}

const reducer = (state = initialState, action = {}) => {
  switch (action.type) {
    case "reuqest":
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

const useReducers = (reducerKeys) => {
  for (let key of reducerKeys) {
    const [bgpvpns, dispatch_bgpvpns] = React.useReducer(reducer, initialState)
  }
}

const StateContext = React.createContext()
const DispatchContext = React.createContext()

export const useGlobalState = (name) => {
  const state = React.useContext(StateContext)
  return name ? state[name] : state
}

export const useDispatch = () => React.useContext(DispatchContext)

const StateProvider = ({ children, reducer, initialState }) => {
  useReducers(["test"])

  const [bgpvpns, dispatch_bgpvpns] = React.useReducer(reducer, initialState)
  const [projects, dispatch_projects] = React.useReducer(reducer, initialState)
  const [routers, dispatch_routers] = React.useReducer(reducer, initialState)

  const dispatch = React.useCallback((name, type, data) => {
    const func = { dispatch_bgpvpns, dispatch_projects, dispatch_routers }
    func[`dispatch_${name}`]({ ...data, type })
  }, [])

  return (
    <StateContext.Provider value={{ bgpvpns, projects, routers }}>
      <DispatchContext.Provider value={dispatch}>
        {children}
      </DispatchContext.Provider>
    </StateContext.Provider>
  )
}

export default StateProvider
