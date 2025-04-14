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
  Icon,
  Modal,
} from "@cloudoperators/juno-ui-components"
import { Link } from "react-router-dom"
import HintLoading from "./Loading"
import ListItem from "./ListItem"

const AppCredentialsList = ({ userId, refreshRequestedAt }) => {
  const [items, setItems] = React.useState([])
  const [isLoading, setIsLoading] = React.useState(true)
  const [error, setError] = React.useState(null)

  // fetch the items from the api
  React.useEffect(() => {
    getApiClient()
      .get(`users/${userId}/application_credentials`)
      .then((response) => {
        console.log("response", response.data.application_credentials)
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
            <SearchInput placeholder="Search by name" />
          </Stack>
        }
      >
        <ButtonRow>
          <Link to="/new">
            <Button>New</Button>
          </Link>
        </ButtonRow>
      </DataGridToolbar>

      {isLoading && !error && !items ? (
        <HintLoading />
      ) : (
        <div>
          {error && <div>Error: {error}</div>}
          <DataGrid columns={4} minContentColumns={[4]}>
            <DataGridRow>
              <DataGridHeadCell>Name</DataGridHeadCell>
              <DataGridHeadCell>Description</DataGridHeadCell>
              <DataGridHeadCell>Expiration</DataGridHeadCell>
              <DataGridHeadCell></DataGridHeadCell>
            </DataGridRow>
            {items && items.length > 0 ? (
              items.map((item, index) => (
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
