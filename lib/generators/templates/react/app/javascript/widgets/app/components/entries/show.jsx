import React from "react"
import { Modal, Button } from "react-bootstrap"
import { Form } from "lib/elektra-form"
import { useHistory, useLocation, useParams } from "react-router-dom"
import * as client from "../../client"
import { useGlobalState } from "../StateProvider"

const Row = ({ label, value, children }) => {
  return (
    <tr>
      <th style={{ width: "30%" }}>{label}</th>
      <td>{value || children}</td>
    </tr>
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

  const close = React.useCallback(() => {
    setShow(false)
  }, [])

  const restoreURL = React.useCallback(() => {
    history.replace(
      location.pathname.replace(/^(\/[^/]*)\/.+\/show$/, (a, b) => b)
    )
  }, [history, location])

  return (
    <Modal
      show={show}
      onHide={close}
      onExited={restoreURL}
      bsSize="large"
      aria-labelledby="contained-modal-title-lg"
    >
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">
          Entry {entry ? entry.name : ""}
        </Modal.Title>
      </Modal.Header>
      <Modal.Body>
        {entry ? (
          <table className="table no-borders">
            <tbody>
              <Row label="Name" value={entry.name} />
              <Row label="Description" value={entry.description} />
              <Row label="ID" value={entry.id} />
            </tbody>
          </table>
        ) : (
          <span>Entry {params.id} not found</span>
        )}
      </Modal.Body>
      <Modal.Footer>
        <Button onClick={close}>Close</Button>
      </Modal.Footer>
    </Modal>
  )
}

export default Show
