import { produce } from "immer"

const initialState = {
  items: [],
  filteredItems: [],
  searchTerm: null,
  isFetching: false,
  error: null,
  updatedAt: null,
}

const filterItemsBySearchTerm = (items, searchTerm) => {
  if (searchTerm === "" || searchTerm === null) return items
  else
    return items.filter(
      (item) => !searchTerm || (item.name && item.name.indexOf(searchTerm) >= 0)
    )
}

export const createContainersSlice = (set, get) => ({
  containers: {
    ...initialState,
    // mutations
    actions: {
      // new state, replace or merge: true or false, action name
      request: () =>
        set(
          produce((state) => {
            state.containers.isFetching = true
            state.containers.error = null
          }),
          false,
          "containers.request"
        ),
      receive: (items) =>
        set(
          produce((state) => {
            state.containers.items = items
            state.containers.isFetching = false
            state.containers.updatedAt = Date.now()
            state.containers.filteredItems = filterItemsBySearchTerm(
              items,
              state.containers.searchTerm
            )
          }),
          false,
          "containers.receive"
        ),
      receiveError: (error) =>
        set(
          produce((state) => {
            state.containers.isFetching = false
            state.containers.error = error
          }),
          false,
          "containers.receiveError"
        ),

      requestItemUpdate: (containerName) => {
        const items = get().containers.items.slice()
        const index = items.findIndex((c) => c.name === containerName)
        if (index < 0) return
        items[index] = { ...items[index], isFetching: true }
        set(
          produce((state) => {
            state.containers.items = items
          }),
          false,
          "containers.requestItemUpdate"
        )
      },

      receiveItemUpdate: (containerName, values) => {
        const items = get().containers.items.slice()
        const index = items.findIndex((c) => c.name === containerName)
        if (index < 0) {
          items.push({ ...values, name: containerName, isFetching: false })
        } else {
          items[index] = { ...items[index], ...values, isFetching: false }
        }

        set(
          produce((state) => {
            state.containers.items = items
          }),
          false,
          "containers.receiveItemUpdate"
        )
      },

      receiveItemError: (containerName, error) => {
        const items = get().containers.items.slice()
        const index = items.findIndex((c) => c.name === containerName)
        if (index < 0) {
          items.push({ name: containerName, isFetching: false, error })
        } else {
          items[index] = { ...items[index], isFetching: false, error }
        }

        set(
          produce((state) => {
            state.containers.items = items
          }),
          false,
          "containers.receiveItemError"
        )
      },

      remove: (name) =>
        set(
          produce((state) => {
            const items = state.items.slice()
            const index = items.findIndex((i) => i.name === name)
            if (index >= 0) items.splice(index, 1)
            state.containers.items = items
            state.containers.filteredItems = filterItemsBySearchTerm(
              items,
              state.containers.searchTerm
            )
          }),
          false,
          "containers.removeItem"
        ),

      add: (item) =>
        set(
          produce((state) => {
            const items = state.items.slice()
            const index = state.items.findIndex((i) => i.name === item.name)
            if (index >= 0) {
              items[index] = item
            } else {
              items.unshift(item)
            }
            state.containers.items = items
            state.containers.filteredItems = filterItemsBySearchTerm(
              items,
              state.containers.searchTerm
            )
          }),
          false,
          "containers.receiveItem"
        ),

      setSearchTerm: (searchTerm) =>
        set(
          produce((state) => {
            state.containers.searchTerm = searchTerm
            state.containers.filteredItems = filterItemsBySearchTerm(
              state.containers.items,
              searchTerm
            )
          }),
          false,
          "containers.setSearchTermAndItems"
        ),
    },
  },
})
