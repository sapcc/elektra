import { produce } from "immer"

const initialState = {
  continerName: null,
  path: null,
  items: [],
  isFetching: false,
  error: null,
  updatedAt: null,
}

export const createObjectsSlice = (set) => ({
  account: {
    ...initialState,
    // mutations
    actions: {
      request: (containerName, path) =>
        set(
          produce((state) => {
            state.objects.containerName = containerName
            state.objects.path = path
            state.objects.isFetching = true
            state.objects.error = null
          }),
          false,
          "objects.request"
        ),
      receive: (items) =>
        set(
          produce((state) => {
            state.objects.isFetching = false
            state.objects.items = items
            state.objects.updatedAt = Date.now()
          }),
          false,
          "objects.receive"
        ),

      receiveError: (error) =>
        set(
          produce((state) => {
            state.objects.isFetching = false
            state.objects.error = error
          }),
          false,
          "objects.receiveError"
        ),
    },
  },
})
