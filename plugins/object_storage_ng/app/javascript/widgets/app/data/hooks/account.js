import { useStore } from "../StoreProvider"
import { apiClient } from "../../lib/apiClient"

export const useAccountData = () => useStore((state) => state.account.data)

export const useAccountIsFetching = () =>
  useStore((state) => state.account.isFetching)

export const useAccountError = () => useStore((state) => state.account.error)

export const useAccountUpdatedAt = () =>
  useStore((state) => state.account.updatedAt)

// load data from API and store it in the state. Manage also loading and error states
export const useAccountLoadDataOnce = () => {
  const updatedAt = useAccountUpdatedAt()
  const isFetching = useAccountIsFetching()
  const { request, receive, receiveError } = useStore(
    (state) => state.account.actions
  )

  return (options = {}) => {
    if (isFetching || (updatedAt && options.reload !== true)) return

    request()
    apiClient
      .osApi("object-store")
      .get("info", { params: { path_prefix: "/" } })
      .then((response) => {
        receive(response.data)
      })
      .catch((error) => receiveError(error.message))
  }
}
