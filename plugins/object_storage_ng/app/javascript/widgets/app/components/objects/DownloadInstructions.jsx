import React from "react"
import PropTypes from "prop-types"
import { Modal, Button } from "react-bootstrap"
import { useHistory, useParams } from "react-router-dom"
import useActions from "../../hooks/useActions"
import { Unit } from "lib/unit"
import { LIMIT } from "./config"
const unit = new Unit("B")

const DeleteConfirmation = ({ onConfirm, onCancel }) => {
  const history = useHistory()
  const [show, setShow] = React.useState(true)
  let { name: containerName, objectPath, object: name } = useParams()

  const cancel = React.useCallback(() => {
    if (onCancel) onCancel()
    setShow(false)
  }, [])

  const confirm = React.useCallback(() => {
    if (onConfirm) onConfirm()
    setShow(false)
  }, [])

  const back = React.useCallback(() => {
    let path = `/containers/${containerName}/objects`
    if (objectPath && objectPath !== "") path += `/${objectPath}`
    history.replace(path)
  }, [containerName, objectPath])

  return (
    <Modal
      show={show}
      onHide={close}
      onExit={back}
      bsSize="large"
      aria-labelledby="contained-modal-title-lg"
    >
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">
          Instructions for downloading large file
        </Modal.Title>
      </Modal.Header>

      <Modal.Body>
        <div className="bs-callout bs-callout-info">
          {!containerName || !name ? (
            <>
              Object {containerName}/{name} does not exist.
            </>
          ) : (
            <p>This object will be irrevocably deleted</p>
          )}
        </div>
      </Modal.Body>
      <Modal.Footer>
        <Button onClick={cancel}>Cancel</Button>
        <Button bsStyle="primary" onClick={confirm}>
          Confirm
        </Button>
      </Modal.Footer>
    </Modal>
  )
}

DeleteConfirmation.propTypes = {
  onConfirm: PropTypes.func,
  onCancel: PropTypes.func,
}

export default DeleteConfirmation
