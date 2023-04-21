import React from "react"
import { create } from "zustand"

// global zustand store. See how this works here: https://github.com/pmndrs/zustand
const useStore = create((set) => ({
  showNewSecret: false,
  setShowNewSecret: (show) => set((state) => ({ showNewSecret: show })),
  showNewContainer: false,
  setShowNewContainer: (show) => set((state) => ({ showNewContainer: show })),
}))

export default useStore
