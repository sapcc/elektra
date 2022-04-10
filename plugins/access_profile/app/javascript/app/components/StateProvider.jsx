import React, {createContext, useContext, useReducer} from 'react';

// This function combines multiple reducers.
const combineReducers = (reducer) => {
  if(typeof reducer === 'function') return reducer
  const keys = Object.keys(reducer)

  return (state = {}, action) => {
    const nextReducers = {}
    keys.forEach(key => nextReducers[key] = reducer[key](state[key], action))
    return nextReducers
  }
}

const GlobalStateContext = createContext()
const DispatchContext = createContext()

export const useGlobalState = () => useContext(GlobalStateContext)
export const useDispatch = () => useContext(DispatchContext)

// component
export const StateProvider = ({reducers, children}) => {
  const store = combineReducers(reducers)
  const [state,dispatch] = useReducer(store, store(undefined,{}))

  return (
    <GlobalStateContext.Provider value={state} >
      <DispatchContext.Provider value={dispatch} >
        {children}
      </DispatchContext.Provider>
    </GlobalStateContext.Provider>
  )
}
