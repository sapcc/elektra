import React, { createContext, useReducer } from "react"

const FormState = createContext(null)
const FormDispatch = createContext(null)

const initialState = { profile: "", service: null, attrs: {} }

const setService = (state, { profile, service }) => {
  return { ...state, profile, service, attrs: {} }
}
const removeService = (state) => {
  return { ...state, profile: "", service: null, attrs: {} }
}
const setServiceAttr = (state, { key, value }) => {
  return { ...state, attrs: { ...state.attrs, [key]: value } }
}
const removeServiceAttr = (state, { key }) => {
  const attrCopy = { ...state.attrs }
  delete attrCopy[key]
  return { ...state, attrs: attrCopy }
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

export const FormStateProvider = ({ children }) => {
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
