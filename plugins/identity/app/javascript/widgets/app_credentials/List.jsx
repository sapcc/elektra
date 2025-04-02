import React from "react"
import apiClient from "./apiClient"
import { DataGrid, DataGridRow, DataGridCell, DataGridHeadCell } from "@cloudoperators/juno-ui-components"
import HintLoading from "../../../../../keymanagerng/app/javascript/widgets/app/components/HintLoading"

const AppCredentialsList = ({ userId }) => {
  const [items, setItems] = React.useState([])
  const [isLoading, setIsLoading] = React.useState(true)
  const [error, setError] = React.useState(null)

  // fetch the items from the api
  React.useEffect(() => {
    apiClient
      .get(`users/${userId}/application_credentials`)
      .then((response) => {
        console.log("response", response.data.application_credentials)
        setItems(response.data.application_credentials)
        //setItems(response.data.credentials)
      })
      .catch((error) => {
        setError(error.message)
      })
      .finally(() => {
        setIsLoading(false)
      })
  }, [])

  return (
    <>
      {isLoading && !error && !items ? (
        <HintLoading />
      ) : (
        <div>
          <h1>App Credentials</h1>
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
                <DataGridRow key={index}>
                  <DataGridCell>{!item.name ? "-" : item.name}</DataGridCell>
                  <DataGridCell>{!item.description ? "-" : item.description}</DataGridCell>
                  <DataGridCell>{!item.expire_at ? "-" : item.expire_at}</DataGridCell>
                  <DataGridCell>
                    <a href={`/app_credentials/${item.id}`}>View</a>
                  </DataGridCell>
                </DataGridRow>
              ))
            ) : (
              <DataGridRow>
                <DataGridCell colSpan={4}>No Application Credentials found...</DataGridCell>
              </DataGridRow>
            )}
          </DataGrid>
        </div>
      )}
    </>
  )
}

export default AppCredentialsList
