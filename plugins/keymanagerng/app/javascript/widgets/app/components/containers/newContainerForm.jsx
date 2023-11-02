import React, { useState, useEffect, useLayoutEffect } from "react"
import {
  Form,
  FormRow,
  TextInput,
  Select,
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
  // const [
  //   selectedCertContainerPrivatekeys,
  //   setSelectedCertContainerPrivatekeys,
  // ] = useState([])
  const [
    certContainerPrivatekeyPassphrases,
    setCertContainerPrivatekeyPassphrases,
  ] = useState([])
  // const [
  //   selectedCertContainerPrivatekeyPassphrases,
  //   setSelectedCertContainerPrivatekeyPassphrases,
  // ] = useState([])
  const [certContainerIntermediates, setCertContainerIntermediates] = useState(
    []
  )
  // const [
  //   selectedCertContainerIntermediates,
  //   setSelectedCertContainerIntermediates,
  // ] = useState([])
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
      selectedCertContainerCertificates?.length === 0 ||
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
        secret_ref: {
          name: secret.name,
          secret_ref: secret.secret_ref,
        },
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

  const updateSecretRefs = (selectedSecretRef, secretType) => {
    if (selectedSecretRef !== undefined) {
      const newSecretRef = {
        name: secretType,
        secret_ref: selectedSecretRef,
      };
  
      // Check if the new object's name is redundant
      const isRedundant = formData.secret_refs.some((ref) => ref.name === secretType);
  
      if (selectedSecretRef === "" && isRedundant) {
        // If selectedSecretRef is empty and name is redundant, remove the existing object
        const updatedSecretRefs = formData.secret_refs.filter((ref) => ref.name !== secretType);
  
        setFormData({
          ...formData,
          secret_refs: updatedSecretRefs,
        });
      } else if (isRedundant) {
        // If the name is redundant, replace the existing object with the new one
        const updatedSecretRefs = formData.secret_refs.map((ref) => {
          if (ref.name === secretType) {
            return newSecretRef;
          }
          return ref;
        });
  
        setFormData({
          ...formData,
          secret_refs: updatedSecretRefs,
        });
      } else {
        // If not redundant, add the new object
        setFormData({
          ...formData,
          secret_refs: [...formData.secret_refs, newSecretRef],
        });
      }
    }
  };
  

  const onSecretsChange = (props) => {
    let secretRefs = []
    let iRandomNum
    if (props) {
      props?.map((prop) => {
        iRandomNum = Math.random().toString(16).slice(2)
        secretRefs.push({
          name: `${prop.secret_ref.name}-gen-${iRandomNum}`, //This name should not be duplicated that's why unique random number is added
          secret_ref: prop.secret_ref.secret_ref,
        })
      })
      setFormData({
        ...formData,
        secret_refs: secretRefs,
      })
    }
    setSelectedGenContainerSecrets(props)
  }

  const onPrivateKeyChange = (selectedSecretRef) => {
    updateSecretRefs(selectedSecretRef, "private_key")
  }

  const onCertContainerPrivatekeyChange = (selectedSecretRef) => {
    onPrivateKeyChange(selectedSecretRef)
    // setSelectedCertContainerPrivatekeys(selectedSecretRef)
  }
  const onRsaContainerPrivateKeyChange = (selectedSecretRef) => {
    onPrivateKeyChange(selectedSecretRef)
    setSelectedRsaContainerPrivatekeys(selectedSecretRef)
  }
  const onPublicKeyChange = (selectedSecretRef) => {
    updateSecretRefs(selectedSecretRef, "public_key")
    setSelectedRsaContainerPublickeys(selectedSecretRef)
  }
  const onPrivateKeyPassphraseChange = (selectedSecretRef) => {
    updateSecretRefs(selectedSecretRef, "private_key_passphrase")
  }
  const onCertContainerPrivateKeyPassphraseChange = (selectedSecretRef) => {
    onPrivateKeyPassphraseChange(selectedSecretRef)
    // setSelectedCertContainerPrivatekeyPassphrases(selectedSecretRef)
  }
  const onRsaContainerPrivateKeyPassphraseChange = (selectedSecretRef) => {
    onPrivateKeyPassphraseChange(selectedSecretRef)
    setSelectedRsaContainerPrivatekeyPassphrases(selectedSecretRef)
  }
  const onIntermediatesChange = (selectedSecretRef) => {
    updateSecretRefs(selectedSecretRef, "intermediates")
    // setSelectedCertContainerIntermediates(selectedSecretRef)
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
            data-target="container-name-text-input"
          />
        </FormRow>
        <FormRow>
          <Select
            defaultValue="generic"
            label="Container Type"
            onChange={(value) => {
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
            {selectContainerTypes("all")?.map((item, index) => (
              <SelectOption
                data-target={"container-type-select-option-" + item.value}
                key={index}
                label={item.label}
                value={item.value}
              />
            ))}
          </Select>
        </FormRow>

        {containerType !== "" && (
          <>
            <FormRow>
              <Label text="Secrets" />
            </FormRow>
            <FormRow>
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
            </FormRow>
            {containerType === "certificate" && (
              <>
                <FormRow>
                  <Select
                    label="Certificate"
                    onChange={(selectedSecretRef) => {
                      updateSecretRefs(selectedSecretRef, "certificate")
                      setSelectedCertContainerCertificates(selectedSecretRef)
                      setValidationState({})
                      resetMessages()
                    }}
                    name="cert_container_type_certificates"
                    data-target="certificate-container-select"
                    errortext={validationState?.certContainerCertificates}
                    invalid={
                      validationState?.certContainerCertificates ? true : false
                    }
                    required
                  >
                    {certContainerCertificates?.length > 0 ? (
                      <>
                        {certContainerCertificates.map((item, index) => (
                          <SelectOption
                            key={index}
                            label={item.label}
                            value={item.value}
                          />
                        ))}
                      </>
                    ) : (
                      <SelectOption label="No secret is available!" value="" />
                    )}
                  </Select>
                </FormRow>
                <FormRow>
                  <Select
                    label="Private key"
                    onChange={onCertContainerPrivatekeyChange}
                    name="cert_container_type_private_keys"
                    data-target="cert-container-private-key-select"
                    invalid={
                      validationState?.certContainerPrivatekeys ? true : false
                    }
                  >
                    {certContainerPrivatekeys?.length > 0 ? (
                      <>
                        <SelectOption label="Select..." value="" />
                        {certContainerPrivatekeys.map((item, index) => (
                          <SelectOption
                            key={index}
                            label={item.label}
                            value={item.value}
                          />
                        ))}
                      </>
                    ) : (
                      <SelectOption label="No secret is available!" value="" />
                    )}
                  </Select>
                </FormRow>
                <FormRow>
                  <Select
                    label="Private key passphrase"
                    onChange={onCertContainerPrivateKeyPassphraseChange}
                    name="cert_container_type_private_key_passphrases"
                    data-target="cert-container-private-key-passphrase-select"
                    loading={secrets?.isLoading}
                    invalid={
                      validationState?.certContainerPrivatekeyPassphrases
                        ? true
                        : false
                    }
                  >
                    {certContainerPrivatekeyPassphrases?.length > 0 ? (
                      <>
                        <SelectOption label="Select..." value="" />
                        {certContainerPrivatekeyPassphrases.map(
                          (item, index) => (
                            <SelectOption
                              key={index}
                              label={item.label}
                              value={item.value}
                            />
                          )
                        )}
                      </>
                    ) : (
                      <SelectOption label="No secret is available!" value="" />
                    )}
                  </Select>
                </FormRow>
                <FormRow>
                  <Select
                    label="Intermediates"
                    onChange={onIntermediatesChange}
                    name="cert_container_type_intermediates"
                    data-target="intermediate-select"
                    loading={secrets?.isLoading}
                    invalid={
                      validationState?.certContainerIntermediates ? true : false
                    }
                  >
                    {certContainerIntermediates?.length > 0 ? (
                      <>
                        <SelectOption label="Select..." value="" />
                        {certContainerIntermediates.map((item, index) => (
                          <SelectOption
                            key={index}
                            label={item.label}
                            value={item.value}
                          />
                        ))}
                      </>
                    ) : (
                      <SelectOption label="No secret is available!" value="" />
                    )}
                  </Select>
                </FormRow>
              </>
            )}
            {containerType === "generic" && (
              <>
                <FormRow>
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
                </FormRow>
                <p className="tw-text-xs tw-text-theme-error tw-mt-1">
                  {validationState?.secret_refs
                    ? validationState?.secret_refs
                    : ""}
                </p>
              </>
            )}
            {containerType === "rsa" && (
              <>
                <FormRow>
                  <Select
                    label="Private key"
                    onChange={onRsaContainerPrivateKeyChange}
                    name="rsa_container_type_private_keys"
                    data-target="rsa-container-private-key-select"
                    loading={secrets?.isLoading}
                    invalid={
                      validationState?.rsaContainerPrivatekeys ? true : false
                    }
                    errortext={validationState?.rsaContainerPrivatekeys}
                    required
                  >
                    {rsaContainerPrivatekeys?.length > 0 ? (
                      rsaContainerPrivatekeys.map((item, index) => (
                          <SelectOption
                            key={index}
                            label={item.label}
                            value={item.value}
                          />
                        ))
                    ) : (
                      <SelectOption label="No secret is available!" value="" />
                    )}
                  </Select>
                </FormRow>
                <FormRow>
                  <Select
                    label="Private key passphrase"
                    onChange={onRsaContainerPrivateKeyPassphraseChange}
                    name="rsa_container_type_private_key_passphrases"
                    data-target="rsa-container-private-key-passphrase-select"
                    loading={secrets?.isLoading}
                    invalid={
                      validationState?.rsaContainerPrivatekeyPassphrases
                        ? true
                        : false
                    }
                    errortext={
                      validationState?.rsaContainerPrivatekeyPassphrases
                    }
                    required
                  >
                    {rsaContainerPrivatekeyPassphrases?.length > 0 ? (
                      rsaContainerPrivatekeyPassphrases.map((item, index) => (
                          <SelectOption
                            key={index}
                            label={item.label}
                            value={item.value}
                          />
                        ))
                    ) : (
                      <SelectOption label="No secret is available!" value="" />
                    )}
                  </Select>
                </FormRow>
                <FormRow>
                  <Select
                    label="Public key"
                    onChange={onPublicKeyChange}
                    name="rsa_container_type_public_keys"
                    data-target="rsa-container-public-key-select"
                    loading={secrets?.isLoading}
                    invalid={
                      validationState?.rsaContainerPublickeys ? true : false
                    }
                    required
                    errortext={validationState?.rsaContainerPublickeys}
                  >
                    {rsaContainerPublickeys?.length > 0 ? (
                      rsaContainerPublickeys.map((item, index) => (
                          <SelectOption
                            key={index}
                            label={item.label}
                            value={item.value}
                          />
                        ))
                      ) : (
                      <SelectOption label="No secret is available!" value="" />
                    )}
                  </Select>
                </FormRow>
              </>
            )}
          </>
        )}
      </Form>
    </PanelBody>
  )
}

export default NewContainerForm
