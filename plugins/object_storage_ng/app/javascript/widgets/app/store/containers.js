const initialState = {
  items: [],
  isFetching: false,
  error: null,
  updatedAt: null,
}

export const createContainersSlice = (set, get, api) => ({
  containers: {
    ...initialState,
    // mutations
    actions: {
      // new state, replace or merge: true or false, action name
      requestItems: () =>
        set({ isFetching: true, error: null }, false, "requestItems"),
      receiveItems: (items) =>
        set(
          { items, isFetching: false, updatedAt: Date.now() },
          false,
          "receiveItems"
        ),
      receiveError: (error) =>
        set({ isFetching: false, error }, false, "receiveError"),
      removeItem: (name) =>
        set((state) => {
          const items = state.items.slice()
          const index = items.findIndex((i) => i.name === name)
          if (index >= 0) items.splice(index, 1)
          return { items, isFetching: false }, false, "removeItem"
        }),
    },
    receiveItem: (item) => {
      set(
        (state) => {
          const items = state.items.slice()
          const index = state.items.findIndex((i) => i.name === item.name)
          if (index >= 0) {
            items[index] = item
          } else {
            items.unshift(item)
          }
          return { items, isFetching: false }
        },
        false,
        "receiveItem"
      )
    },

    // loadContainerMetadata:
    //   (containerName) => {
    //     return apiClient
    //       .osApi("object-store")
    //       .head(containerPath(containerName))
    //       .then((response) => {
    //         const metadata = response.headers
    //         Object.keys(metadata).forEach(
    //           (k) => (metadata[k] = decodeURIComponent(metadata[k]))
    //         )
    //         const date = new Date(metadata["x-last-modified"])
    //         dispatch({
    //           type: "RECEIVE_CONTAINER",
    //           item: {
    //             name: containerName,
    //             bytes: metadata["x-container-bytes-used"],
    //             count: metadata["x-container-object-count"],
    //             last_modified: date || metadata["x-last-modified"],
    //             metadata,
    //           },
    //         })
    //         return metadata
    //       })
    //   }
    // ),
    // updateContainerMetadata:
    //   (containerName, headers) => {
    //     const newHeaders = { ...headers }
    //     Object.keys(newHeaders).forEach(
    //       (k) =>
    //         k &&
    //         k.indexOf("x-container-meta") === 0 &&
    //         (newHeaders[k] = encodeURIComponent(newHeaders[k]))
    //     )

    //     return apiClient
    //       .osApi("object-store")
    //       .post(containerPath(containerName), {}, { headers: newHeaders })
    //   }
    // )
  },
})
