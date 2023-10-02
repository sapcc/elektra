import { combine } from "zustand/middleware"

export default combine({ data: [], isFetching: false }, (set, get) => ({
  setData: (data) => set(() => ({ data })),
  setIsFetching: (bool) => set(() => ({ isFetching: bool })),
}))
