import { createStore } from "zustand"
import { devtools } from "zustand/middleware"

import { createAccountSlice } from "./account"
import { createCapabilitiesSlice } from "./capabilities"
import { createContainersSlice } from "./containers"
// import { createObjectsSlice } from "./objects"

import createTestSlice from "./test"

// // Function to create a store for managing named state slices.
// const namedSlicesStore = (slices) => (set, get, api) => {
//   // Helper function for updating a slice's state.
//   const nestedSetFunc = (name) => (newState, replace, actionName) => {
//     // Retrieve the current state of the specified slice.
//     const sliceState = get()[name]

//     // Apply newState as a function to the current state if it's a function.
//     if (typeof newState === "function") newState = newState(sliceState)

//     // Create the new slice state by either replacing or merging with the current state.
//     const newSliceState = replace ? newState : { ...sliceState, ...newState }

//     // Update the state and log the action (with an optional action name, defaulting to "unknownAction").
//     return set(
//       { [name]: newSliceState },
//       false,
//       `${name}.${actionName || "unknownAction"}`
//     )
//   }

//   // Initialize and return slices.
//   return Object.keys(slices).reduce((store, name) => {
//     store[name] = slices[name](nestedSetFunc(name), get, api)
//     return store
//   }, {})
// }

// const createSelectors = (_store) => {
//   let store = _store
//   console.log(":::::::::::::", store)
//   store.use = {}
//   for (let sliceName of Object.keys(store.getState())) {
//     store.use[sliceName] = {}
//     for (let k of Object.keys(store.getState()[sliceName])) {
//       store.use[sliceName][k] = () => store((s) => s.account.actions)
//     }
//   }

//   return store
// }

const createSlicedSelectors = (store) => {
  const state = store.getState()
  store.use = {}
  for (const sliceName of Object.keys(state)) {
    store.use[sliceName] = {}
    for (let k of Object.keys(state[sliceName])) {
      store.use[sliceName][k] = () => store.getState()[sliceName][k]
    }
  }

  return store
}

// Initialize a store for managing named slices of state.
const store = (set, get, api) => ({
  ...createAccountSlice(set, get, api),
  ...createCapabilitiesSlice(set, get, api),
  ...createContainersSlice(set, get, api),
  test: { ...createTestSlice(set, get, api) },
})

console.log(">>>store", store)
export default () => createSlicedSelectors(createStore(devtools(store)))
