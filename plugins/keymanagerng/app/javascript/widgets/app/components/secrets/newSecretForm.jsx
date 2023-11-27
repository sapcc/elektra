import React, { useState, useLayoutEffect } from "react"
import {
  Form,
  FormRow,
  TextInput,
  Textarea,
  Select,
  SelectOption,
  Message,
  PanelBody,
  PanelFooter,
  Button,
  Container,
  Label,
  Icon,
  Stack,
} from "juno-ui-components"
import { createSecret } from "../../secretActions"
import { useMutation, useQueryClient } from "@tanstack/react-query"
import { useActions, Messages } from "messages-provider"
import { getSecretUuid } from "../../../lib/secretHelper"
import { DayPicker } from "react-day-picker"
import { format, isToday, isAfter } from "date-fns"
import { parseError } from "../../helpers"

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
      return [{ value: TYPE_OCTET_STREAM, label: TYPE_OCTET_STREAM }]
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

const SecretTypeHelpText = ({ showMore, handleShowMore }) => {
  const handleHide = () => {
    handleShowMore(false)
  }

  return (
    <>
      {!showMore ? (
        <Stack alignment="center">
          <p>Show more info about secret types</p>
          <Icon icon="chevronRight" onClick={() => handleShowMore(true)} />
        </Stack>
      ) : (
        <>
          <p>
            certificate - Used for storing cryptographic certificates such as
            X.509 certificates
          </p>
          <p>
            opaque - Used for backwards compatibility with previous versions of
            the API without typed secrets
          </p>
          <p>passphrase - Used for storing plain text passphrases</p>
          <p>
            private - Used for storing the private key of an asymmetric keypair
          </p>
          <p>
            public - Used for storing the public key of an asymmetric keypair
          </p>
          <p>
            symmetric - Used for storing byte arrays such as keys suitable for
            symmetric encryption
          </p>
          <Stack alignment="center">
            <p>Hide info about secret types</p>
            <Icon icon="chevronLeft" onClick={handleHide} />
          </Stack>
        </>
      )}
    </>
  )
}

