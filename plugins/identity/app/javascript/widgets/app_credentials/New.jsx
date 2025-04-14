import React from "react"
import { Panel, PanelBody, Stack, Message } from "@cloudoperators/juno-ui-components"
import { useHistory, useLocation } from "react-router-dom"
import { getApiClient } from "./apiClient"
import { NewForm } from "./NewForm"
import { ResponseData } from "./ResponseData"

const NewAppCredentials = ({ userId, refreshList }) => {
  const location = useLocation()
  const history = useHistory()
  const [error, setError] = React.useState(null)
  const [isLoading, setIsLoading] = React.useState(false)
  const [responseData, setResponseData] = React.useState(null)

  const close = () => {
    history.replace(location.pathname.replace("/new", ""))
  }

  const handleSubmit = (formData) => {
    if (!formData.name || !formData.description) {
      setError("Name and Description are required.")
      return
    }
    setIsLoading(true)
    getApiClient()
      .post(`users/${userId}/application_credentials`, { application_credential: formData })
      .then(({ data }) => {
        setResponseData(data.application_credential)
        refreshList()
      })
      .catch((error) => {
        //console.log(JSON.stringify(error, null, 2))
        setError(error.data.error.error.message)
      })
      .finally(() => {
        setIsLoading(false)
      })
  }

  return (
    <Panel opened={true} onClose={close} heading="New Application Credentials">
      <PanelBody>
        <Stack direction="vertical" gap="3">
          {error && <Message variant="error" text={error} />}
          {isLoading && <Message variant="info" text="Creating credential..." />}

          {responseData ? (
            <ResponseData appCredential={responseData} onConfirm={close} />
          ) : (
            <>
              <NewForm
                onSubmit={(formData) => {
                  // this will trigger the handleSubmit function with data from the form
                  handleSubmit(formData)
                }}
                onCancel={close}
                setError={setError}
              />
            </>
          )}
        </Stack>
      </PanelBody>
    </Panel>
  )
}
export default NewAppCredentials
