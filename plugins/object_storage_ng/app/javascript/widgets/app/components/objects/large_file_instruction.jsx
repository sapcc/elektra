import React from "react"
import PropTypes from "prop-types"
import { Modal, Button } from "react-bootstrap"
import { Form } from "lib/elektra-form"
import { useHistory, useParams, useRouteMatch } from "react-router-dom"
import useUrlParamEncoder from "../../hooks/useUrlParamEncoder"
import { useDispatch } from "../../stateProvider"

const LargeFileInstruction = ({ mode, continerName, name }) => {
  const history = useHistory()
  const [show, setShow] = React.useState(true)
  const [error, setError] = React.useState()
  const [loading, setLoading] = React.useState(false)
  const [submitting, setSubmitting] = React.useState(false)
  const dispatch = useDispatch()

  const validate = React.useCallback((values) => !!values.name, [])

  const close = React.useCallback(() => {
    setError(null)
    setLoading(false)
    setSubmitting(false)
    setShow(false)
  }, [])

  return (
    <Modal
      show={show}
      onHide={close}
      bsSize="large"
      aria-labelledby="contained-modal-title-lg"
    >
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">
          Instructions for {mode === "download" ? "downloading" : "uploading"}{" "}
          the file
        </Modal.Title>
      </Modal.Header>

      <Modal.Body>{mode}</Modal.Body>
      <Modal.Footer>
        <Button onClick={close}>Cancel</Button>
        <Form.SubmitButton label="Create folder" />
      </Modal.Footer>
    </Modal>
  )
}

LargeFileInstruction.propTypes = {
  mode: PropTypes.string.isRequired,
  containerName: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
}

export default LargeFileInstruction
