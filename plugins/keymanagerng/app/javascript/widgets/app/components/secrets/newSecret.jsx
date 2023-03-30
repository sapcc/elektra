import React, { useEffect, useState, useCallback, useRef } from "react"
import {
  Modal,
  Form,
  TextInputRow,
  TextareaRow,
  SelectRow,
  SelectOption,
  Message,
  Container,
  Box,
} from "juno-ui-components"
import { useHistory, useLocation } from "react-router-dom"
import { createSecret } from "../../secretActions"
import { useMutation, useQueryClient } from "@tanstack/react-query"

// import DateTimePicker from "react-datetime-picker"

const TYPE_SYMMETRIC = "symmetric"
const TYPE_PUBLIC = "public"
const TYPE_PRIVATE = "private"
const TYPE_PASSPHRASE = "passphrase"
const TYPE_CERTIFICATE = "certificate"
const TYPE_OPAQUE = "opaque"

const selectTypes = (secretType) => {
  switch (secretType) {
    case TYPE_CERTIFICATE:
      return [{ value: TYPE_CERTIFICATE, label: TYPE_CERTIFICATE }]
    case TYPE_OPAQUE:
      return [{ value: TYPE_OPAQUE, label: TYPE_OPAQUE }]
    case TYPE_PASSPHRASE:
      return [{ value: TYPE_PASSPHRASE, label: TYPE_PASSPHRASE }]
    case TYPE_PRIVATE:
      return [{ value: TYPE_PRIVATE, label: TYPE_PRIVATE }]
    case TYPE_PUBLIC:
      return [{ value: TYPE_PUBLIC, label: TYPE_PUBLIC }]
    case TYPE_SYMMETRIC:
      return [{ value: TYPE_SYMMETRIC, label: TYPE_SYMMETRIC }]
    case "all":
      return [
        { value: TYPE_CERTIFICATE, label: TYPE_CERTIFICATE },
        { value: TYPE_OPAQUE, label: TYPE_OPAQUE },
        { value: TYPE_PASSPHRASE, label: TYPE_PASSPHRASE },
        { value: TYPE_PRIVATE, label: TYPE_PRIVATE },
        { value: TYPE_PUBLIC, label: TYPE_PUBLIC },
        { value: TYPE_SYMMETRIC, label: TYPE_SYMMETRIC },
      ]
    default:
      return []
  }
}

const TYPE_TEXTPLAIN = "text/plain"
const TYPE_PKCS8 = "application/pkcs8"
const TYPE_PKIX_CERT = "application/pkix-cert"
const TYPE_OCTET_STREAM = "application/octet-stream"
const TYPE_TEXTPLAIN_CHARSET_UTF8 = "text/plain;charset=utf-8"

