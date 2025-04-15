import React, { useEffect } from "react"
import { getApiClient } from "./apiClient"
import {
  DataGrid,
  DataGridRow,
  DataGridCell,
  DataGridHeadCell,
  ButtonRow,
  DataGridToolbar,
  Button,
  Stack,
  SearchInput,
  Message,
} from "@cloudoperators/juno-ui-components"
import { Link } from "react-router-dom"
import Loading from "./Loading"
import ListItem from "./ListItem"

const AppCredentialsList = ({ userId, refreshRequestedAt }) => {
  const [items, setItems] = React.useState([])
  const [isLoading, setIsLoading] = React.useState(true)
  const [error, setError] = React.useState(null)
  const [searchText, setSearchText] = React.useState("")

  const filteredData = React.useMemo(() => {
    if (!items) return []
    return items.filter((entry) => {
      if (!searchText) return true
      return (
        // Check if the search text is present in the resource name, id, type or service type
        entry.name?.includes(searchText) || entry.id?.includes(searchText) || entry.description?.includes(searchText)
      )
    })
  }, [items, searchText])

  // fetch the items from the api
  React.useEffect(() => {
    getApiClient()
      .get(`users/${userId}/application_credentials`)
      .then((response) => {
        console.log("items response", response.data.application_credentials)
        setItems(response.data.application_credentials)
      })
      .catch((error) => {
        setError(error.message)
      })
      .finally(() => {
        setIsLoading(false)
      })
  }, [refreshRequestedAt])

  // delete the item from the api
  const handleDelete = (id) => {
    getApiClient()
      .delete(`users/${userId}/application_credentials/${id}`)
      .then(() => {
        setItems((prevItems) => prevItems.filter((item) => item.id !== id))
      })
      .catch((error) => {
        setError(error.message)
      })
  }

  return (
    <>
      <DataGridToolbar
        search={
          <Stack alignment="center">
            <SearchInput
              placeholder="Search by name, id or description"
              onChange={(e) => setSearchText(e.target.value)}
              onClear={() => setSearchText("")}
            />
          </Stack>
        }
      >
        <ButtonRow>
          <Link to="/new">
            <Button>New</Button>
          </Link>
        </ButtonRow>
      </DataGridToolbar>
      {error && <Message variant="error" text={error} />}
      {isLoading && !error && !items ? (
        <Loading />
      ) : (
        <div>
          <DataGrid columns={4} minContentColumns={[4]}>
            <DataGridRow>
              <DataGridHeadCell>Name</DataGridHeadCell>
              <DataGridHeadCell>Description</DataGridHeadCell>
              <DataGridHeadCell>Expiration</DataGridHeadCell>
              <DataGridHeadCell></DataGridHeadCell>
            </DataGridRow>
            {filteredData.length > 0 ? (
              filteredData.map((item, index) => (
                <ListItem key={item.id} item={item} index={index} handleDelete={() => handleDelete(item.id)} />
              ))
            ) : (
              <DataGridRow>
                <DataGridCell colSpan={4}>No Application Credentials found, create a new one 🚀</DataGridCell>
              </DataGridRow>
            )}
          </DataGrid>
        </div>
      )}
    </>
  )
}

export default AppCredentialsList
