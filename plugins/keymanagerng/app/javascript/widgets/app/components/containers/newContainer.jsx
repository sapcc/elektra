import React from "react"
import {
  Modal,
  Form,
  TextInputRow,
  SelectRow,
  SelectOption,
} from "juno-ui-components"
import { useHistory, useLocation } from "react-router-dom"
import apiClient from "../../apiClient"
import { useGlobalState } from "../StateProvider"

const TYPE_CERTIFICATE = "Certificate"
const TYPE_GENERIC = "Generic"
const TYPE_RSA = "Rsa"

const selectContainerTypes = (containerType) => {
  switch (containerType) {
    case TYPE_CERTIFICATE:
      return [{ value: TYPE_CERTIFICATE, label: TYPE_CERTIFICATE }]
    case TYPE_GENERIC:
      return [{ value: TYPE_GENERIC, label: TYPE_GENERIC }]
    case TYPE_RSA:
      return [{ value: TYPE_RSA, label: TYPE_RSA }]
    default:
      return []
  }
}

const TYPE_TEXTPLAIN = "text/plain"
const TYPE_PKCS8 = "application/pkcs8"
const TYPE_PKIX_CERT = "application/pkix-cert"
const TYPE_OCTET_STREAM = "application/octet-stream"
const TYPE_TEXTPLAIN_CHARSET_UTF8 = "text/plain;charset=utf-8"

const secretsSectionRelToCertificateType = (certificateType) => {
  switch (certificateType) {
    case TYPE_CERTIFICATE:
      return [
        { value: "", label: "Please select a payload content type" },
        { value: TYPE_OCTET_STREAM, label: TYPE_OCTET_STREAM },
      ]
    case TYPE_GENERIC:
      return [
        { value: TYPE_TEXTPLAIN, label: TYPE_TEXTPLAIN },
        { value: TYPE_OCTET_STREAM, label: TYPE_OCTET_STREAM },
      ]
    case TYPE_RSA:
      return [
        { value: TYPE_TEXTPLAIN, label: TYPE_TEXTPLAIN },
        {
          value: TYPE_TEXTPLAIN_CHARSET_UTF8,
          label: TYPE_TEXTPLAIN_CHARSET_UTF8,
        },
      ]
    default:
      return []
  }
}

const formValidation = (formData) => {
  let errors = {}
  if (!formData.name) {
    errors.name = "Name can't be empty!"
  }
  if (!formData.container_type) {
    errors.container_type = "Container type can't be empty!"
  }
  return errors
}

const NewContainer = () => {
  const location = useLocation()
  const history = useHistory()
  const [_, dispatch] = useGlobalState()
  const [show, setShow] = React.useState(true)
  const mounted = React.useRef(false)
  const [formData, setFormData] = useState({})
  const [validationState, setValidationState] = useState({})

  React.useEffect(() => {
    mounted.current = true
    return () => (mounted.current = false)
  }, [])

  const onConfirm = React.useCallback(
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
    history.replace(location.pathname.replace("/new", "")), [history, location]
  }, [])

  const restoreURL = React.useCallback(
    () => history.replace(location.pathname.replace("/new", "")),
    [history, location]
  )

  return (
    <Modal
      title="New Container"
      open={show}
      onCancel={close}
      onConfirm={onConfirm}
      confirmButtonLabel="Save"
      cancelButtonLabel="Cancel"
      size="large"
      aria-labelledby="contained-modal-title-lg"
    >
      <Form className="form form-horizontal">
        <TextInputRow label="Name" name="name" required="true" />
        <SelectRow label="Container Type">
          <SelectOption label="" value="" />
          {selectContainerTypes("all").map((item, index) => (
            <SelectOption key={index} label={item.label} value={item.value} />
          ))}
        </SelectRow>
        <SelectRow label="Secrets" items=""></SelectRow>
      </Form>
    </Modal>
  )
}

export default NewContainer
