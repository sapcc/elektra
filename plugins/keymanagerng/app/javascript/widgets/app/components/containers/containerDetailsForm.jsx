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

const ContainerDetailsForm = () => {
  const location = useLocation()
  const history = useHistory()
  const params = useParams()
  const [containersState] = useGlobalState()
  const container = React.useMemo(
    () =>
      containersState.containers.items.find(
        (i) => i.container_ref.indexOf(params.id) >= 0
      ),
    [containersState.containers, params.id]
  )

  const [show, setShow] = React.useState(!!container)
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
      heading={`Container ${container ? container.name : ""}`}
    >
      <PanelBody>
        {container ? (
          <DataGrid columns={3}>
            <Row label="Name" value={container.name} />
            <Row label="Type" value={container.type} />
            <Row label="Status" value={container.status} />
          </DataGrid>
        ) : (
          <span>Container {params.id} not found</span>
        )}
      </PanelBody>
    </Panel>
  )
}

export default ContainerDetailsForm
