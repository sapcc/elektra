import React from "react"
// import { Modal, Button } from "react-bootstrap"
import { Form } from "lib/elektra-form"
import { useHistory, useLocation, useParams } from "react-router-dom"
import * as client from "../../client"
import { useGlobalState } from "../StateProvider"

import {
  Panel,
  PanelBody,
  PanelFooter,
  Button,
  DataList,
  DataListRow,
  DataListCell,
} from "juno-ui-components"

const Row = ({ label, value, children }) => {
  return (
    <DataListRow>
      <DataListCell>{label}</DataListCell>
      <DataListCell>{value || children}</DataListCell>
    </DataListRow>
  )
}

const Show = () => {
  const location = useLocation()
  const history = useHistory()
  const params = useParams()
  const [state] = useGlobalState()
  const entry = React.useMemo(
    () => state.entries.items.find((i) => i.id === params.id),
    [state.entries, params.id]
  )
  const [show, setShow] = React.useState(!!entry)
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
      heading={`Entry ${entry ? entry.name : ""}`}
    >
      <PanelBody
        footer={
          <PanelFooter>
            <Button onClick={close}>Close</Button>
          </PanelFooter>
        }
      >
        {entry ? (
          <DataList>
            <Row label="Name" value={entry.name} />
            <Row label="Description" value={entry.description} />
            <Row label="ID" value={entry.id} />
          </DataList>
        ) : (
          <span>Entry {params.id} not found</span>
        )}
      </PanelBody>
    </Panel>
  )
}

export default Show
