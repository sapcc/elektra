import React, { useMemo, useEffect, useState, useCallback, useRef } from "react"
// import { Modal, Button } from "react-bootstrap"
import { useHistory, useLocation, useParams, Link } from "react-router-dom"
import { useGlobalState } from "../StateProvider"
import { getSecretUuid } from "../../../lib/secretHelper"
import {
  Panel,
  PanelBody,
  DataGrid,
  DataGridRow,
  DataGridCell,
  DataGridHeadCell,
} from "juno-ui-components"
import { fetchSecret } from "../../secretActions"

const Row = ({ label, value, children }) => {
  return (
    <DataGridRow>
      <DataGridHeadCell>{label}</DataGridHeadCell>
      <DataGridCell>{value || children}</DataGridCell>
    </DataGridRow>
  )
}

const SecretDetails = () => {
  const location = useLocation()
  const history = useHistory()
  const params = useParams()
  const [secretsState, dispatch] = useGlobalState()
  const secret = useMemo(() => {
    return secretsState.secrets.items.find(
      (i) => i.secret_ref.indexOf(params.id) >= 0
    )
  }, [secretsState.secrets, params.id])
  const [secretId, setSecretId] = useState(null)
  const [error, setError] = useState(null)
  const [loading, setLoading] = useState(false)

  const [show, setShow] = useState(!!secret)
  const mounted = useRef(false)

  useEffect(() => {
    if (secret?.secret_ref) {
      const newSecretId = getSecretUuid(secret)
      setSecretId(newSecretId)
      loadSecret(newSecretId)
    }
  }, [secret?.secret_ref])

  const loadSecret = (secretId) => {
    fetchSecret(secretId)
      .then((data) => {
        console.log("dispatch:", data)
        dispatch({
          type: "RECEIVE_SECRET",
          data,
        })
      })
      .catch((error) => setError(error.data))
  }

  useEffect(() => {
    mounted.current = true
    setShow(!!params.id)
    console.log("show secret", params.id)
    return () => (mounted.current = false)
  }, [params.id])

  // const onPayloadLinkClick = useCallback(() => {
  //   fetchSecret(getSecretUuid(secret))
  //     .then((data) => {
  //       debugger
  //       console.log("fetch a secret", data)
  //       mounted.current && dispatch({ type: "RECEIVE_SECRET", data })
  //     })
  //     .then(close)
  //     .catch((error) => {
  //       console.log(error.data)
  //       mounted.current &&
  //         dispatch({
  //           type: "REQUEST_SECRETS_FAILURE",
  //           error: error.data,
  //         })
  //     })
  // }, [dispatch])

  const restoreURL = useCallback(() => {
    history.replace(
      location.pathname.replace(/^(\/[^/]*)\/.+\/show$/, (a, b) => b)
    )
  }, [history, location])

  const close = useCallback(() => {
    setShow(false)
    restoreURL()
  }, [restoreURL])

  return (
    <Panel
      opened={show}
      onClose={close}
      heading={`Secret ${secret ? secret.name : ""}`}
    >
      <PanelBody>
        {secret ? (
          <DataGrid columns={2}>
            <Row label="Name" value={secret.name} />
            <Row label="Secret Ref" value={secret.secret_ref} />
            <Row label="Type" value={secret.secret_type} />
            <Row label="Created at" value={secret.created} />
            <Row label="Owner" value={secret.creator_id} />
            <Row label="Content Types" value={secret.content_types.default} />
            <Row label="Bit Length" value={secret.bit_length} />
            <Row label="Algorithm" value={secret.algorithm} />
            <Row label="Mode" value={secret.mode} />
            <Row label="Status" value={secret.status} />
            <Row label="Expiration" value={secret.expiration} />
            <DataGridRow>
              <DataGridHeadCell>{"Payload"}</DataGridHeadCell>
              <DataGridCell>
                <Link to={`/secrets/${secretId}/payload`}>
                  Payload of {secret.name}
                </Link>
              </DataGridCell>
            </DataGridRow>
          </DataGrid>
        ) : (
          <span>Secret {params.id} not found</span>
        )}
      </PanelBody>
    </Panel>
  )
}

export default SecretDetails
