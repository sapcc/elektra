import React, { useState, useEffect } from "react"
import useCommons from "../../../lib/hooks/useCommons"
import { Modal, Button, Collapse } from "react-bootstrap"
import usePool from "../../../lib/hooks/usePool"
import ErrorPage from "../ErrorPage"
import { Form } from "lib/elektra-form"
import SelectInput from "../shared/SelectInput"
import HelpPopover from "../shared/HelpPopover"
import useListener from "../../../lib/hooks/useListener"
import useLoadbalancer from "../../../lib/hooks/useLoadbalancer"
import TagsInput from "../shared/TagsInput"
import { addNotice } from "lib/flashes"
import Log from "../shared/logger"

const EditPool = (props) => {
  const {
    matchParams,
    searchParamsToString,
    formErrorMessage,
    helpBlockTextForSelect,
  } = useCommons()
  const {
    lbAlgorithmTypes,
    poolPersistenceTypes,
    protocolTypes,
    fetchPool,
    filterListeners,
    updatePool,
  } = usePool()
  const { persistLoadbalancer } = useLoadbalancer()
  const { fetchListnersForSelect, fetchSecretsForSelect } = useListener()

  const [loadbalancerID, setLoadbalancerID] = useState(null)
  const [poolID, setPoolID] = useState(null)
  const [availableListeners, setAvailableListeners] = useState([])
  const [availableListenersLoading, setAvailableListenersLoading] =
    useState(true)
  const [listenersLoaded, setListenersLoaded] = useState(false)
  const [secretsLoaded, setSecretsLoaded] = useState(false)

  const [lbAlgorithm, setLbAlgorithm] = useState(null)
  const [protocol, setProtocol] = useState(null)
  const [sessionPersistenceType, setSessionPersistenceType] = useState(null)
  const [sessionPersistenceCookieName, setSessionPersistenceCookieName] =
    useState(null)
  const [listener, setListener] = useState(null)
  const [certificateContainer, setCertificateContainer] = useState(null)
  const [certificateContainerDeprecated, setCertificateContainerDeprecated] =
    useState(null)
  const [authenticationContainer, setAuthenticationContainer] = useState(null)
  const [
    authenticationContainerDeprecated,
    setAuthenticationContainerDeprecated,
  ] = useState(null)

  const [pool, setPool] = useState({
    isLoading: false,
    error: null,
    item: null,
  })
  const [listeners, setListeners] = useState({
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
    const plID = params.poolID
    setLoadbalancerID(lbID)
    setPoolID(plID)
  }, [])

  useEffect(() => {
    if (poolID) {
      loadPool()
      loadListeners()
      loadSecrets()
    }
  }, [poolID])

  const loadPool = () => {
    Log.debug("fetching pool to edit")
    setPool({ ...pool, isLoading: true, error: null })
    fetchPool(loadbalancerID, poolID)
      .then((data) => {
        setSelectedLbAlgorithm(data.pool.lb_algorithm)
        setSelectedProtocol(data.pool.protocol)
        setSelectedSessionPersistence(data.pool)
        setSelectedUseTLS(data.pool.tls_enabled)
        setPool({ ...pool, isLoading: false, item: data.pool, error: null })
      })
      .catch((error) => {
        setPool({ ...pool, isLoading: false, error: error })
      })
  }

  const loadListeners = () => {
    Log.debug("fetching listeners to pool edit")
    setListeners({ ...listeners, isLoading: true })
    fetchListnersForSelect(loadbalancerID)
      .then((data) => {
        setListeners({
          ...listeners,
          isLoading: false,
          items: data.listeners,
          error: null,
        })
        setListenersLoaded(true)
      })
      .catch((error) => {
        setListeners({ ...listeners, isLoading: false, error: error })
      })
  }

  const loadSecrets = () => {
    setSecrets({ ...secrets, isLoading: true })
    fetchSecretsForSelect(loadbalancerID)
      .then((data) => {
        setSecrets({
          ...secrets,
          isLoading: false,
          items: data.secrets,
          error: null,
        })
        setSecretsLoaded(true)
      })
      .catch((error) => {
        setSecrets({ ...secrets, isLoading: false, error: error })
      })
  }

  useEffect(() => {
    if (protocol && protocol.value) {
      const selectedProtocol = protocol ? protocol.value : ""
      const filteredListeners = filterListeners(
        listeners.items,
        selectedProtocol
      )
      setAvailableListeners(filteredListeners)
      setAvailableListenersLoading(false)
      if (pool.item && pool.item.listeners) {
        setSelectedListener(filteredListeners, pool.item.listeners)
      }
    }
  }, [listenersLoaded, protocol, pool])

  useEffect(() => {
    // for testing
    // if(pool.item) {
    //   setSelectedCertificateContainer(containers.items, "https://keymanager-3.qa-de-1.cloud.sap:443/v1/containers/9cb71563-3ce3-4642-a93a-a027f7d48776")
    //   setSelectedAuthenticationContainer(containers.items, "https://keymanager-3.qa-de-1.cloud.sap:443/v1/containers/9cb71563-3ce3-4642-a93a-a027f7d48776")
    // }
    if (pool.item && pool.item.tls_container_ref) {
      setSelectedCertificateContainer(
        secrets.items,
        pool.item.tls_container_ref
      )
    }
    if (pool.item && pool.item.ca_tls_container_ref) {
      setSelectedAuthenticationContainer(
        secrets.items,
        pool.item.ca_tls_container_ref
      )
    }
  }, [secretsLoaded, pool])

  const setSelectedLbAlgorithm = (selectedLbAlgorithm) => {
    const selectedOption = lbAlgorithmTypes().find(
      (i) => i.value == (selectedLbAlgorithm || "").trim()
    )
    setLbAlgorithm(selectedOption)
  }

  const setSelectedProtocol = (selectedProtocol) => {
    const selectedOption = protocolTypes().find(
      (i) => i.value == (selectedProtocol || "").trim()
    )
    setProtocol(selectedOption)
  }

  const setSelectedSessionPersistence = (pool) => {
    const selectedPersistenceType = pool.session_persistence
    if (selectedPersistenceType && selectedPersistenceType.type) {
      const selectedOption = poolPersistenceTypes().find(
        (i) => i.value == (selectedPersistenceType.type || "").trim()
      )
      setSessionPersistenceType(selectedOption)
      setShowPersistenceCookieName(selectedOption)
      pool.session_persistence_type = selectedPersistenceType.type
    }
    if (selectedPersistenceType && selectedPersistenceType.cookie_name) {
      // Need to be just set per context since this is a plain input field and no value attribute available
      pool.session_persistence_cookie_name = selectedPersistenceType.cookie_name
    }
  }

  const setSelectedListener = (filteredListeners, selectedListeners) => {
    const selectedListenerKeys = selectedListeners.map((i) => i.id)
    const selectedOptions = filteredListeners.filter((i) =>
      selectedListenerKeys.includes(i.value)
    )
    setListener(selectedOptions)
  }

  const setSelectedUseTLS = (selectedUseTLS) => {
    setShowTLSSettings(selectedUseTLS)
  }

  const setSelectedCertificateContainer = (
    availableSecrets,
    selectedCertificateContainer
  ) => {
    const selectedOption = availableSecrets.find(
      (i) => i.value == (selectedCertificateContainer || "").trim()
    )

    // save the secret in a different var if not found
    // given the user has choose before a secret (selectedCertificateContainer)
    // and the secrets are laoded (availableSecrets)
    if (!selectedOption && selectedCertificateContainer && availableSecrets) {
      setCertificateContainerDeprecated(selectedCertificateContainer)
    }

    setCertificateContainer(selectedOption)
  }

  const setSelectedAuthenticationContainer = (
    availableSecrets,
    selectedAuthenticationContainer
  ) => {
    const selectedOption = availableSecrets.find(
      (i) => i.value == (selectedAuthenticationContainer || "").trim()
    )
    // save the secret in a different var if not found
    // given the user has choose before a secret (selectedCertificateContainer)
    // and the secrets are laoded (availableSecrets)
    if (
      !selectedOption &&
      selectedAuthenticationContainer &&
      availableSecrets
    ) {
      setAuthenticationContainerDeprecated(selectedAuthenticationContainer)
    }

    setAuthenticationContainer(selectedOption)
  }

  const setShowPersistenceCookieName = (option) => {
    setShowCookieName(option && option.value == "APP_COOKIE")
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
  const [protocols, setProtocols] = useState(protocolTypes())
  const [showCookieName, setShowCookieName] = useState(false)
  const [showTLSSettings, setShowTLSSettings] = useState(false)

  const validate = ({
    name,
    description,
    lb_algorithm,
    session_persistence_type,
    session_persistence_cookie_name,
    listener_id,
    tls_enabled,
    tls_container_ref,
    ca_tls_container_ref,
    tags,
  }) => {
    return name && lb_algorithm && true
  }

  const onSubmit = (values) => {
    const newValues = { ...values }
    const persistenceBlob = newValues.session_persistence || {}
    if (
      persistenceBlob.type != newValues.session_persistence_type ||
      persistenceBlob.cookie_name != newValues.session_persistence_cookie_name
    ) {
      // the session persistence has been changed. The JSON blob will be overwritten with new attributes
      // session_persistence_type and/or session_persistence_cookie_name by the rails controller
      if (newValues.session_persistence_type != "APP_COOKIE") {
        // remove just in case it still in context but presistence is not anymore app_coockie
        delete newValues.session_persistence_cookie_name
      }
    } else {
      // the session persistence is the same as in the JSON Blob. Remove the session_persistence_type and/or session_persistence_cookie_name
      // so it doesn't create a new blob
      delete newValues.session_persistence_type
      delete newValues.session_persistence_cookie_name
    }

    if (!showTLSSettings) {
      // remove tls attributes just in case they still in context but tls not anymore enabled
      delete newValues.tls_container_ref
      delete newValues.ca_tls_container_ref
    }

    setFormErrors(null)
    return updatePool(loadbalancerID, poolID, newValues)
      .then((response) => {
        addNotice(
          <React.Fragment>
            Pool <b>{response.data.name}</b> ({response.data.id}) is being
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

  const onLbAlgorithmChange = (option) => {
    setLbAlgorithm(option)
  }
  const onPoolPersistenceTypeChanged = (option) => {
    setSessionPersistenceType(option)
    setShowPersistenceCookieName(option)
  }
  const onChangedTLS = (e) => {
    if (e && e.target) {
      const value = e.target.checked
      setTimeout(() => setShowTLSSettings(value), 200)
    }
  }
  const onCertificateContainerChange = (option) => {
    setCertificateContainer(option)
  }
  const onAuthenticationContainerChange = (option) => {
    setAuthenticationContainer(option)
  }

  Log.debug("RENDER edit pool")
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
        <Modal.Title id="contained-modal-title-lg">Edit Pool</Modal.Title>
      </Modal.Header>

      {pool.error ? (
        <Modal.Body>
          <ErrorPage
            headTitle="Edit Pool"
            error={pool.error}
            onReload={loadPool}
          />
        </Modal.Body>
      ) : (
        <React.Fragment>
          {pool.isLoading ? (
            <Modal.Body>
              <span className="spinner" />
            </Modal.Body>
          ) : (
            <Form
              className="form form-horizontal"
              validate={validate}
              onSubmit={onSubmit}
              initialValues={pool.item}
              resetForm={false}
            >
              <Modal.Body>
                <div className="bs-callout bs-callout-warning bs-callout-emphasize">
                  <h4>
                    Switched to using PKCS12 for TLS Term certs (New in API
                    version 2.8)
                  </h4>
                  <p>
                    For pools with TLS encryption now use the URI of the Key
                    Manager service secret containing a PKCS12 format
                    certificate/key bundle.
                  </p>
                  <p>
                    <b>
                      Please consider exchanging the secret containers for
                      secrets and use PKCS12 format certificate/key bundle for
                      the for TLS client authentication as soon as possible!
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
                  Object representing the grouping of members to which the
                  listener forwards client requests. Note that a pool is
                  associated with only one listener, but a listener might refer
                  to several pools (and switch between them using layer 7
                  policies).
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
                  label="Lb Algorithm"
                  name="lb_algorithm"
                  required
                >
                  <SelectInput
                    name="lb_algorithm"
                    items={lbAlgorithmTypes()}
                    onChange={onLbAlgorithmChange}
                    value={lbAlgorithm}
                  />
                  <span className="help-block">
                    <i className="fa fa-info-circle"></i>
                    The method used for lbaas between members.
                  </span>
                </Form.ElementHorizontal>

                <Form.ElementHorizontal
                  label="Protocol"
                  name="protocol"
                  required
                >
                  <SelectInput
                    name="protocol"
                    items={protocols}
                    value={protocol}
                    isDisabled={true}
                  />
                  <span className="help-block">
                    <i className="fa fa-info-circle"></i>
                    The protocol used for routing the traffic to the members.
                  </span>
                </Form.ElementHorizontal>

                <Form.ElementHorizontal
                  label="Session Persistence Type"
                  name="session_persistence_type"
                >
                  <SelectInput
                    name="session_persistence_type"
                    isClearable
                    items={poolPersistenceTypes()}
                    onChange={onPoolPersistenceTypeChanged}
                    value={sessionPersistenceType}
                  />
                  <span className="help-block">
                    <i className="fa fa-info-circle"></i>
                    <span className="help-block-text">
                      Defines the method used for session stickiness. Traffic
                      for a client will be send always to the same member after
                      the session is established.
                    </span>
                    <HelpPopover
                      text={helpBlockTextForSelect(poolPersistenceTypes())}
                    />
                  </span>
                </Form.ElementHorizontal>

                <Collapse in={showCookieName}>
                  <div className="advanced-options-section">
                    <div className="advanced-options">
                      <Form.ElementHorizontal
                        label="Cookie Name"
                        name="session_persistence_cookie_name"
                        required
                      >
                        <Form.Input
                          elementType="input"
                          type="text"
                          name="session_persistence_cookie_name"
                        />
                        <span className="help-block">
                          <i className="fa fa-info-circle"></i>
                          The name of the HTTP cookie defined by your
                          application. The cookie value will be used for session
                          stickiness.
                        </span>
                      </Form.ElementHorizontal>
                    </div>
                  </div>
                </Collapse>

                <Form.ElementHorizontal
                  label="Assigned to Listeners"
                  name="listener_id"
                >
                  <SelectInput
                    name="listener_id"
                    isClearable
                    isMulti
                    isLoading={availableListenersLoading}
                    items={availableListeners}
                    value={listener}
                    isDisabled
                  />
                  {listeners.error ? (
                    <span className="text-danger">{listeners.error}</span>
                  ) : (
                    ""
                  )}
                  <span className="help-block">
                    <i className="fa fa-info-circle"></i>
                    The listener for which this pool is set as the default one.
                  </span>
                </Form.ElementHorizontal>

                <Form.ElementHorizontal label="Use TLS" name="tls_enabled">
                  <Form.Input
                    elementType="input"
                    type="checkbox"
                    name="tls_enabled"
                    onClick={onChangedTLS}
                  />
                  <span className="help-block">
                    <i className="fa fa-info-circle"></i>
                    When true connections to backend member servers will use TLS
                    encryption
                  </span>
                </Form.ElementHorizontal>

                <Collapse in={showTLSSettings}>
                  <div className="advanced-options-section">
                    <div className="advanced-options">
                      <Form.ElementHorizontal
                        label="Certificate Secret"
                        name="tls_container_ref"
                      >
                        <SelectInput
                          name="tls_container_ref"
                          isClearable
                          isLoading={secrets.isLoading}
                          items={secrets.items}
                          onChange={onCertificateContainerChange}
                          value={certificateContainer}
                        />
                        <span className="help-block">
                          <i className="fa fa-info-circle"></i>
                          The reference to the secret containing a PKCS12 format
                          certificate/key bundle for TLS client authentication
                          to the member servers.
                        </span>
                        {secrets.error && (
                          <span className="text-danger">{secrets.error}</span>
                        )}
                        {certificateContainerDeprecated && (
                          <React.Fragment>
                            <p>
                              <b className="text-danger">
                                Secret(s) not found:{" "}
                              </b>
                            </p>
                            <ul className="secrets-not-found">
                              <li>{certificateContainerDeprecated}</li>
                            </ul>
                          </React.Fragment>
                        )}
                      </Form.ElementHorizontal>

                      <Form.ElementHorizontal
                        label="Authentication Secret (CA)"
                        name="ca_tls_container_ref"
                      >
                        <SelectInput
                          name="ca_tls_container_ref"
                          isClearable
                          isLoading={secrets.isLoading}
                          items={secrets.items}
                          onChange={onAuthenticationContainerChange}
                          value={authenticationContainer}
                        />
                        <span className="help-block">
                          <i className="fa fa-info-circle"></i>
                          The reference secret containing a PEM format CA
                          certificate bundle.
                        </span>
                        {secrets.error && (
                          <span className="text-danger">{secrets.error}</span>
                        )}
                        {authenticationContainerDeprecated && (
                          <React.Fragment>
                            <p>
                              <b className="text-danger">
                                Secret(s) not found:{" "}
                              </b>
                            </p>
                            <ul className="secrets-not-found">
                              <li>{authenticationContainerDeprecated}</li>
                            </ul>
                          </React.Fragment>
                        )}
                      </Form.ElementHorizontal>
                    </div>
                  </div>
                </Collapse>

                <Form.ElementHorizontal label="Tags" name="tags">
                  <TagsInput
                    name="tags"
                    initValue={pool.item && pool.item.tags}
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

export default EditPool
