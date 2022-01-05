import React, { createContext, useReducer } from "react"

const FormState = createContext(null)
const FormDispatch = createContext(null)

const initialState = { service: null, attr: null }

const setService = (state, { service }) => {
  // get the id of the last item
  return { ...state, service: service, attr: null }
}
const removeService = (state) => {
  return { ...state, service: null, attr: null }
}
const setServiceAttr = (state, { attr }) => {
  return { ...state, attr: attr }
}
const removeServiceAttr = (state) => {
  return { ...state, attr: null }
}

function reducer(state, action) {
  switch (action.type) {
    case "SET_SERVICE":
      return setService(state, action)
    case "REMOVE_SERVICE":
      return removeService(state, action)
    case "SET_SERVICE_ATTR":
      return setServiceAttr(state, action)
    case "REMOVE_SERVICE_ATTR":
      return removeServiceAttr(state, action)
    default:
      throw new Error()
  }
}

export const FormStateProvider = ({ children, items }) => {
  const [state, dispatch] = useReducer(reducer, initialState)
  return (
    <FormState.Provider value={state}>
      <FormDispatch.Provider value={dispatch}>{children}</FormDispatch.Provider>
    </FormState.Provider>
  )
}

export const useFormDispatch = () => React.useContext(FormDispatch)

export const useFormState = () => {
  return React.useContext(FormState)
}
