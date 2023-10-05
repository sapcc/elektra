// StoreProvider.jsx
import React, { createContext, useContext } from "react"
import createStore from "./store/index"
import { useStore as useZustandStore } from "zustand"

// Create a Store Context
const StoreContext = createContext()

const useStore = (selector) => {
  const store = useContext(StoreContext)
  if (!store) {
    throw new Error("Missing StoreProvider")
  }
  return useZustandStore(store, selector)
}

// export const useState = (key) => {
//   useStore((state) => key.split(".").reduce((acc, curr) => acc[curr], state))
// }

export const useState = (slice, key) => {
  useStore((state) => state[slice][key])
}

// Create the Store Provider component
const StoreProvider = ({ children }) => (
  // The store is created when this component is mounted
  <StoreContext.Provider value={createStore()}>
    {children}
  </StoreContext.Provider>
)

export default StoreProvider
export { useStore }
