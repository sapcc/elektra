import React from "react"
import { Modal, Button } from "react-bootstrap"
import { Form, TextInputRow, SelectRow, SelectOption } from "juno-ui-components"
import { useHistory, useLocation } from "react-router-dom"
import apiClient from "../../apiClient"
import { useGlobalState } from "../StateProvider"

const NewContainer = () => {
  const location = useLocation()
  const history = useHistory()
  const [_, dispatch] = useGlobalState()
  const [show, setShow] = React.useState(true)
  const mounted = React.useRef(false)

  React.useEffect(() => {
    mounted.current = true
    return () => (mounted.current = false)
  }, [])

  const onSubmit = React.useCallback(
    (values) => {
      apiClient
        .post("keymanagerng-api/containers", { entry: values })
        .then((response) => response.data)
        .then(
          (container) =>
            mounted.current &&
            dispatch({ type: "RECEIVE_CONTAINERS", container })
        )
        .then(close)
        .catch(
          (error) =>
            mounted.current &&
            dispatch({
              type: "REQUEST_CONTAINERS_FAILURE",
              error: error.message,
            })
        )
    },
    [dispatch]
  )

  const close = React.useCallback(() => {
    setShow(false)
  }, [])

  const restoreURL = React.useCallback(
    () => history.replace(location.pathname.replace("/new", "")),
    [history, location]
  )

  const validate = React.useCallback((values) => !!values.name)

  return (
    <Modal
      show={show}
      onHide={close}
      onExited={restoreURL}
      bsSize="large"
      aria-labelledby="contained-modal-title-lg"
    >
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">New Container</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <Form
          className="form form-horizontal"
          validate={validate}
          onSubmit={onSubmit}
        >
          <TextInputRow
            label="Name"
            name="name"
            required="true"
            variant="stacked"
            placeholder="Enter name"
          />
          <SelectRow label="Container Type">
            <SelectOption label="Certificate" value="" />
            <SelectOption label="Generic" value="" />
            <SelectOption label="Rsa" value="" />
          </SelectRow>
          <SelectRow label="Secrets" items=""></SelectRow>
        </Form>
      </Modal.Body>
      <Modal.Footer>
        <Button onClick={close}>Cancel</Button>
        <Button onClick={onSubmit}>Create</Button>
      </Modal.Footer>
    </Modal>
  )
}

export default NewContainer
