import React from "react"
import {
  Panel,
  PanelBody,
  Stack,
  Message,
  DataGrid,
  DataGridRow,
  DataGridHeadCell,
  DataGridCell,
} from "@cloudoperators/juno-ui-components"
import { useParams } from "react-router-dom"
import { getApiClient } from "./apiClient"
import { useHistory, useLocation } from "react-router-dom"
import Loading from "./Loading"

const DetailsRow = ({ label, value }) => {
  return (
    <DataGridRow>
      <DataGridHeadCell>{label}</DataGridHeadCell>
      <DataGridCell className="tw-break-all">{value}</DataGridCell>
    </DataGridRow>
  )
}

const Show = ({ userId }) => {
  const { id } = useParams()
  //console.log("userId", userId)
  //console.log("id", id)
  const location = useLocation()
  const history = useHistory()
  const [item, setItem] = React.useState({})
  const [isLoading, setIsLoading] = React.useState(true)
  const [error, setError] = React.useState(null)

  // fetch the items from the api
  React.useEffect(() => {
    getApiClient()
      .get(`users/${userId}/application_credentials/${id}`)
      .then((response) => {
        //console.log("item response", response.data.application_credential)
        setItem(response.data.application_credential)
      })
      .catch((error) => {
        setError(error.message)
      })
      .finally(() => {
        setIsLoading(false)
      })
  }, [id])

  const close = () => {
    history.replace(location.pathname.replace(/\/[^/]+\/show$/, ""))
  }

  return (
    <div>
      <Panel opened={true} onClose={close} heading="Show Application Credentials">
        <PanelBody>
          <Stack direction="vertical" gap="3">
            {error && <Message variant="error" text={error} />}
            {isLoading && !error && !item ? (
              <Loading />
            ) : (
              <div>
                <DataGrid columns={2}>
                  <DetailsRow label="Name" value={!item.name ? "-" : item.name} />
                  <DetailsRow label="ID" value={item?.id} />
                  <DetailsRow label="Description" value={!item.description ? "-" : item.description} />
                  <DetailsRow
                    label="Roles"
                    value={!item.roles ? "-" : item.roles.map((role) => role.name).join(", ")}
                  />
                  <DetailsRow
                    label="Expires At"
                    value={
                      !item.expires_at
                        ? "Unlimited"
                        : new Date(item.expires_at).toLocaleDateString("en-US", {
                            month: "long",
                            day: "numeric",
                            year: "numeric",
                          })
                    }
                  />
                </DataGrid>
              </div>
            )}
          </Stack>
        </PanelBody>
      </Panel>
    </div>
  )
}

export default Show
