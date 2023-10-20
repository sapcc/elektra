import React, { useState, useEffect, useLayoutEffect } from "react"
import {
  Form,
  TextInputRow,
  SelectRow,
  SelectOption,
  Label,
  PanelBody,
  PanelFooter,
  Button,
} from "juno-ui-components"
import { createContainer } from "../../containerActions"
import { getSecrets } from "../../secretActions"
import { useMutation, useQueryClient, useQuery } from "@tanstack/react-query"
import CreatableSelect from "react-select/creatable"
import { useActions, Messages } from "messages-provider"
import { getContainerUuid } from "../../../lib/containerHelper"

const TYPE_CERTIFICATE = "certificate"
const TYPE_GENERIC = "generic"
const TYPE_RSA = "rsa"

const selectContainerTypes = (containerType) => {
  switch (containerType) {
    case TYPE_CERTIFICATE:
      return [{ value: TYPE_CERTIFICATE, label: "Certificate" }]
    case TYPE_GENERIC:
      return [{ value: TYPE_GENERIC, label: "Generic" }]
    case TYPE_RSA:
      return [{ value: TYPE_RSA, label: "Rsa" }]
    case "all":
      return [
        { value: TYPE_CERTIFICATE, label: "Certificate" },
        { value: TYPE_GENERIC, label: "Generic" },
        { value: TYPE_RSA, label: "Rsa" },
      ]
    default:
      return []
  }
}

