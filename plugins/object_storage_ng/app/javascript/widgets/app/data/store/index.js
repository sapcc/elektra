import { createStore, useStore } from "zustand"
import { devtools } from "zustand/middleware"

import { createAccountSlice } from "./account"
import { createCapabilitiesSlice } from "./capabilities"
import { createContainersSlice } from "./containers"
// import { createObjectsSlice } from "./objects"

// Initialize a store for managing named slices of state.
const store = (set, get, api) => ({
  ...createAccountSlice(set, get, api),
  ...createCapabilitiesSlice(set, get, api),
  ...createContainersSlice(set, get, api),
})

// const createSelectors = (store) => {
//   store.use = {}
//   for (const sliceName of Object.keys(store.getState())) {
//     store.use[sliceName] = {}
//     for (const selectorName of Object.keys(store.getState()[sliceName])) {
//       store.use[sliceName][selectorName] = () =>
//         useStore(store, (s) => s[sliceName][selectorName])
//     }
//   }
//   return store
// }

export default () => createStore(devtools(store))
