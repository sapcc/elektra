import { produce } from "immer"

const initialState = {
  data: {},
  isFetching: false,
  error: null,
  updatedAt: null,
}

export const createAccountSlice = (set) => ({
  account: {
    ...initialState,
    // mutations
    actions: {
      request: () =>
        set(
          produce((state) => {
            state.account.isFetching = true
            state.account.error = null
          }),
          false,
          "account.request"
        ),
      receive: (data) =>
        set(
          produce((state) => {
            state.account.isFetching = false
            state.account.data = data
            state.account.updatedAt = Date.now()
          }),
          false,
          "account.receive"
        ),

      receiveError: (error) =>
        set(
          produce((state) => {
            state.account.isFetching = false
            state.account.error = error
          }),
          false,
          "account.receiveError"
        ),
    },
  },
})