const NewContainerForm = ({ onSuccessfullyCloseForm, onClose }) => {
  const [containerType, setContainerType] = useState("generic")
  const [formData, setFormData] = useState({ type: "generic" })
  const [validationState, setValidationState] = useState({})
  const [secretsForSelect, setSecretsForSelect] = useState([])

  const [certContainerCertificates, setCertContainerCertificates] = useState([])
  const [
    selectedCertContainerCertificates,
    setSelectedCertContainerCertificates,
  ] = useState([])
  const [certContainerPrivatekeys, setCertContainerPrivatekeys] = useState([])
  const [
    selectedCertContainerPrivatekeys,
    setSelectedCertContainerPrivatekeys,
  ] = useState([])
  const [
    certContainerPrivatekeyPassphrases,
    setCertContainerPrivatekeyPassphrases,
  ] = useState([])
  const [
    selectedCertContainerPrivatekeyPassphrases,
    setSelectedCertContainerPrivatekeyPassphrases,
  ] = useState([])
  const [certContainerIntermediates, setCertContainerIntermediates] = useState(
    []
  )
  const [
    selectedCertContainerIntermediates,
    setSelectedCertContainerIntermediates,
  ] = useState([])
  const [genContainerSecrets, setGenContainerSecrets] = useState([])
  const [selectedGenContainerSecrets, setSelectedGenContainerSecrets] =
    useState([])
  const [rsaContainerPrivatekeys, setRsaContainerPrivatekeys] = useState([])
  const [selectedRsaContainerPrivatekeys, setSelectedRsaContainerPrivatekeys] =
    useState([])
  const [
    rsaContainerPrivatekeyPassphrases,
    setRsaContainerPrivatekeyPassphrases,
  ] = useState([])
  const [
    selectedRsaContainerPrivatekeyPassphrases,
    setSelectedRsaContainerPrivatekeyPassphrases,
  ] = useState([])
  const [rsaContainerPublickeys, setRsaContainerPublickeys] = useState([])
  const [selectedRsaContainerPublickeys, setSelectedRsaContainerPublickeys] =
    useState([])

  const queryClient = useQueryClient()

  const { mutate } = useMutation(({ formState }) => createContainer(formState))
  const { addMessage, resetMessages } = useActions()

  const formValidation = (formData) => {
    let errors = {}
    if (!formData.name) {
      errors.name = "Name can't be empty!"
    }
    if (!formData.type) {
      errors.type = "Container type can't be empty!"
    }
    if (
      !formData.secret_refs ||
      formData.secret_refs?.length === 0 ||
      selectedRsaContainerPrivatekeys?.length === 0 ||
      selectedRsaContainerPrivatekeyPassphrases?.length === 0 ||
      selectedRsaContainerPublickeys?.length === 0
    ) {
      switch (formData.type) {
        case "generic":
          if (selectedGenContainerSecrets?.length === 0) {
            errors.secret_refs = "Secrets can't be empty!"
          }
          break
        case "certificate":
          if (selectedCertContainerCertificates?.length === 0) {
            errors.certContainerCertificates = "Certificates can't be empty!"
          }
          break
        case "rsa":
          if (selectedRsaContainerPrivatekeys?.length === 0) {
            errors.rsaContainerPrivatekeys = "Private keys can't be empty!"
          }
          if (selectedRsaContainerPrivatekeyPassphrases?.length === 0) {
            errors.rsaContainerPrivatekeyPassphrases =
              "Private key passphrases can't be empty!"
          }
          if (selectedRsaContainerPublickeys?.length === 0) {
            errors.rsaContainerPublickeys = "Public keys can't be empty!"
          }
          break
        default:
          errors.secret_refs = "Secrets can't be empty!"
      }
    }
    return errors
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
            const containerUuid = getContainerUuid(data)
            queryClient.invalidateQueries("containers")
            onSuccessfullyCloseForm(containerUuid)
          },
          onError: (error) => {
            addMessage({
              variant: "error",
              text: error.data.error.description,
            })
          },
        }
      )
    }
  }

  const secrets = useQuery({
    queryKey: ["secrets", { limit: 500, offset: 0 }],
    queryFn: getSecrets,
  })

  useEffect(() => {
    const secretsOfSelect = []
    const fetchedSecrets = secrets.data?.secrets
    if (!fetchedSecrets) return
    fetchedSecrets.map((secret) => {
      secretsOfSelect.push({
        label: `${secret.name} (${secret.secret_type})`,
        value: secret.secret_ref,
        secret_ref: { name: secret.name, secret_ref: secret.secret_ref },
        type: secret.secret_type,
      })
    })
    setSecretsForSelect(secretsOfSelect)
  }, [secrets.data])

  const filterSecrets = (secretType) => {
    return secretsForSelect.filter((secret) => {
      return secret.type == secretType
    })
  }
  useEffect(() => {
    setCertContainerCertificates(filterSecrets("certificate"))
    setCertContainerPrivatekeys(filterSecrets("private"))
    setCertContainerPrivatekeyPassphrases(filterSecrets("passphrase"))
    setCertContainerIntermediates(filterSecrets("certificate"))
    setGenContainerSecrets(secretsForSelect)
    setRsaContainerPrivatekeys(filterSecrets("private"))
    setRsaContainerPrivatekeyPassphrases(filterSecrets("passphrase"))
    setRsaContainerPublickeys(filterSecrets("public"))
  }, [secretsForSelect])

  const commonCreatableStyles = {
    container: (base) => ({
      ...base,
      flex: 1,
    }),
    menuPortal: (provided) => ({ ...provided, zIndex: 9999 }),
    menu: (provided) => ({ ...provided, zIndex: 9999 }),
  }

  const invalidateReactSelect = (value) => {
    return value?.length === 0 &&
      (!!validationState?.secret_refs ||
        !!validationState?.certContainerCertificates ||
        !!validationState?.rsaContainerPrivatekeys ||
        !!validationState?.rsaContainerPrivatekeyPassphrases ||
        !!validationState?.rsaContainerPublickeys)
      ? {
          ...commonCreatableStyles,
          control: (provided, state) => ({
            ...provided,
            borderColor: state.isFocused
              ? "var(--color-error)"
              : "var(--color-error)",
            boxShadow: state.isFocused ? "0 0 0 1px var(--color-error)" : null,
            "&:hover": {
              borderColor: "var(--color-error)",
            },
          }),
        }
      : commonCreatableStyles
  }
  const updateSecretRefs = (props, secretRefName) => {
    const secretRefs = []
    if (props) {
      props?.map((prop) => {
        secretRefs.push({
          name: secretRefName ? secretRefName : prop.secret_ref.name,
          secret_ref: prop.secret_ref.secret_ref,
        })
      })
      setFormData({
        ...formData,
        secret_refs: secretRefs,
      })
    }
  }

  const onSecretsChange = (props) => {
    updateSecretRefs(props)
    setSelectedGenContainerSecrets(props)
  }

  const onCertificatesChange = (props) => {
    updateSecretRefs(props, "certificate")
    setSelectedCertContainerCertificates(props)
  }
  const onPrivateKeyChange = (props) => {
    updateSecretRefs(props, "private_key")
  }

  const onCertContainerPrivatekeyChange = (props) => {
    onPrivateKeyChange(props)
    setSelectedCertContainerPrivatekeys(props)
  }
  const onRsaContainerPrivateKeyChange = (props) => {
    onPrivateKeyChange(props)
    setSelectedRsaContainerPrivatekeys(props)
  }
  const onPublicKeyChange = (props) => {
    updateSecretRefs(props, "public_key")
    setSelectedRsaContainerPublickeys(props)
  }
  const onPrivateKeyPassphraseChange = (props) => {
    updateSecretRefs(props, "private_key_passphrase")
  }
  const onCertContainerPrivateKeyPassphraseChange = (props) => {
    onPrivateKeyPassphraseChange(props)
    setSelectedCertContainerPrivatekeyPassphrases(props)
  }
  const onRsaContainerPrivateKeyPassphraseChange = (props) => {
    onPrivateKeyPassphraseChange(props)
    setSelectedRsaContainerPrivatekeyPassphrases(props)
  }
  const onIntermediatesChange = (props) => {
    updateSecretRefs(props, "intermediates")
  }

  useLayoutEffect(() => {
    resetMessages()
  }, [])

  return (
    <PanelBody
      footer={
        <PanelFooter>
          <Button label="Save" onClick={onConfirm} variant="primary" />
          <Button label="Cancel" onClick={onClose} />
        </PanelFooter>
      }
    >
      <Form className="form form-horizontal">
        <Messages className="tw-mb-6" />
        <TextInputRow
          label="Name"
          name="name"
          onChange={(oEvent) => {
            setFormData({ ...formData, name: oEvent.target.value })
          }}
          invalid={validationState?.name ? true : false}
          errortext={validationState?.name}
          required
          data-target="container-name-text-input"
        />
        <SelectRow
          className="tw-mb-6"
          defaultValue="generic"
          label="Container Type"
          onValueChange={(value) => {
            setContainerType(value)
            setValidationState({})
            setFormData({ ...formData, type: value, secret_refs: [] })
            resetMessages()
          }}
          name="containerType"
          data-target="container-type-select"
          invalid={validationState?.type ? true : false}
          required
        >
          {selectContainerTypes("all").map((item, index) => (
            <SelectOption key={index} label={item.label} value={item.value} />
          ))}
        </SelectRow>
        {containerType !== "" && (
          <>
            <Label text="Secrets" />
            <div className="tw-text-xs">
              {containerType === "certificate"
                ? "A certificate container is used for storing the following secrets that are relevant to certificates: certificate, private_key (optional), " +
                  "private_key_passphrase (optional), intermediates (optional):"
                : containerType === "generic"
                ? "A generic container is used for any type of container that a user may wish to create. " +
                  "There are no restrictions on the type or amount of secrets that can be held within a container:"
                : containerType === "rsa"
                ? "An RSA container is used for storing RSA public keys, private keys, and private key pass phrases"
                : ""}
            </div>
            {containerType === "certificate" && (
              <>
                <div className="tw-mt-6" />
                <Label text="Certificate" required />
                <CreatableSelect
                  className="basic-single"
                  classNamePrefix="select"
                  isRtl={false}
                  closeMenuOnSelect={false}
                  createLabel="Certificate"
                  isLoading={secrets?.isLoading}
                  isSearchable
                  isMulti
                  isClearable
                  name="cert_container_type_certificates"
                  onChange={onCertificatesChange}
                  options={certContainerCertificates}
                  value={selectedCertContainerCertificates}
                  styles={invalidateReactSelect(
                    selectedCertContainerCertificates
                  )}
                />
                <p className="tw-text-xs tw-text-theme-error tw-mt-1">
                  {validationState?.certContainerCertificates
                    ? validationState?.certContainerCertificates
                    : ""}
                </p>
                <Label text="Private key" />
                <CreatableSelect
                  className="basic-single"
                  classNamePrefix="select"
                  isRtl={false}
                  closeMenuOnSelect={false}
                  name="cert_container_type_private_key"
                  isLoading={secrets?.isLoading}
                  options={certContainerPrivatekeys}
                  value={selectedCertContainerPrivatekeys}
                  onChange={onCertContainerPrivatekeyChange}
                  isSearchable
                  isClearable
                  isMulti
                  styles={commonCreatableStyles}
                />
                <Label text="Private key passphrase" />
                <CreatableSelect
                  className="basic-single"
                  classNamePrefix="select"
                  isRtl={false}
                  closeMenuOnSelect={false}
                  name="cert_container_type_private_key_passphrases"
                  isLoading={secrets?.isLoading}
                  options={certContainerPrivatekeyPassphrases}
                  value={selectedCertContainerPrivatekeyPassphrases}
                  onChange={onCertContainerPrivateKeyPassphraseChange}
                  isSearchable
                  isClearable
                  isMulti
                  styles={commonCreatableStyles}
                />
                <Label text="Intermediates" />
                <CreatableSelect
                  className="basic-single"
                  classNamePrefix="select"
                  isRtl={false}
                  closeMenuOnSelect={false}
                  name="cert_container_type_intermediates"
                  isLoading={secrets?.isLoading}
                  options={certContainerIntermediates}
                  value={selectedCertContainerIntermediates}
                  onChange={onIntermediatesChange}
                  isSearchable
                  isClearable
                  isMulti
                  styles={commonCreatableStyles}
                />
              </>
            )}
            {containerType === "generic" && (
              <>
                <div className="tw-mt-6" />
                <CreatableSelect
                  className="basic-single"
                  classNamePrefix="select"
                  isRtl={false}
                  closeMenuOnSelect={false}
                  isSearchable
                  isClearable
                  isMulti
                  name="generic_container_type_secrets"
                  isLoading={secrets?.isLoading}
                  options={genContainerSecrets}
                  onChange={onSecretsChange}
                  value={selectedGenContainerSecrets}
                  styles={invalidateReactSelect(selectedGenContainerSecrets)}
                />
                <p className="tw-text-xs tw-text-theme-error tw-mt-1">
                  {validationState?.secret_refs
                    ? validationState?.secret_refs
                    : ""}
                </p>
              </>
            )}
            {containerType === "rsa" && (
              <>
                <div className="tw-mt-6" />
                <Label text="Private key" required />
                <CreatableSelect
                  className="basic-single"
                  classNamePrefix="select"
                  isRtl={false}
                  closeMenuOnSelect={false}
                  name="rsa_container_type_private_keys"
                  isLoading={secrets?.isLoading}
                  options={rsaContainerPrivatekeys}
                  value={selectedRsaContainerPrivatekeys}
                  onChange={onRsaContainerPrivateKeyChange}
                  isSearchable
                  isClearable
                  isMulti
                  styles={invalidateReactSelect(
                    selectedRsaContainerPrivatekeys
                  )}
                />
                <p className="tw-text-xs tw-text-theme-error tw-mt-1">
                  {validationState?.rsaContainerPrivatekeys
                    ? validationState?.rsaContainerPrivatekeys
                    : ""}
                </p>
                <Label text="Private key passphrase" required />
                <CreatableSelect
                  className="basic-single"
                  classNamePrefix="select"
                  isRtl={false}
                  closeMenuOnSelect={false}
                  name="rsa_container_type_private_key_passphrases"
                  isLoading={secrets?.isLoading}
                  options={rsaContainerPrivatekeyPassphrases}
                  value={selectedRsaContainerPrivatekeyPassphrases}
                  onChange={onRsaContainerPrivateKeyPassphraseChange}
                  isSearchable
                  isClearable
                  isMulti
                  styles={invalidateReactSelect(
                    selectedRsaContainerPrivatekeyPassphrases
                  )}
                />
                <p className="tw-text-xs tw-text-theme-error tw-mt-1">
                  {validationState?.rsaContainerPrivatekeyPassphrases
                    ? validationState?.rsaContainerPrivatekeyPassphrases
                    : ""}
                </p>
                <Label text="Public key" required />
                <CreatableSelect
                  className="basic-single"
                  classNamePrefix="select"
                  isRtl={false}
                  closeMenuOnSelect={false}
                  name="rsa_container_type_public_key"
                  isLoading={secrets?.isLoading}
                  options={rsaContainerPublickeys}
                  value={selectedRsaContainerPublickeys}
                  onChange={onPublicKeyChange}
                  isSearchable
                  isClearable
                  isMulti
                  styles={invalidateReactSelect(selectedRsaContainerPublickeys)}
                />
                <p className="tw-text-xs tw-text-theme-error tw-mt-1">
                  {validationState?.rsaContainerPublickeys
                    ? validationState?.rsaContainerPublickeys
                    : ""}
                </p>
              </>
            )}
          </>
        )}
      </Form>
    </PanelBody>
  )
}

export default NewContainerForm
