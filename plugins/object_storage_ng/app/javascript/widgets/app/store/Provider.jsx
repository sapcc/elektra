// StoreProvider.jsx
import React, { createContext, useContext } from "react"
import createStore from "./index"
import { useStore as useZustandStore } from "zustand"

// Create a Store Context
const StoreContext = createContext()

const getStore = () => {
  const store = useContext(StoreContext)
  if (!store) {
    throw new Error("Missing StoreProvider")
  }
  return { ...store.use }
}

// Create the Store Provider component
const StoreProvider = ({ children }) => (
  // The store is created when this component is mounted
  <StoreContext.Provider value={createStore()}>
    {children}
  </StoreContext.Provider>
)

export default StoreProvider
export { getStore }
