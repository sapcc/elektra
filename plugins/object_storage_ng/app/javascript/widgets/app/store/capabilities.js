import { apiClient } from "../lib/apiClient"
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
      loadCapabilitiesOnce: (options = {}) => {
        const updatedAt = get().capabilities.updatedAt

        if (updatedAt && !options.reload) return

        set(
          produce((state) => {
            state.capabilities.isFetching = true
            state.capabilities.error = null
          }),
          false,
          "capabilities.request"
        )

        apiClient
          .osApi("object-store")
          .get("info", { params: { path_prefix: "/" } })
          .then((response) => {
            set(
              produce((state) => {
                state.capabilities.isFetching = false
                state.capabilities.data = response.data
                state.capabilities.updatedAt = Date.now()
              }),
              false,
              "capabilities.receive"
            )
          })
          .catch((error) =>
            set(
              produce((state) => {
                state.capabilities.isFetching = false
                state.capabilities.error = error
              }),
              false,
              "capabilities.receiveError"
            )
          )
      },
    },
  },
})
