import React from "react"

import { reducer, initialState } from "./reducers"

const StateContext = React.createContext()
const DispatchContext = React.createContext()

export const useGlobalState = (name) => {
  const state = React.useContext(StateContext)
  return name ? state[name] : state
}

export const useDispatch = () => React.useContext(DispatchContext)

const StateProvider = ({ children }) => {
  const [state, dispatch] = React.useReducer(reducer, initialState)

  return (
    <StateContext.Provider value={state}>
      <DispatchContext.Provider value={dispatch}>
        {children}
      </DispatchContext.Provider>
    </StateContext.Provider>
  )
}

export default StateProvider
