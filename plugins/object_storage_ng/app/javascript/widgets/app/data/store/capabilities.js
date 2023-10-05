import { produce } from "immer"

const initialState = {
  data: {},
  isFetching: false,
  error: null,
  updatedAt: null,
}

export const createCapabilitiesSlice = (set, get) => ({
  capabilities: {
    ...initialState,
    // mutations
    actions: {
      request: () =>
        set(
          produce((state) => {
            state.capabilities.isFetching = true
            state.capabilities.error = null
          }),
          false,
          "capabilities.request"
        ),
      receive: (data) =>
        set(
          produce((state) => {
            state.capabilities.isFetching = false
            state.capabilities.data = data
            state.capabilities.updatedAt = Date.now()
          }),
          false,
          "capabilities.receive"
        ),

      receiveError: (error) =>
        set(
          produce((state) => {
            state.capabilities.isFetching = false
            state.capabilities.error = error
          }),
          false,
          "capabilities.receiveError"
        ),
    },
  },
})
