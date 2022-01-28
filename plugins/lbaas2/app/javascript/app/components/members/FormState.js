import React, { createContext, useReducer } from "react"
import uniqueId from "lodash/uniqueId"

const FormState = createContext(null)
const FormDispatch = createContext(null)
const initialState = { items: [] }

const updateItem = (state, { id, key, value }) => {
  let newValues = [...state.items]
  const index = newValues.findIndex((item) => item.id === id)

  // if not found return
  if (index < 0) return state

  // keep monitor_port, protocol_port and weight as int
  if (key === "monitor_port" || key === "protocol_port" || key === "weight") {
    value = parseInt(value, 10) || ""
  }

  // update item
  let item = {
    ...newValues[index],
    [key]: value,
  }
  // check if there is a change between the saved item and the new generated
  if (JSON.stringify(newValues[index]) === JSON.stringify(item)) return state

  newValues[index] = item
  return { ...state, items: newValues }
}

const addItem = (state, { item }) => {
  let newValues = [...state.items]
  newValues.push(item)
  return { ...state, items: newValues }
}

const removeItem = (state, { id }) => {
  let newValues = [...state.items]
  const index = newValues.findIndex((item) => item.id === id)

  if (index >= 0) {
    newValues.splice(index, 1)
  }
  return {
    ...state,
    items: newValues,
  }
}

function reducer(state, action) {
  switch (action.type) {
    case "UPDATE_ITEM":
      return updateItem(state, action)
    case "ADD_ITEM":
      return addItem(state, action)
    case "REMOVE_ITEM":
      return removeItem(state, action)
    default:
      throw new Error()
  }
}

export const FormStateProvider = ({ children }) => {
  // set default items if not given
  const defaultItems = [generateMemberItem()]

  // init with given items and make a copy
  const [state, dispatch] = useReducer(reducer, {
    ...initialState,
    items: defaultItems,
  })

  return (
    <FormState.Provider value={state}>
      <FormDispatch.Provider value={dispatch}>{children}</FormDispatch.Provider>
    </FormState.Provider>
  )
}

export const useFormDispatch = () => React.useContext(FormDispatch)

export const useFormState = (itemID) => {
  const state = React.useContext(FormState)
  if (itemID === undefined) return state
  const index = state.items.findIndex((item) => item.id === itemID)
  if (index < 0) return null
  return state.items[index]
}

export const generateMemberItem = () => {
  return {
    id: uniqueId("member_"),
    name: "",
    address: "",
    protocol_port: "",
    monitor_address: "",
    monitor_port: "",
    weight: "1",
    backup: false,
    tags: "",
    admin_state_up: true,
  }
}