const secretTypeRelToPayloadContentType = (secretType) => {
  switch (secretType) {
    case TYPE_SYMMETRIC:
      return [
        { value: "", label: "Please select a payload content type" },
        { value: TYPE_OCTET_STREAM, label: TYPE_OCTET_STREAM },
      ]
    case TYPE_PUBLIC:
    case TYPE_PRIVATE:
      return [
        { value: TYPE_TEXTPLAIN, label: TYPE_TEXTPLAIN },
        { value: TYPE_OCTET_STREAM, label: TYPE_OCTET_STREAM },
      ]
    case TYPE_PASSPHRASE:
      return [
        { value: TYPE_TEXTPLAIN, label: TYPE_TEXTPLAIN },
        {
          value: TYPE_TEXTPLAIN_CHARSET_UTF8,
          label: TYPE_TEXTPLAIN_CHARSET_UTF8,
        },
      ]
    case TYPE_CERTIFICATE:
      return [
        {
          value: TYPE_TEXTPLAIN,
          label: TYPE_TEXTPLAIN,
        },
        { value: TYPE_PKCS8, label: TYPE_PKCS8 },
        { value: TYPE_PKIX_CERT, label: TYPE_PKIX_CERT },
      ]
    case TYPE_OPAQUE:
      return [
        { value: TYPE_TEXTPLAIN, label: TYPE_TEXTPLAIN },
        { value: TYPE_OCTET_STREAM, label: TYPE_OCTET_STREAM },
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
  if (!formData.expiration) {
    errors.expiration = "Expiration date can't be empty!"
  }
  if (
    isNaN(Date.parse(formData.expiration).toString()) ||
    Date.parse(formData.expiration).toString() < 0
  ) {
    errors.expiration =
      "Expiration date has not a valid format!  It should be a UTC timestamp in ISO 8601 format YYYY-MM-DDTHH:MM:SSZ"
  }
  if (!formData.secret_type) {
    errors.secret_type = "Secret type can't be empty!"
  }
  if (!formData.payload) {
    errors.payload = "Payload can't be empty!"
  }
  if (!formData.payload_content_type) {
    errors.payload_content_type = "Payload content type can't be empty!"
  }
  return errors
}

const NewSecret = () => {
  const location = useLocation()
  const history = useHistory()
  const [show, setShow] = useState(true)
  const [formData, setFormData] = useState({})
  const [validationState, setValidationState] = useState({})
  const [payloadContentTypeOptions, setPayloadContentTypeOptions] = useState([])

  const queryClient = useQueryClient()

  const { isLoading, isError, error, data, isSuccess, mutate } = useMutation(
    ({ formState }) => createSecret(formState)
  )

  const onConfirm = () => {
    const errors = formValidation(formData)
    if (Object.keys(errors).length > 0) {
      setValidationState(errors)
    } else {
      mutate(
        {
          formState: formData,
        },
        {
          onSuccess: (data, variables, context) => {
            close()
            queryClient.invalidateQueries("secrets")
          },
          onError: (error, variables, context) => {
            // TODO display error
          },
        }
      )
    }
  }

  const close = useCallback(() => {
    setShow(false)
    history.replace(location.pathname.replace("/new", "")), [history, location]
  }, [])

  const onSecretTypeChange = (oEvent) => {
    const secretType = oEvent.target.value
    let options = { secret_type: secretType }

    if (secretType === "symmetric") {
      options["payload_content_encoding"] = "base64"
    }
    console.log("secret type: ", secretType)
    setPayloadContentTypeOptions(secretTypeRelToPayloadContentType(secretType))
    return setFormData({ ...formData, ...options })
  }

  return (
    <Modal
      title="New Secret"
      open={show}
      size="large"
      onCancel={close}
      onConfirm={onConfirm}
      confirmButtonLabel="Save"
      cancelButtonLabel="Cancel"
    >
      <Form className="form form-horizontal">
        <TextInputRow
          label="Name"
          name="name"
          onChange={(oEvent) => {
            setFormData({ ...formData, name: oEvent.target.value })
          }}
          invalid={validationState?.name ? true : false}
          helptext={validationState?.name}
          required
        />
        <TextInputRow
          label="Expiration"
          name="expiration"
          onChange={(oEvent) => {
            setFormData({ ...formData, expiration: oEvent.target.value })
          }}
          invalid={validationState?.expiration ? true : false}
          helptext={
            validationState?.expiration
              ? validationState.expiration
              : "This is a UTC timestamp in ISO 8601 format YYYY-MM-DDTHH:MM:SSZ. If set, the secret will not be available after this time"
          }
          required
        />
        <TextInputRow
          label="Bit length"
          name="Bit length"
          onChange={(oEvent) => {
            setFormData({
              ...formData,
              bit_length: parseInt(oEvent.target.value),
            })
          }}
          helptext="Metadata for informational purposes. Value must be greater than zero"
        />
        <TextInputRow
          label="Algorithm"
          name="algorithm"
          onChange={(oEvent) => {
            setFormData({ ...formData, algorithm: oEvent.target.value })
          }}
          helptext="Metadata for informational purposes"
        />
        <TextInputRow
          label="Mode"
          name="mode"
          onChange={(oEvent) => {
            setFormData({ ...formData, mode: oEvent.target.value })
          }}
          helptext="Metadata for informational purposes"
        />
        <Box>
          <p>
            certificate - Used for storing cryptographic certificates such as
            X.509 certificates
          </p>
          <p>
            opaque - Used for backwards compatibility with previous versions of
            the API without typed secrets{" "}
          </p>
          <p>passphrase - Used for storing plain text passphrases </p>
          <p>
            private - Used for storing the private key of an asymmetric keypair{" "}
          </p>
          <p>
            public - Used for storing the public key of an asymmetric keypair{" "}
          </p>
          <p>
            symmetric - Used for storing byte arrays such as keys suitable for
            symmetric encryption
          </p>
        </Box>
        <SelectRow
          label="Secret Type"
          name="secretType"
          onChange={onSecretTypeChange}
          helptext={validationState?.secret_type}
          invalid={validationState?.secret_type ? true : false}
          required
        >
          <SelectOption label="" value="" />
          {selectTypes("all").map((item, index) => (
            <SelectOption key={index} label={item.label} value={item.value} />
          ))}
        </SelectRow>
        <TextareaRow
          label="Payload"
          name="payload"
          onChange={(oEvent) => {
            setFormData({ ...formData, payload: oEvent.target.value })
          }}
          helptext={
            validationState?.payload
              ? validationState.payload
              : "The secret’s data to be stored"
          }
          invalid={validationState?.payload ? true : false}
          required
        />
        <SelectRow
          label="Payload Content Type"
          name="payloadContentType"
          onChange={(oEvent) => {
            setFormData({
              ...formData,
              payload_content_type: oEvent.target.value,
            })
          }}
          helptext={validationState?.payload_content_type}
          invalid={validationState?.payload_content_type ? true : false}
          required
        >
          {!formData.secret_type && (
            <SelectOption label="Please first select a secret type" value="" />
          )}
          <SelectOption label="" value="" />
          {payloadContentTypeOptions.map((item, index) => (
            <SelectOption key={index} label={item.label} value={item.value} />
          ))}
        </SelectRow>
        {formData.secret_type === "symmetric" && (
          <>
            <Message
              variant="warning"
              name="warningForSymmetricSecretType"
              text="Please encode the payload according to the chosen content encoding below"
            />
            <TextInputRow
              label="PayloadContentEncoding"
              name="payloadContentEncoding"
              value="base64"
              helptext="The encoding used for the payload. Currently only base64 is supported"
              required
              disabled
            />
          </>
        )}
      </Form>
    </Modal>
  )
}
export default NewSecret
