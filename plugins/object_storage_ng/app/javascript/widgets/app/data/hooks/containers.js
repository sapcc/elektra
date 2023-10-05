import { useStore } from "../StoreProvider"
import { apiClient } from "../../lib/apiClient"
// import { encode,decode } from "../../lib/urlHelper"

export const useContainersItems = () =>
  useStore((state) => state.containers.items)

export const useContainersFilteredItems = () =>
  useStore((state) => state.containers.filteredItems)

export const useContainersIsFetching = () =>
  useStore((state) => state.containers.isFetching)

export const useContainersError = () =>
  useStore((state) => state.containers.error)

export const useContainersUpdatedAt = () =>
  useStore((state) => state.containers.updatedAt)

export const useContainersActions = () =>
  useStore((state) => state.containers.actions)

export const useContainersItem = (containerName) =>
  useStore((state) => state.containers.items?.[containerName])

// load data from API and store it in the state. Manage also loading and error states
export const useContainersLoadOnce = () => {
  const updatedAt = useContainersUpdatedAt()
  const isFetching = useContainersIsFetching()
  const { request, receive, receiveError } = useStore(
    (state) => state.containers.actions
  )

  return (options = {}) => {
    if (isFetching || (updatedAt && options.reload !== true)) return

    request()
    apiClient
      .osApi("object-store")
      .get("")
      .then((response) => {
        receive(response.data)
      })
      .catch((error) => receiveError(error.message))
  }
}

export const useContainersLoadMetadata = () => {
  const { requestItemUpdate, receiveItemUpdate, receiveItemError } =
    useContainersActions()

  return (containerName) => {
    requestItemUpdate()
    apiClient
      .osApi("object-store")
      .head(encodeURI(containerName))
      .then((response) => {
        const metadata = response.headers
        Object.keys(metadata).forEach(
          (k) => (metadata[k] = decodeURIComponent(metadata[k]))
        )
        const date = new Date(metadata["x-last-modified"])
        receiveItemUpdate(containerName, {
          bytes: metadata["x-container-bytes-used"],
          count: metadata["x-container-object-count"],
          last_modified: date || metadata["x-last-modified"],
          metadata,
        })
      })
      .catch((error) => receiveItemError(containerName, error.message))
  }
}

export const useContainersUpdateMetadata = () => {
  return (containerName, headers) => {
    const newHeaders = { ...headers }
    Object.keys(newHeaders).forEach(
      (k) =>
        k &&
        k.indexOf("x-container-meta") === 0 &&
        (newHeaders[k] = encodeURIComponent(newHeaders[k]))
    )

    return apiClient
      .osApi("object-store")
      .post(containerPath(containerName), {}, { headers: newHeaders })
  }
}