const NewSecretForm = ({ onSuccessfullyCloseForm, onClose }) => {
  const [formData, setFormData] = useState({})
  const [validationState, setValidationState] = useState({})
  const [payloadContentTypeOptions, setPayloadContentTypeOptions] = useState([])

  const queryClient = useQueryClient()

  const { mutate } = useMutation(({ formState }) => createSecret(formState))
  const { addMessage, resetMessages } = useActions()

  const [selectedDay, setSelectedDay] = React.useState(null)

  const [showMore, setShowMore] = useState(false)

  const handleShowMore = (value) => {
    setShowMore(value)
  }

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
          onSuccess: (data) => {
            const secretUuid = getSecretUuid(data)
            queryClient.invalidateQueries("secrets")
            onSuccessfullyCloseForm(secretUuid)
          },
          onError: (error) => {
            addMessage({
              variant: "error",
              text: parseError(error.data.error),
            })
          },
        }
      )
    }
  }

  const onSecretTypeChange = (secretType) => {
    let options = { secret_type: secretType }

    if (secretType === "symmetric") {
      options["payload_content_encoding"] = "base64"
    }
    setPayloadContentTypeOptions(secretTypeRelToPayloadContentType(secretType))
    return setFormData({ ...formData, ...options })
  }

  useLayoutEffect(() => {
    resetMessages()
  }, [])

  return (
    <PanelBody
      footer={
        <PanelFooter>
          <Button
            label="Save"
            onClick={onConfirm}
            variant="primary"
            data-target="save-secret-btn"
          />
          <Button label="Cancel" onClick={onClose} />
        </PanelFooter>
      }
    >
      <Form className="form form-horizontal">
        <FormRow>
          <Messages />
        </FormRow>
        <FormRow>
          <TextInput
            label="Name"
            name="name"
            onChange={(oEvent) => {
              setFormData({ ...formData, name: oEvent.target.value })
            }}
            invalid={validationState?.name ? true : false}
            errortext={validationState?.name}
            required
            data-target="name-text-input"
          />
        </FormRow>
        <FormRow>
          <Container py px={false}>
            <FormRow>
              <Label text="Expiration" />
            </FormRow>
            <FormRow>
              <DayPicker
                mode="single"
                selected={selectedDay}
                onSelect={(selectedDate) => {
                  const currentDate = new Date()
                  let selectedDateTime = new Date(selectedDate)

                  // Set the time to the end of the day (23:59:59)
                  selectedDateTime.setHours(23, 59, 59)

                  if (
                    isToday(selectedDate) ||
                    isAfter(selectedDate, currentDate)
                  ) {
                    setSelectedDay(selectedDate)
                    setFormData({
                      ...formData,
                      expiration: selectedDateTime.toISOString(),
                    })
                    setValidationState({
                      ...validationState,
                      expiration: null, // Set to null when there is no error
                    })
                  } else {
                    setValidationState({
                      ...validationState,
                      expiration:
                        "Selected date must be greater than the current date and time!",
                    })
                    setSelectedDay(null)
                  }
                }}
              />
            </FormRow>

            {validationState?.expiration && (
              <FormRow>
                <p className="tw-text-xs tw-text-theme-error">
                  {validationState?.expiration
                    ? validationState?.expiration
                    : ""}
                </p>
              </FormRow>
            )}
            {selectedDay && (
              <FormRow>
                <p>
                  Selected date is:{" "}
                  {format(
                    new Date(selectedDay).setHours(23, 59, 59),
                    "MMMM d, yyyy HH:mm:ss"
                  )}
                </p>
              </FormRow>
            )}
            <FormRow>
              <p className="tw-text-xs tw-text-theme-light">
                {
                  "This is a UTC timestamp in ISO 8601 format YYYY-MM-DDTHH:MM:SSZ. If set, the secret will not be available after this time"
                }
              </p>
            </FormRow>
          </Container>
        </FormRow>

        <FormRow>
          <TextInput
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
        </FormRow>
        <FormRow>
          <TextInput
            label="Algorithm"
            name="algorithm"
            onChange={(oEvent) => {
              setFormData({ ...formData, algorithm: oEvent.target.value })
            }}
            helptext="Metadata for informational purposes"
          />
        </FormRow>
        <FormRow>
          <TextInput
            label="Mode"
            name="mode"
            onChange={(oEvent) => {
              setFormData({ ...formData, mode: oEvent.target.value })
            }}
            helptext="Metadata for informational purposes"
          />
        </FormRow>
        <FormRow>
          <Select
            label="Secret Type"
            name="secretType"
            onChange={onSecretTypeChange}
            errortext={validationState?.secret_type}
            invalid={validationState?.secret_type ? true : false}
            required
            data-target="secret-type-select"
            helptext={
              <SecretTypeHelpText
                showMore={showMore}
                handleShowMore={handleShowMore}
              />
            }
          >
            {selectTypes("all").map((item, index) => (
              <SelectOption
                data-target={"secret-type-select-option-" + item.label}
                key={index}
                label={item.label}
                value={item.value}
              />
            ))}
          </Select>
        </FormRow>
        <FormRow>
          <Textarea
            label="Payload"
            name="payload"
            onChange={(oEvent) => {
              setFormData({ ...formData, payload: oEvent.target.value })
            }}
            helptext={
              validationState?.payload ? "" : "The secret’s data to be stored"
            }
            errortext={validationState?.payload}
            invalid={validationState?.payload ? true : false}
            className="tw-h-64"
            required
            data-target="payload-text-area"
          />
        </FormRow>
        <FormRow>
          <Select
            label="Payload Content Type"
            name="payloadContentType"
            onChange={(value) => {
              setFormData({
                ...formData,
                payload_content_type: value,
              })
            }}
            placeholder={
              formData.secret_type
                ? "Select..."
                : "Please first select a secret type"
            }
            errortext={validationState?.payload_content_type}
            invalid={validationState?.payload_content_type ? true : false}
            data-target="payload-content-type-select"
            required
          >
            {!!formData.secret_type &&
              payloadContentTypeOptions.map((item, index) => (
                <SelectOption
                  data-target={
                    "payload-content-type-select-option-" + item.label
                  }
                  key={index}
                  label={item.label}
                  value={item.value}
                />
              ))}
          </Select>
        </FormRow>
        {formData.secret_type === "symmetric" && (
          <>
            <FormRow>
              <Message
                variant="warning"
                name="warningForSymmetricSecretType"
                text="Please encode the payload according to the chosen content encoding below"
              />
            </FormRow>
            <FormRow>
              <TextInput
                label="PayloadContentEncoding"
                name="payloadContentEncoding"
                value="base64"
                helptext="The encoding used for the payload. Currently only base64 is supported"
                required
                disabled
              />
            </FormRow>
          </>
        )}
      </Form>
    </PanelBody>
  )
}
export default NewSecretForm
