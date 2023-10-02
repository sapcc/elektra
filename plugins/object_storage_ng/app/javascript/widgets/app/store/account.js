import { apiClient } from "../lib/apiClient"
import { produce } from "immer"

const initialState = {
  metaData: {},
  isFetching: false,
  error: null,
  updatedAt: null,
}

export const createAccountSlice = (set, get) => ({
  account: {
    ...initialState,
    // mutations
    actions: {
      loadMetadataOnce: (options = {}) => {
        const updatedAt = get().account.updatedAt
        const isFetching = get().account.isFetching

        if (updatedAt || isFetching || options.reload === false) return

        set(
          produce((state) => {
            state.account.isFetching = true
            state.account.error = null
          }),
          false,
          "account.fetchMetaData"
        )

        apiClient
          .osApi("object-store")
          .head("")
          .then((response) => {
            set(
              produce((state) => {
                state.account.isFetching = false
                ;(state.account.metaData = response.headers),
                  (state.account.updatedAt = new Date())
              }),
              false,
              "account.receiveMetaData"
            )
          })
          .catch((error) =>
            set(
              produce((state) => {
                state.account.isFetching = false
                state.account.error = error
              }),
              false,
              "account.error"
            )
          )
      },
    },
  },
})
