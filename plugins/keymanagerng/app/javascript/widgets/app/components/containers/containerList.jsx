import React from "react"
import { Link } from "react-router-dom"
import { policy } from "lib/policy"
import { SearchField } from "lib/components/search_field"
import ContainerListItem from "./containerListItem"
import apiClient from "../../apiClient"
import { useGlobalState } from "../StateProvider"
// import { QueryClient, QueryClientProvider } from "react-query"

import {
  Button,
  DataGrid,
  DataGridRow,
  DataGridCell,
  DataGridHeadCell,
  DataGridToolbar,
  Spinner,
} from "juno-ui-components"

const Containers = () => {
  const [filterTerm, setFilterTerm] = React.useState(null)
  const [{ containers: containersState }, dispatch] = useGlobalState()
  const mounted = React.useRef(false)

  React.useEffect(() => {
    mounted.current = true
    return () => (mounted.current = false)
  }, [])

  React.useEffect(() => {
    if (containersState.loaded || containersState.isFetching) return

    dispatch({ type: "REQUEST_CONTAINERS" })
    apiClient
      .osApi("key-manager")
      .get("/v1/containers")
      .then((response) => response.data)
      .then(
        (data) =>
          mounted.current &&
          dispatch({ type: "RECEIVE_CONTAINERS", containers: data.containers })
      )
      .catch(
        (error) =>
          mounted.current &&
          dispatch({ type: "REQUEST_CONTAINERS_FAILURE", error: error.message })
      )
  }, [dispatch, containersState])

  const handleDelete = React.useCallback(
    (id) => {
      dispatch({ type: "REQUEST_DELETE_CONTAINERS", id })
      apiClient
        .osApi("key-manager")
        .del(`v1/containers/${id}`)
        .then(
          () => mounted.current && dispatch({ type: "DELETE_CONTAINERS", id })
        )
        .catch(
          (error) =>
            mounted.current &&
            dispatch({
              type: "DELETE_CONTAINERS_FAILURE",
              id,
              error: error.message,
            })
        )
    },
    [dispatch]
  )

  const filteredContainers = React.useMemo(() => {
    if (!containersState.items || containersState.items.length === 0) return []
    if (!filterTerm || filterTerm === "") return containersState.items
    return containersState.items.filter(
      (item) =>
        (item.name && item.name.indexOf(filterTerm) >= 0) ||
        (item.type && item.type.indexOf(filterTerm) >= 0) ||
        (item.status && item.status.indexOf(filterTerm) >= 0)
    )
  }, [containersState.items, filterTerm])

  return (
    <>
      <DataGridToolbar
        search={
          <SearchField
            variant="juno"
            onChange={setFilterTerm}
            placeholder="Name or Type or Status"
            text="Searches by Name or Type or Status in visible containers list only.
                Entering a search term will automatically start loading the next pages
                and filter the loaded containers using the search term. Emptying the search
                input field will show all currently loaded containers."
          />
        }
      >
        {policy.isAllowed("keymanagerng:container_create") && (
          <Link to="/containers/newcontainer">
            <Button>New Container</Button>
          </Link>
        )}
      </DataGridToolbar>

      {!policy.isAllowed("keymanagerng:container_list") ? (
        <span>You are not allowed to see this page</span>
      ) : containersState.isFetching ? (
        <Spinner variant="primary" />
      ) : (
        <DataGrid columns={4} minContentColumns={[5]}>
          <DataGridRow>
            <DataGridHeadCell>Name</DataGridHeadCell>
            <DataGridHeadCell>Type</DataGridHeadCell>
            <DataGridHeadCell>Status</DataGridHeadCell>
            <DataGridHeadCell></DataGridHeadCell>
          </DataGridRow>
          {filteredContainers && filteredContainers.length > 0 ? (
            filteredContainers.map((container, index) => (
              <ContainerListItem
                key={index}
                container={container}
                handleDelete={handleDelete}
              />
            ))
          ) : (
            <DataGridRow>
              <DataGridCell colSpan={4}>No containers found.</DataGridCell>
            </DataGridRow>
          )}
        </DataGrid>
      )}
    </>
  )
}

export default Containers
