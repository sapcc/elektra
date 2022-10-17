import React from "react"
// import { Modal, Button } from "react-bootstrap"
import { useHistory, useLocation, useParams } from "react-router-dom"
import { useGlobalState } from "../StateProvider"

import {
  Panel,
  PanelBody,
  DataGrid,
  DataGridRow,
  DataGridCell,
  DataGridHeadCell,
} from "juno-ui-components"

const Row = ({ label, value, children }) => {
  return (
    <DataGridRow>
      <DataGridHeadCell>{label}</DataGridHeadCell>
      <DataGridCell>{value || children}</DataGridCell>
    </DataGridRow>
  )
}

const SecretDetailsForm = () => {
  const location = useLocation()
  const history = useHistory()
  const params = useParams()
  const [secretsState] = useGlobalState()
  const secret = React.useMemo(
    () =>
      secretsState.secrets.items.find(
        (i) => i.secret_ref.indexOf(params.id) >= 0
      ),
    [secretsState.secrets, params.id]
  )

  const [show, setShow] = React.useState(!!secret)
  const mounted = React.useRef(false)

  React.useEffect(() => {
    mounted.current = true
    setShow(!!params.id)
    return () => (mounted.current = false)
  }, [params.id])

  const restoreURL = React.useCallback(() => {
    history.replace(
      location.pathname.replace(/^(\/[^/]*)\/.+\/show$/, (a, b) => b)
    )
  }, [history, location])

  const close = React.useCallback(() => {
    setShow(false)
    restoreURL()
  }, [restoreURL])

  return (
    <Panel
      opened={show}
      onClose={close}
      heading={`Secret ${secret ? secret.name : ""}`}
    >
      <PanelBody>
        {secret ? (
          <DataGrid columns={4}>
            <Row label="Name" value={secret.name} />
            <Row label="Type" value={secret.type} />
            <Row label="Content Types" value={secret.contentTypes} />
            <Row label="Status" value={secret.status} />
          </DataGrid>
        ) : (
          <span>Secret {params.id} not found</span>
        )}
      </PanelBody>
    </Panel>
  )
}

export default SecretDetailsForm
