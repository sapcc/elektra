import React from "react"
import { Button } from "react-bootstrap"
import {
  Modal,
  Form,
  TextInputRow,
  TextareaRow,
  SelectRow,
  SelectOption,
  Message,
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
  const [encodingVis, setEncodingVis] = React.useState(true)
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
    setEncodingVis(false)
    history.replace(location.pathname.replace("/new", "")), [history, location]
  }, [])

  const validate = React.useCallback(
    (values) =>
      !!values.name &&
      !!values.expiration &&
      !!values.secretType &&
      !!values.payload &&
      !!values.payloadContentType
  )
  const onSecretTypeChange = React.useCallback((value) => {
    if (
      value ===
      "symmetric - Used for storing byte arrays such as keys suitable for symmetric encryption"
    ) {
      setEncodingVis(true)
    }
  })

  return (
    <Modal
      title="New Secret"
      open={show}
      onCancel={close}
      confirmButtonLabel="Save"
      cancelButtonLabel="Cancel"
      size="large"
      aria-labelledby="contained-modal-title-lg"
    >
      <Form
        className="form form-horizontal"
        validate={validate}
        onSubmit={onSubmit}
      >
        <TextInputRow
          label="Name"
          name="name"
          placeholder="Enter name"
          required
        />
        <TextInputRow
          label="Expiration"
          name="expiration"
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
        <SelectRow
          label="Secret Type"
          name="secretType"
          onChange={onSecretTypeChange}
          required
        >
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
        <SelectRow
          label="Payload Content Type"
          name="payloadContentType"
          required
        >
          <SelectOption label="text/plain" value="" />
          <SelectOption label="text/plain;charset=utf-8" value="" />
        </SelectRow>
        <Message
          title="Warning"
          name="warningForSymmetricSecretType"
          text="Please encode the payload according to the choosen content encoding below."
          visible={encodingVis}
        />
        <TextInputRow
          label="PayloadContentEncoding"
          name="payloadContentEncoding"
          value="base64"
          helptext="The encoding used for the payload. Currently only base64 is supported."
          required
          disabled
          visible={encodingVis}
        />
      </Form>
    </Modal>
  )
}

export default NewSecret
