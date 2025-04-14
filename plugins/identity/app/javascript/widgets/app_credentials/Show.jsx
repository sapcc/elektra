import React from "react"
import { Panel, PanelBody, Stack, Message } from "@cloudoperators/juno-ui-components"
import { useParams } from "react-router-dom"
import { getApiClient } from "./apiClient"
import { useHistory, useLocation } from "react-router-dom"

const Show = ({ userId }) => {
  const { id } = useParams()
  console.log("userId", userId)
  console.log("id", id)
  const location = useLocation()
  const history = useHistory()
  const [item, setItem] = React.useState([])
  const [isLoading, setIsLoading] = React.useState(true)
  const [error, setError] = React.useState(null)

  // fetch the items from the api
  React.useEffect(() => {
    getApiClient()
      .get(`users/${userId}/application_credentials/${id}`)
      .then((response) => {
        console.log("response", response.data.application_credential)
        setItem(response.data.application_credentials)
      })
      .catch((error) => {
        setError(error.message)
      })
      .finally(() => {
        setIsLoading(false)
      })
  }, [])

  const close = () => {
    history.replace(location.pathname.replace(/\/[^/]+\/show$/, ""))
  }

  return (
    <div>
      <Panel opened={true} onClose={close} heading="Show Application Credentials">
        <PanelBody></PanelBody>
      </Panel>
    </div>
  )
}

export default Show
