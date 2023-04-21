import React, { useState, useCallback, useEffect } from "react"
import {
  Modal,
  Form,
  TextInputRow,
  SelectRow,
  SelectOption,
  Label,
  Container,
  Message,
  Panel,
  PanelBody,
  PanelFooter,
  Button,
} from "juno-ui-components"
import { useHistory, useLocation } from "react-router-dom"
import { createContainer } from "../../containerActions"
import { getSecrets } from "../../secretActions"
import { useMutation, useQueryClient, useQuery } from "@tanstack/react-query"
import CreatableSelect from "react-select/creatable"
import { useMessageStore, Messages, MessagesProvider } from "messages-provider"
import { getContainerUuid } from "../../../lib/containerHelper"
import useStore from "../../store"

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

const NewContainer = () => {
  const location = useLocation()
  const history = useHistory()
  const [show, setShow] = useState(true)
  const [containerType, setContainerType] = useState("generic")
  const [formData, setFormData] = useState({ type: "generic" })
  const [validationState, setValidationState] = useState({})
  const [secret_refs, setSecret_refs] = useState([])
  const [secretsForSelect, setSecretsForSelect] = useState([])
  const [menuIsOpen, setMenuIsOpen] = useState(false)

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

  const { isLoading, isError, error, data, isSuccess, mutate } = useMutation(
    ({ formState }) => createContainer(formState)
  )
  const addMessage = useMessageStore((state) => state.addMessage)
  const resetMessages = useMessageStore((state) => state.resetMessages)
  const setShowNewContainer = useStore(
    useCallback((state) => state.setShowNewContainer)
  )

  const onConfirm = () => {
    console.log("new container formData: ", formData)
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
            close()
            queryClient.invalidateQueries("containers")
            addMessage({
              variant: "success",
              text: `The container ${containerUuid} is successfully created.`,
            })
          },
          onError: (error) => {
            addMessage({
              variant: "error",
              text: error.data.error,
            })
          },
        }
      )
    }
  }

  const secrets = useQuery(["secrets", { limit: 500, offset: 0 }], getSecrets, {
    // onSuccess: (data) => {
    //   const a = []
    //   const secrets = data?.secrets
    //   secrets.map((secret) => {
    //     a.push({
    //       label: `${secret.name} (${secret.secret_type})`,
    //       value: secret.secret_ref,
    //       secret_ref: { name: secret.name, secret_ref: secret.secret_ref },
    //       type: secret.secret_type,
    //     })
    //   })
    //   setSecretsForSelect(a)
    // },
  })

  useEffect(() => {
    const a = []
    const b = secrets.data?.secrets
    if (!b) return 
    b.map((secret) => {
      a.push({
        label: `${secret.name} (${secret.secret_type})`,
        value: secret.secret_ref,
        secret_ref: { name: secret.name, secret_ref: secret.secret_ref },
        type: secret.secret_type,
      })
    })
    setSecretsForSelect(a)
  }, [secrets.data])

  useEffect(() => {
    setCertContainerCertificates(
      secretsForSelect.filter((secret) => {
        return secret.type == "certificate"
      })
    )
    setCertContainerPrivatekeys(
      secretsForSelect.filter((secret) => {
        return secret.type == "private"
      })
    )
    setCertContainerPrivatekeyPassphrases(
      secretsForSelect.filter((secret) => {
        return secret.type == "passphrase"
      })
    )
    setCertContainerIntermediates(
      secretsForSelect.filter((secret) => {
        return secret.type == "certificate"
      })
    )
    setGenContainerSecrets(secretsForSelect)
    setRsaContainerPrivatekeys(
      secretsForSelect.filter((secret) => {
        return secret.type == "private"
      })
    )
    setRsaContainerPrivatekeyPassphrases(
      secretsForSelect.filter((secret) => {
        return secret.type == "passphrase"
      })
    )
    setRsaContainerPublickeys(
      secretsForSelect.filter((secret) => {
        return secret.type == "public"
      })
    )
  }, [secretsForSelect])

  const close = useCallback(() => {
    setShow(false)
    setShowNewContainer(false)
    history.replace(location.pathname.replace("/new", "")), [history, location]
    resetMessages()
  }, [])

  const restoreURL = useCallback(
    () => history.replace(location.pathname.replace("/new", "")),
    [history, location]
  )

  const styles = {
    container: (base) => ({
      ...base,
      flex: 1,
    }),
    menuPortal: (provided) => ({ ...provided, zIndex: 9999 }),
    menu: (provided) => ({ ...provided, zIndex: 9999 }),
  }

  const onSecretsChange = (props) => {
    if (props) {
      props?.map((prop) => {
        if (secret_refs) {
          for (let i = 0; i < secret_refs.length; i++) {
            if (secret_refs[i].secret_ref === prop.secret_ref.secret_ref) return
          }
        }
        secret_refs.push({
          name: prop.secret_ref.name,
          secret_ref: prop.secret_ref.secret_ref,
        })
      })
      setFormData({ ...formData, secret_refs: secret_refs })
    }
  }

  const onCertificatesChange = (props) => {
    if (props) {
      props?.map((prop) => {
        if (secret_refs) {
          for (let i = 0; i < secret_refs.length; i++) {
            if (secret_refs[i].secret_ref === prop.secret_ref.secret_ref) return
          }
        }
        secret_refs.push({
          name: "certificate",
          secret_ref: prop.secret_ref.secret_ref,
        })
      })
      setFormData({ ...formData, secret_refs: secret_refs })
    }
  }

  const onPrivateKeyChange = (props) => {
    if (props) {
      props?.map((prop) => {
        if (secret_refs) {
          for (let i = 0; i < secret_refs.length; i++) {
            if (secret_refs[i].secret_ref === prop.secret_ref.secret_ref) return
          }
        }
        secret_refs.push({
          name: "private_key",
          secret_ref: prop.secret_ref.secret_ref,
        })
      })
      setFormData({ ...formData, secret_refs: secret_refs })
    }
  }
  const onPublicKeyChange = (props) => {
    if (props) {
      props?.map((prop) => {
        if (secret_refs) {
          for (let i = 0; i < secret_refs.length; i++) {
            if (secret_refs[i].secret_ref === prop.secret_ref.secret_ref) return
          }
        }
        secret_refs.push({
          name: "public_key",
          secret_ref: prop.secret_ref.secret_ref,
        })
      })
      setFormData({ ...formData, secret_refs: secret_refs })
    }
  }
  const onPrivateKeyPassphraseChange = (props) => {
    if (props) {
      props?.map((prop) => {
        if (secret_refs) {
          for (let i = 0; i < secret_refs.length; i++) {
            if (secret_refs[i].secret_ref === prop.secret_ref.secret_ref) return
          }
        }
        secret_refs.push({
          name: "private_key_passphrase",
          secret_ref: prop.secret_ref.secret_ref,
        })
      })
      setFormData({ ...formData, secret_refs: secret_refs })
    }
  }
  const onIntermediatesChange = (props) => {
    if (props) {
      props?.map((prop) => {
        if (secret_refs) {
          for (let i = 0; i < secret_refs.length; i++) {
            if (secret_refs[i].secret_ref === prop.secret_ref.secret_ref) return
          }
        }
        secret_refs.push({
          name: "intermediates",
          secret_ref: prop.secret_ref.secret_ref,
        })
      })
      setFormData({ ...formData, secret_refs: secret_refs })
    }
  }

  const onClearValue = (props) => {
    //TODO: update secret_refs when user clears a value
    console.log("clear value props: ", props)
  }

  useEffect(() => {
    setShowNewContainer(true)
  }, [])

  return (
    <Panel
      opened={true}
      onClose={close}
      heading="New Container"
      size="large"
      aria-labelledby="contained-modal-title-lg"
    >
      <PanelBody
        footer={
          <PanelFooter>
            <Button label="Save" onClick={onConfirm} variant="primary" />
            <Button label="Cancel" onClick={close} />
          </PanelFooter>
        }
      >
        <Messages className="tw-mb-6" />
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
          <SelectRow
            className="tw-mb-6"
            defaultValue="generic"
            label="Container Type"
            onChange={(oEvent) => {
              setContainerType(oEvent.target.value)
              setCertContainerCertificates(null)
              setSecret_refs([])
              setCertContainerIntermediates(null)
              setCertContainerPrivatekeyPassphrases(null)
              setCertContainerPrivatekeys(null)
              setGenContainerSecrets(null)
              setRsaContainerPrivatekeyPassphrases(null)
              setRsaContainerPrivatekeys(null)
              setRsaContainerPublickeys(null)
              setValidationState({})

              setFormData({ ...formData, type: oEvent.target.value })
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
              {/* {validationState?.secret_refs && (
              <Container py px={false}>
                <Message variant="error" text={validationState?.secret_refs} />
              </Container>
            )} */}
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
                    styles={styles}
                  />
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
                    styles={styles}
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
                    styles={styles}
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
                    styles={styles}
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
                    styles={styles}
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
                    styles={styles}
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
                    styles={styles}
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
                    styles={styles}
                  />
                </>
              )}
            </>
          )}
        </Form>
      </PanelBody>
    </Panel>
  )
}

export default (props) => (
  <MessagesProvider>
    <NewContainer {...props} />
  </MessagesProvider>
)
