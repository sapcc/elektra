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

const formValidation = (formData) => {
  let errors = {}
  if (!formData.name) {
    errors.name = "Name can't be empty!"
  }
  if (!formData.type) {
    errors.type = "Container type can't be empty!"
  }
  if (!formData.secret_refs) {
    errors.secret_refs = "Secrets can't be empty!"
  }
  return errors
}

const NewContainerForm = ({ onSuccessfullyCloseForm, onClose }) => {
  const [containerType, setContainerType] = useState("generic")
  const [formData, setFormData] = useState({ type: "generic" })
  const [validationState, setValidationState] = useState({})
  const [secret_refs, setSecret_refs] = useState([])
  const [secretsForSelect, setSecretsForSelect] = useState([])
  const [isSavePressed, setIsSavePressed] = useState(false)

  const [certContainerCertificates, setCertContainerCertificates] = useState([])
  const [certContainerPrivatekeys, setCertContainerPrivatekeys] = useState(null)
  const [
    certContainerPrivatekeyPassphrases,
    setCertContainerPrivatekeyPassphrases,
  ] = useState(null)
  const [certContainerIntermediates, setCertContainerIntermediates] =
    useState(null)
  const [genContainerSecrets, setGenContainerSecrets] = useState(null)
  const [rsaContainerPrivatekeys, setRsaContainerPrivatekeys] = useState(null)
  const [
    rsaContainerPrivatekeyPassphrases,
    setRsaContainerPrivatekeyPassphrases,
  ] = useState(null)
  const [rsaContainerPublickeys, setRsaContainerPublickeys] = useState(null)

  const queryClient = useQueryClient()

  const { mutate } = useMutation(
    ({ formState }) => createContainer(formState)
  )
  const { addMessage, resetMessages } = useActions()

  const onConfirm = () => {
    debugger
    setIsSavePressed(true)
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

  const secrets = useQuery(
    ["secrets", { limit: 500, offset: 0 }],
    getSecrets,
    {}
  )

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
    return {
      ...commonCreatableStyles,
      control: (baseStyles, state) => ({
        ...baseStyles,
        borderColor: !value && isSavePressed ? "red" : "grey",
      }),
    }
  }
  const updateSecretRefs = (props, secretRefName) => {
    if (props) {
      props?.map((prop) => {
        if (secret_refs) {
          for (let i = 0; i < secret_refs.length; i++) {
            if (secret_refs[i].secret_ref === prop.secret_ref.secret_ref) return
          }
        }
        secret_refs.push({
          name: secretRefName ? secretRefName : prop.secret_ref.name,
          secret_ref: prop.secret_ref.secret_ref,
        })
      })
      setFormData({ ...formData, secret_refs: secret_refs })
      setSecret_refs(secret_refs)
    }
  }

  const onSecretsChange = (props, actionType) => {
    updateSecretRefs(props)
  }

  const onCertificatesChange = (props) => {
    updateSecretRefs(props, "certificate")
  }
  const onPrivateKeyChange = (props) => {
    updateSecretRefs(props, "private_key")
  }
  const onPublicKeyChange = (props) => {
    updateSecretRefs(props, "public_key")
  }
  const onPrivateKeyPassphraseChange = (props) => {
    updateSecretRefs(props, "private_key_passphrase")
  }
  const onIntermediatesChange = (props) => {
    updateSecretRefs(props, "intermediates")
  }

  const onClearValue = (props) => {
    //TODO: update secret_refs when user clears a value
    console.log("clear value props: ", props)
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
            onClick={onSuccessfullyCloseForm}
            variant="primary"
          />
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
          helptext={validationState?.name}
          required
        />
        <SelectRow
          className="tw-mb-6"
          defaultValue="generic"
          label="Container Type"
          onValueChange={(value) => {
            setContainerType(value)
            setSecret_refs([])
            setValidationState({})

            setFormData({ ...formData, type: value })
          }}
          invalid={validationState?.type ? true : false}
          helptext={validationState?.type}
          required
        >
          <SelectOption label="" value="" />
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
                  styles={invalidateReactSelect(certContainerCertificates)}
                />
                {!certContainerCertificates &&
                  !validationState?.secret_refs(
                    <div>{validationState?.secret_refs}</div>
                  )}
                <Label text="Private key" />
                <CreatableSelect
                  className="basic-single"
                  classNamePrefix="select"
                  isRtl={false}
                  closeMenuOnSelect={false}
                  name="cert_container_type_private_key"
                  isLoading={secrets?.isLoading}
                  options={certContainerPrivatekeys}
                  onChange={onPrivateKeyChange}
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
                  onChange={onPrivateKeyPassphraseChange}
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
                  styles={invalidateReactSelect(genContainerSecrets)}
                  clearValue={onClearValue}
                />
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
                  onChange={onPrivateKeyChange}
                  isSearchable
                  isClearable
                  isMulti
                  styles={invalidateReactSelect(rsaContainerPrivatekeys)}
                />
                <Label text="Private key passphrase" required />
                <CreatableSelect
                  className="basic-single"
                  classNamePrefix="select"
                  isRtl={false}
                  closeMenuOnSelect={false}
                  name="rsa_container_type_private_key_passphrases"
                  isLoading={secrets?.isLoading}
                  options={rsaContainerPrivatekeyPassphrases}
                  onChange={onPrivateKeyPassphraseChange}
                  isSearchable
                  isClearable
                  isMulti
                  styles={invalidateReactSelect(
                    rsaContainerPrivatekeyPassphrases
                  )}
                />
                <Label text="Public key" required />
                <CreatableSelect
                  className="basic-single"
                  classNamePrefix="select"
                  isRtl={false}
                  closeMenuOnSelect={false}
                  name="rsa_container_type_public_key"
                  isLoading={secrets?.isLoading}
                  options={rsaContainerPublickeys}
                  onChange={onPublicKeyChange}
                  isSearchable
                  isClearable
                  isMulti
                  styles={invalidateReactSelect(rsaContainerPublickeys)}
                />
              </>
            )}
          </>
        )}
      </Form>
    </PanelBody>
  )
}

export default NewContainerForm
