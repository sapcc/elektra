import React, { useState, useEffect } from "react"
import { Modal, Button, Collapse } from "react-bootstrap"
import useCommons from "../../../lib/hooks/useCommons"
import { Form } from "lib/elektra-form"
import useListener from "../../../lib/hooks/useListener"
import SelectInput from "../shared/SelectInput"
import ErrorPage from "../ErrorPage"
import TagsInput from "../shared/TagsInput"
import HelpPopover from "../shared/HelpPopover"
import { addNotice } from "lib/flashes"
import useLoadbalancer from "../../../lib/hooks/useLoadbalancer"
import Log from "../shared/logger"
import react from "react"

const EditListener = (props) => {
  const {
    matchParams,
    searchParamsToString,
    formErrorMessage,
    fetchPoolsForSelect,
    helpBlockTextForSelect,
  } = useCommons()
  const {
    fetchListener,
    protocolTypes,
    tlsPoolRelation,
    protocolHeaderInsertionRelation,
    clientAuthenticationRelation,
    fetchSecretsForSelect,
    isSecretAContainer,
    certificateContainerRelation,
    SNIContainerRelation,
    CATLSContainerRelation,
    updateListener,
    httpHeaderInsertions,
    predefinedPolicies,
    advancedSectionRelation,
    helpBlockItems,
  } = useListener()
  const { persistLoadbalancer } = useLoadbalancer()
  const [loadbalancerID, setLoadbalancerID] = useState(null)
  const [listenerID, setListenerID] = useState(null)

  const [protocolType, setProtocolType] = useState(null)
  const [insetHeaders, setInsertHeaders] = useState(null)
  const [certificateContainer, setCertificateContainer] = useState(null)
  const [CertificateContainerNotFound, setCertificateContainerNotFound] =
    useState(null)
  const [CertificateContainerDeprecated, setCertificateContainerDeprecated] =
    useState(false)
  const [SNIContainers, setSNIContainers] = useState(null)
  const [SNIContainersNotFound, setSNIContainersNotFound] = useState(null)
  const [SNIContainersDeprecated, setSNIContainersDeprecated] = useState(false)
  const [clientAuthType, setClientAuthType] = useState(null)
  const [defaultPool, setDefaultPool] = useState(null)
  const [clientCATLScontainer, setClientCATLScontainer] = useState(null)
  const [clientCATLScontainerNotFound, setClientCATLScontainerNotFound] =
    useState(null)
  const [clientCATLScontainerDeprecated, setClientCATLScontainerDeprecated] =
    useState(false)
  const [predPolicies, setPredPolicies] = useState([])
  const [tags, setTags] = useState([])
  const [nonSelectableTlsPools, setNonSelectableTlsPools] = useState([])
  const [displayPools, setDisplayPools] = useState([])

  const [listener, setListener] = useState({
    isLoading: false,
    error: null,
    item: null,
  })
  const [pools, setPools] = useState({
    isLoading: false,
    error: null,
    items: [],
  })
  const [secrets, setSecrets] = useState({
    isLoading: false,
    error: null,
    items: [],
  })

  useEffect(() => {
    // get the lb
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    const ltID = params.listenerID
    setLoadbalancerID(lbID)
    setListenerID(ltID)
  }, [])

  useEffect(() => {
    if (listenerID) {
      loadListener()
    }
  }, [listenerID])

  useEffect(() => {
    if (loadbalancerID) {
      loadPools(loadbalancerID)
    }
  }, [loadbalancerID])

  useEffect(() => {
    if (pools.items.length > 0) {
      const newItems = [...pools.items]
      for (let i = 0; i < newItems.length; i++) {
        if (newItems[i].tls_enabled == true) {
          const newLabel = `${newItems[i].label} - available with protocol TERMINATED_HTTPS`
          newItems[i] = {
            ...newItems[i],
            ...{ isDisabled: true, label: newLabel },
          }
        }
      }
      setNonSelectableTlsPools(newItems)
    }
  }, [pools])

  useEffect(() => {
    if (pools.items.length > 0 && listener.item) {
      setSelectedDefaultPool()
      setupDisplayPools(listener.item.protocol)
    }
  }, [pools, listener, nonSelectableTlsPools])

  const loadListener = () => {
    Log.debug("fetching listener to edit")
    // fetch the listener to edit
    setListener({ ...listener, isLoading: true, error: null })
    fetchListener(loadbalancerID, listenerID)
      .then((data) => {
        // fill the secret depending fields with loaded secrets
        loadSecrets(loadbalancerID)
          .then((availableSecrets) => {
            setSelectedCertificateContainer(
              data.listener.protocol,
              availableSecrets,
              data.listener.default_tls_container_ref
            )
            setSelectedSNIContainers(
              data.listener.protocol,
              availableSecrets,
              data.listener.sni_container_refs
            )
            setSelectedClientCATLScontainer(
              data.listener.protocol,
              availableSecrets,
              data.listener.client_ca_tls_container_ref
            )
          })
          .catch((error) => {
            // if error fetching secrets the fields should still be shown with an error
            setSelectedCertificateContainer(data.listener.protocol, [], "")
            setSelectedSNIContainers(data.listener.protocol, [], [])
            setSelectedClientCATLScontainer(data.listener.protocol, [], "")
          })

        setListener({
          ...listener,
          isLoading: false,
          item: data.listener,
          error: null,
        })
      })
      .catch((error) => {
        setListener({ ...listener, isLoading: false, error: error })
      })
  }

  useEffect(() => {
    if (listener.item) {
      setSelectedProtocolType()
      setSelectedInsertHeaders()
      setSelectedClientAuthenticationType()
      setSelectedPredPoliciesAndTags()
      setAdvancedSection()
      // we show secrets depending fields already before the secrets are loaded. It just looks better
      // we set available secrets to null to avoid showing not found secret
      setSelectedCertificateContainer(listener.item.protocol, null, "")
      setSelectedSNIContainers(listener.item.protocol, null, [])
      setSelectedClientCATLScontainer(listener.item.protocol, null, "")
    }
  }, [listener.item])

  const setupDisplayPools = (protocol) => {
    // TLS-enabled pool can only be attached to a TERMINATED_HTTPS type listener
    if (tlsPoolRelation(protocol)) {
      setDisplayPools(pools.items)
    } else {
      setDisplayPools(nonSelectableTlsPools)
    }
  }

  const setSelectedProtocolType = () => {
    const selectedOption = protocolTypes().find(
      (i) => i.value == (listener.item.protocol || "").trim()
    )
    setProtocolType(selectedOption)
  }

  const setSelectedInsertHeaders = () => {
    const availableInsertHeaders = protocolHeaderInsertionRelation(
      listener.item.protocol
    )
    setInsertHeaderSelectItems(availableInsertHeaders)
    setShowInsertHeaders((availableInsertHeaders || []).length > 0)
    const selectedOptions = availableInsertHeaders.filter((i) =>
      listener.item.insert_headers.includes(i.value)
    )
    setInsertHeaders(selectedOptions)
  }

  const setSelectedClientAuthenticationType = () => {
    const availableClientAuthTypes = clientAuthenticationRelation(
      listener.item.protocol
    )
    setClientAuthenticationSelectItems(availableClientAuthTypes)
    setShowClientAuthentication((availableClientAuthTypes || []).length > 0)
    const selectedOption = availableClientAuthTypes.find(
      (i) => i.value == (listener.item.client_authentication || "").trim()
    )
    setClientAuthType(selectedOption)
  }

  const setSelectedDefaultPool = () => {
    const selectedDefaultPoolID = listener.item.default_pool_id
    const selectedOption = pools.items.find(
      (i) => i.value == (selectedDefaultPoolID || "").trim()
    )
    // if pool is not tls reset option
    setShowTLSPoolWarning(false)
    if (
      listener.item.protocol != "TERMINATED_HTTPS" &&
      selectedOption &&
      selectedOption.tls_enabled
    ) {
      setShowTLSPoolWarning(true)
    }
    setDefaultPool(selectedOption)
  }

  const setSelectedCertificateContainer = (
    selectedProtocolType,
    availableSecrets,
    selectedCertificateContainer
  ) => {
    setShowCertificateContainer(
      certificateContainerRelation(selectedProtocolType)
    )

    const selectedOption =
      availableSecrets &&
      availableSecrets.find(
        (i) => i.value == (selectedCertificateContainer || "").trim()
      )

    // save the secret in a different var if not found
    // given the user has choose before a secret (selectedCertificateContainer)
    // and the secrets are laoded (availableSecrets)
    if (!selectedOption && selectedCertificateContainer && availableSecrets) {
      setCertificateContainerNotFound(selectedCertificateContainer)
      setCertificateContainerDeprecated(
        isSecretAContainer(selectedCertificateContainer)
      )
    }

    setCertificateContainer(selectedOption)
  }

  const setSelectedSNIContainers = (
    selectedProtocolType,
    availableSecrets,
    selectedSNIContainers
  ) => {
    setShowSNIContainer(SNIContainerRelation(selectedProtocolType))
    const selectedOptions =
      availableSecrets &&
      availableSecrets.filter((i) => selectedSNIContainers.includes(i.value))

    // get the difference from the selected sni items to the ones found
    const foundOptions = selectedOptions || []
    const selectedSecrets = selectedSNIContainers || []
    const difference = selectedSecrets.filter((x) => !foundOptions.includes(x))
    if (difference.length > 0) {
      setSNIContainersNotFound(difference)
      difference.forEach((s) => {
        if (isSecretAContainer(s)) {
          setSNIContainersDeprecated(true)
        }
      })
    }

    setSNIContainers(selectedOptions)
  }

  const setSelectedClientCATLScontainer = (
    selectedProtocolType,
    availableSecrets,
    selectedCATLSContainer
  ) => {
    setShowCATLSContainer(CATLSContainerRelation(selectedProtocolType))
    const selectedOption =
      availableSecrets &&
      availableSecrets.find(
        (i) => i.value == (selectedCATLSContainer || "").trim()
      )

    // save the secret in a different var if not found
    // given the user has choose before a secret (selectedCertificateContainer)
    // and the secrets are laoded (availableSecrets)
    if (!selectedOption && selectedProtocolType && availableSecrets) {
      setClientCATLScontainerNotFound(selectedCATLSContainer)
      setClientCATLScontainerDeprecated(
        isSecretAContainer(selectedCATLSContainer)
      )
    }

    setClientCATLScontainer(selectedOption)
  }

  const setSelectedPredPoliciesAndTags = () => {
    const predPolicies = predefinedPolicies(listener.item.protocol)
    // set available pred policies depending on the protocol
    setPredefinedPoliciesSelectItems(predPolicies)
    // find the selected pred policies from the tags
    const selectedPredPoliciesOptions = predPolicies.filter((i) =>
      listener.item.tags.includes(i.value)
    )
    // add fixed attribute
    const newOptions = selectedPredPoliciesOptions.map((item) => {
      item.isFixed = true
      return item
    })
    setPredPolicies(newOptions)
    // remove the pred policies from the tags to avoid duplicates
    const selectedTagsOptions = listener.item.tags.filter(
      (tag) => !selectedPredPoliciesOptions.find((i) => i.value == tag)
    )
    setTags(selectedTagsOptions)

    setShowPredefinedPolicies(
      predefinedPolicies(listener.item.protocol).length > 0
    )
    setHelpBlockItemsPredPolicies(helpBlockItems(listener.item.protocol))
  }

  const setAdvancedSection = () => {
    setShowAdvancedSection(advancedSectionRelation(listener.item.protocol))
  }

  const loadPools = (lbID) => {
    return new Promise((handleSuccess, handleErrors) => {
      setPools({ ...pools, isLoading: true })
      fetchPoolsForSelect(lbID)
        .then((data) => {
          setPools({
            ...pools,
            isLoading: false,
            items: data.pools,
            error: null,
          })
          handleSuccess(data.pools)
        })
        .catch((error) => {
          setPools({ ...pools, isLoading: false, error: error })
          handleErrors(error)
        })
    })
  }

  const loadSecrets = (lbID) => {
    return new Promise((handleSuccess, handleErrors) => {
      setSecrets({ ...secrets, isLoading: true })
      fetchSecretsForSelect(lbID)
        .then((data) => {
          setSecrets({
            ...secrets,
            isLoading: false,
            items: data.secrets,
            error: null,
          })
          handleSuccess(data.secrets)
        })
        .catch((error) => {
          setSecrets({
            ...secrets,
            isLoading: false,
            error: error,
          })
          handleErrors(error)
        })
    })
  }

  /*
   * Modal stuff
   */
  const [show, setShow] = useState(true)

  const close = (e) => {
    if (e) e.stopPropagation()
    setShow(false)
  }

  const restoreUrl = () => {
    if (!show) {
      // get the lb
      const params = matchParams(props)
      const lbID = params.loadbalancerID
      props.history.replace(
        `/loadbalancers/${lbID}/show?${searchParamsToString(props)}`
      )
    }
  }

  /**
   * Form stuff
   */
  const [formErrors, setFormErrors] = useState(null)
  const [insetHeaderSelectItems, setInsertHeaderSelectItems] = useState([])
  const [clientAuthenticationSelectItems, setClientAuthenticationSelectItems] =
    useState([])
  const [predefinedPoliciesSelectItems, setPredefinedPoliciesSelectItems] =
    useState(null)
  const [helpBlockItemsPredPolicies, setHelpBlockItemsPredPolicies] =
    useState(null)

  const [showInsertHeaders, setShowInsertHeaders] = useState(false)
  const [showClientAuthentication, setShowClientAuthentication] =
    useState(false)
  const [showCertificateContainer, setShowCertificateContainer] =
    useState(false)
  const [showSNIContainer, setShowSNIContainer] = useState(false)
  const [showCATLSContainer, setShowCATLSContainer] = useState(false)
  const [showPredefinedPolicies, setShowPredefinedPolicies] = useState(false)
  const [showAdvancedSection, setShowAdvancedSection] = useState(false)
  const [showTLSPoolWarning, setShowTLSPoolWarning] = useState(false)

  const validate = ({
    name,
    description,
    protocol_port,
    protocol,
    default_pool_id,
    connection_limit,
    insert_headers,
    default_tls_container_ref,
    sni_container_refs,
    client_authentication,
    client_ca_tls_container_ref,
    tags,
  }) => {
    return name && protocol_port && protocol && true
  }

  const onSubmit = (values) => {
    setFormErrors(null)
    const newValues = { ...values }

    // removing tags or pred policies can result to null variables instead of empty arrays
    const newPredPolicies = predPolicies || []
    const newTags = tags || []

    // add optional attributes that not set per context
    newValues.tags = [...newPredPolicies, ...newTags].map((item, index) => {
      return item.value || item
    })

    return updateListener(loadbalancerID, listenerID, newValues)
      .then((response) => {
        addNotice(
          <React.Fragment>
            Listener <b>{response.data.name}</b> ({response.data.id}) is being
            updated.
          </React.Fragment>
        )
        // fetch the lb again containing the new listener so it gets updated fast
        persistLoadbalancer(loadbalancerID).catch((error) => {})
        close()
      })
      .catch((error) => {
        setFormErrors(formErrorMessage(error))
      })
  }

  const onSelectDefaultPoolChange = (props) => {
    setDefaultPool(props)
  }
  const onSelectInsertHeadersChange = (props) => {
    setInsertHeaders(props)
  }
  const onSelectClientAuthentication = (props) => {
    setClientAuthType(props)
  }
  const onSelectCertificateContainer = (props) => {
    setCertificateContainer(props)
  }
  const onSelectSNIContainers = (props) => {
    setSNIContainers(props)
  }
  const onSelectCATLSContainers = (props) => {
    setClientCATLScontainer(props)
  }

  const onSelectPredPolicies = (options) => {
    const newOptions = options || []
    setPredPolicies(newOptions)
  }

  const onTagsChange = (options) => {
    setTags(options)
  }

  Log.debug("RENDER edit listener")
  return (
    <Modal
      show={show}
      onHide={close}
      bsSize="large"
      backdrop="static"
      onExited={restoreUrl}
      aria-labelledby="contained-modal-title-lg"
      bsClass="lbaas2 modal"
    >
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">Edit Listener</Modal.Title>
      </Modal.Header>

      {listener.error ? (
        <Modal.Body>
          <ErrorPage
            headTitle="Edit Listener"
            error={listener.error}
            onReload={loadListener}
          />
        </Modal.Body>
      ) : (
        <React.Fragment>
          {listener.isLoading ? (
            <Modal.Body>
              <span className="spinner" />
            </Modal.Body>
          ) : (
            <Form
              className="form form-horizontal"
              validate={validate}
              onSubmit={onSubmit}
              initialValues={listener.item}
              resetForm={false}
            >
              <Modal.Body>
                <div className="bs-callout bs-callout-warning bs-callout-emphasize">
                  <h4>
                    Switched to using PKCS12 for TLS Term certs (New in API
                    version 2.8)
                  </h4>
                  <p>
                    For the TERMINATED_HTTPS protocol listeners now use the URI
                    of the Key Manager service secret containing a PKCS12 format
                    certificate/key bundle.
                  </p>
                  <p>
                    <b>
                      Listeners using secret containers of type "certificate"
                      containing the certificate and key for TERMINATED_HTTPS
                      protocol are deprecated and will no longer work in the
                      near future. Please consider exchanging the secret
                      containers for secrets and use PKCS12 format
                      certificate/key bundles as soon as possible!
                    </b>
                  </p>
                  <p>
                    Please see following examples for creating certs with PKCS12
                    format:{" "}
                    <a
                      href="https://github.com/openstack/octavia/blob/master/doc/source/user/guides/basic-cookbook.rst"
                      target="_blank"
                    >
                      Basic Load Balancing Cookbook
                    </a>
                  </p>
                </div>
                <p>
                  A Listener defines a protocol/port combination under which the
                  load balancer can be called.
                </p>
                <Form.Errors errors={formErrors} />
                <Form.ElementHorizontal label="Name" name="name" required>
                  <Form.Input elementType="input" type="text" name="name" />
                </Form.ElementHorizontal>
                <Form.ElementHorizontal label="Description" name="description">
                  <Form.Input
                    elementType="input"
                    type="text"
                    name="description"
                  />
                </Form.ElementHorizontal>
                <Form.ElementHorizontal
                  label="Protocol Port"
                  name="protocol_port"
                  required
                >
                  <Form.Input
                    elementType="input"
                    type="number"
                    min="1"
                    max="65535"
                    name="protocol_port"
                    disabled={true}
                  />
                  <span className="help-block">
                    <i className="fa fa-info-circle"></i>
                    The port under which the load balancer can be called. A port
                    number between 1 and 65535.
                  </span>
                </Form.ElementHorizontal>
                <Form.ElementHorizontal
                  label="Protocol"
                  name="protocol"
                  required
                >
                  <SelectInput
                    name="protocol"
                    items={protocolTypes()}
                    value={protocolType}
                    isDisabled={true}
                  />
                  <span className="help-block">
                    <i className="fa fa-info-circle"></i>
                    The protocol which can be used to access the load balancer
                    port.
                  </span>
                </Form.ElementHorizontal>

                <Collapse in={showAdvancedSection}>
                  <div className="advanced-options-section">
                    <div className="advanced-options">
                      {showCertificateContainer && (
                        <React.Fragment>
                          <div>
                            <Form.ElementHorizontal
                              label="Certificate Secret"
                              name="default_tls_container_ref"
                              required
                            >
                              <SelectInput
                                name="default_tls_container_ref"
                                isLoading={secrets.isLoading}
                                items={secrets.items}
                                onChange={onSelectCertificateContainer}
                                value={certificateContainer}
                                isClearable
                              />
                              <span className="help-block">
                                <i className="fa fa-info-circle"></i>
                                The secret containing a PKCS12 format
                                certificate/key bundles.
                              </span>
                              {secrets.error && (
                                <span className="text-danger">
                                  {secrets.error}
                                </span>
                              )}
                              {CertificateContainerNotFound && (
                                <React.Fragment>
                                  <p>
                                    <b className="text-danger">
                                      Secret not found:{" "}
                                    </b>
                                  </p>
                                  <ul className="secrets-not-found">
                                    <li>{CertificateContainerNotFound}</li>
                                  </ul>
                                  {CertificateContainerDeprecated && (
                                    <p>
                                      (It looks like one or more of your secrets
                                      are containers. Please consider the
                                      warning shown above.)
                                    </p>
                                  )}
                                </React.Fragment>
                              )}
                            </Form.ElementHorizontal>
                          </div>
                          <div>
                            <p>Optional attributes:</p>
                          </div>
                        </React.Fragment>
                      )}

                      {showPredefinedPolicies && (
                        <div>
                          <Form.ElementHorizontal
                            label="Extended Policy"
                            name="extended_policies"
                          >
                            <SelectInput
                              name="extended_policies"
                              items={predefinedPoliciesSelectItems}
                              isMulti
                              onChange={onSelectPredPolicies}
                              value={predPolicies}
                              useFormContext={false}
                            />
                            <span className="help-block">
                              <i className="fa fa-info-circle"></i>
                              <span className="help-block-text">
                                Policies predefined by CCloud for special
                                purpose. The policy will apply specific settings
                                on the load balancer objects. L7Rules are not
                                applicable and the Policy will be applied
                                always. After creation these will be shown as a
                                tag.
                              </span>
                              <HelpPopover
                                text={helpBlockTextForSelect(
                                  helpBlockItemsPredPolicies
                                )}
                              />
                            </span>
                          </Form.ElementHorizontal>
                        </div>
                      )}

                      {showInsertHeaders && (
                        <div>
                          <Form.ElementHorizontal
                            label="Insert Headers"
                            name="insert_headers"
                          >
                            <SelectInput
                              name="insert_headers"
                              items={insetHeaderSelectItems}
                              isMulti
                              onChange={onSelectInsertHeadersChange}
                              value={insetHeaders}
                            />
                            <span className="help-block">
                              <i className="fa fa-info-circle"></i>
                              <span className="help-block-text">
                                Headers to insert into the request before it is
                                sent to the backend member.
                              </span>
                              <HelpPopover
                                text={helpBlockTextForSelect(
                                  httpHeaderInsertions("ALL")
                                )}
                              />
                            </span>
                          </Form.ElementHorizontal>
                        </div>
                      )}

                      {showSNIContainer && (
                        <div>
                          <div className="row">
                            <div className="col-sm-8 col-sm-push-4">
                              <div className="bs-callout bs-callout-info bs-callout-emphasize">
                                <p>
                                  {" "}
                                  Use <b>SNI</b> if you have multiple TLS
                                  certificates that you would like to use on the
                                  same listener using Server Name Indication
                                  (SNI) technology. Please also visit{" "}
                                  <a
                                    href="https://docs.openstack.org/octavia/latest/user/guides/basic-cookbook.html#deploy-a-tls-terminated-https-load-balancer-with-sni"
                                    target="_blank"
                                  >
                                    the Octavia SNI section
                                  </a>{" "}
                                  for more information.
                                </p>
                              </div>
                            </div>
                          </div>

                          <Form.ElementHorizontal
                            label="SNI Secrets"
                            name="sni_container_refs"
                          >
                            <SelectInput
                              name="sni_container_refs"
                              isLoading={secrets.isLoading}
                              isMulti
                              items={secrets.items}
                              onChange={onSelectSNIContainers}
                              value={SNIContainers}
                            />
                            <span className="help-block">
                              <i className="fa fa-info-circle"></i>A list of
                              secrets containing PKCS12 format certificate/key
                              bundles used for Server Name Indication (SNI).
                            </span>
                            {secrets.error && (
                              <span className="text-danger">
                                {secrets.error}
                              </span>
                            )}
                            {SNIContainersNotFound &&
                              SNIContainersNotFound.length > 0 && (
                                <React.Fragment>
                                  <p>
                                    <b className="text-danger">
                                      Secret(s) not found:{" "}
                                    </b>
                                  </p>
                                  <ul className="secrets-not-found">
                                    {SNIContainersNotFound.map((s, index) => (
                                      <li key={index}>{s}</li>
                                    ))}
                                  </ul>
                                  {SNIContainersDeprecated && (
                                    <p>
                                      (It looks like one or more of your secrets
                                      are containers. Please consider the
                                      warning shown above.)
                                    </p>
                                  )}
                                </React.Fragment>
                              )}
                          </Form.ElementHorizontal>
                        </div>
                      )}

                      {showClientAuthentication && (
                        <div>
                          <div className="row">
                            <div className="col-sm-8 col-sm-push-4">
                              <div className="bs-callout bs-callout-info bs-callout-emphasize">
                                <p>
                                  <b>Client authentication</b> allows users to
                                  authenticate themselves to the VIP using
                                  certificates. This is also known as two-way
                                  TLS authentication. Please also visit{" "}
                                  <a
                                    href="https://docs.openstack.org/octavia/latest/user/guides/basic-cookbook.html#deploy-a-tls-terminated-https-load-balancer-with-client-authentication"
                                    target="_blank"
                                  >
                                    the Octavia client authentication section
                                  </a>{" "}
                                  for more information.
                                </p>
                              </div>
                            </div>
                          </div>

                          <Form.ElementHorizontal
                            label="Client Authentication Mode"
                            name="client_authentication"
                          >
                            <SelectInput
                              name="client_authentication"
                              items={clientAuthenticationSelectItems}
                              onChange={onSelectClientAuthentication}
                              value={clientAuthType}
                              isClearable
                            />
                            <span className="help-block">
                              <i className="fa fa-info-circle"></i>
                              The TLS client authentication mode.
                            </span>
                          </Form.ElementHorizontal>
                        </div>
                      )}

                      {showCATLSContainer && (
                        <div>
                          <Form.ElementHorizontal
                            label="Client Authentication Secret"
                            name="client_ca_tls_container_ref"
                          >
                            <SelectInput
                              name="client_ca_tls_container_ref"
                              isLoading={secrets.isLoading}
                              items={secrets.items}
                              onChange={onSelectCATLSContainers}
                              value={clientCATLScontainer}
                              isClearable
                            />
                            <span className="help-block">
                              <i className="fa fa-info-circle"></i>
                              The secret containing a PEM format client CA
                              certificate bundle.
                            </span>
                            {secrets.error && (
                              <span className="text-danger">
                                {secrets.error}
                              </span>
                            )}
                            {clientCATLScontainerNotFound && (
                              <React.Fragment>
                                <p>
                                  <b className="text-danger">
                                    Secret(s) not found:{" "}
                                  </b>
                                </p>
                                <ul className="secrets-not-found">
                                  <li>{clientCATLScontainerNotFound}</li>
                                </ul>
                                {clientCATLScontainerDeprecated && (
                                  <p>
                                    (It looks like one or more of your secrets
                                    are containers. Please consider the warning
                                    shown above.)
                                  </p>
                                )}
                              </React.Fragment>
                            )}
                          </Form.ElementHorizontal>
                        </div>
                      )}
                    </div>
                  </div>
                </Collapse>

                <Collapse in={showTLSPoolWarning}>
                  <div className="row">
                    <div className="col-sm-8 col-sm-push-4">
                      <div className="bs-callout bs-callout-warning bs-callout-emphasize">
                        <p>
                          TLS-enabled pool can only be attached to a{" "}
                          <b>TERMINATED_HTTPS</b> type listener!
                        </p>
                        <p>Please change default pool!</p>
                      </div>
                    </div>
                  </div>
                </Collapse>

                <Form.ElementHorizontal
                  label="Default Pool"
                  name="default_pool_id"
                >
                  <SelectInput
                    name="default_pool_id"
                    isLoading={pools.isLoading}
                    items={displayPools}
                    onChange={onSelectDefaultPoolChange}
                    value={defaultPool}
                    isClearable
                  />
                  {pools.error && (
                    <span className="text-danger">{pools.error}</span>
                  )}
                  <span className="help-block">
                    <i className="fa fa-info-circle"></i>
                    The pool to which all traffic will be routed if no L7 Policy
                    defines a different pool.
                  </span>
                </Form.ElementHorizontal>
                <Form.ElementHorizontal
                  label="Connection Limit"
                  name="connection_limit"
                >
                  <Form.Input
                    elementType="input"
                    type="number"
                    min="-1"
                    name="connection_limit"
                  />
                  <span className="help-block">
                    <i className="fa fa-info-circle"></i>
                    The number of parallel connections allowed to access the
                    load balancer. Value -1 means infinite connections are
                    allowed.
                  </span>
                </Form.ElementHorizontal>

                <Form.ElementHorizontal label="Tags" name="tags">
                  <TagsInput
                    name="tags"
                    initValue={tags}
                    useFormContext={false}
                    onChange={onTagsChange}
                  />
                  <span className="help-block">
                    <i className="fa fa-info-circle"></i>
                    Start a new tag typing a string and hitting the Enter or Tab
                    key.
                  </span>
                </Form.ElementHorizontal>
              </Modal.Body>

              <Modal.Footer>
                <Button onClick={close}>Cancel</Button>
                <Form.SubmitButton label="Save" />
              </Modal.Footer>
            </Form>
          )}
        </React.Fragment>
      )}
    </Modal>
  )
}

export default EditListener
