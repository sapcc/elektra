import React from "react"
import { Modal, Button } from "react-bootstrap"
import {
  Form,
  TextInputRow,
  TextareaRow,
  SelectRow,
  SelectOption,
} from "juno-ui-components"
// import { Form } from "lib/elektra-form"
import { useHistory, useLocation } from "react-router-dom"
import apiClient from "../../apiClient"
import { useGlobalState } from "../StateProvider"

const NewSecret = () => {
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
        .post("keymanagerng-api/secrets", { entry: values })
        .then((response) => response.data)
        .then(
          (item) =>
            mounted.current && dispatch({ type: "RECEIVE_SECRETS", item })
        )
        .then(close)
        .catch(
          (error) =>
            mounted.current &&
            dispatch({ type: "REQUEST_SECRETS_FAILURE", error: error.message })
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
        <Modal.Title id="contained-modal-title-lg">New Secret</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <Form className="form form-horizontal">
          <TextInputRow
            label="Name"
            name="name"
            placeholder="Enter name"
            required
          />
          <TextInputRow
            label="Expiration"
            name="expiration"
            type="number"
            helptext="If set, the secret will not be available after this time."
            required
          />
          <TextInputRow
            label="Bit length"
            name="Bit length"
            variant="stacked"
            placeholder="Enter bit length"
            helptext="Metadata for informational purposes. Value must be greater than zero."
          />
          <TextInputRow
            label="Algorithm"
            name="algorithm"
            variant="stacked"
            placeholder="Enter algorithm"
            helptext="Metadata for informational purposes."
          />
          <TextInputRow
            label="Mode"
            name="mode"
            variant="stacked"
            placeholder="Enter mode"
            helptext="Metadata for informational purposes."
          />
          <SelectRow label="Secret Type" required>
            <SelectOption
              label="certificate - Used for storing cryptographic certificates such as X.509 certificates"
              value="certificate - Used for storing cryptographic certificates such as X.509 certificates"
            />
            <SelectOption
              label="opaque - Used for backwards compatibility with previous versions of the API without typed secrets"
              value=""
            />
            <SelectOption
              label="passphrase - Used for storing plain text passphrases"
              value=""
            />
            <SelectOption
              label="private - Used for storing the private key of an asymmetric keypair"
              value=""
            />
            <SelectOption
              label="public - Used for storing the public key of an asymmetric keypair"
              value=""
            />
            <SelectOption
              label="symmetric - Used for storing byte arrays such as keys suitable for symmetric encryption"
              value=""
            />
          </SelectRow>
          <TextareaRow label="Payload" name="payload" required />
          <SelectRow label="Payload Content Type" required>
            <SelectOption label="text/plain" value="" />
            <SelectOption label="text/plain;charset=utf-8" value="" />
          </SelectRow>
        </Form>
      </Modal.Body>
      <Modal.Footer>
        <Button onClick={close}>Cancel</Button>
        <Button onClick={onSubmit}>Save</Button>
      </Modal.Footer>
    </Modal>
  )
}

export default NewSecret
