import { useStore } from "../StoreProvider"
import { apiClient } from "../../lib/apiClient"

export const useCapabilitiesData = () =>
  useStore((state) => state.capabilities.data)
export const useCapabilitiesIsFetching = () =>
  useStore((state) => state.capabilities.isFetching)

export const useCapabilitiesError = () =>
  useStore((state) => state.capabilities.error)

export const useCapabilitiesUpdatedAt = () =>
  useStore((state) => state.capabilities.updatedAt)

// load data from API and store it in the state. Manage also loading and error states
export const useCapabilitiesLoadOnce = () => {
  const updatedAt = useCapabilitiesUpdatedAt()
  const isFetching = useCapabilitiesIsFetching()
  const { request, receive, receiveError } = useStore(
    (state) => state.capabilities.actions
  )

  return (options = {}) => {
    if (isFetching || (updatedAt && options.reload !== true)) return

    request()
    apiClient
      .osApi("object-store")
      .get("info", { params: { path_prefix: "/" } })
      .then((response) => receive(response.data))
      .catch((error) => receiveError(error.message))
  }
}
