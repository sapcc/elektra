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
  CodeBlock,
  Badge,
} from "juno-ui-components"
import { getSecret, getSecretMetadata } from "../../secretActions"
import { useQuery } from "react-query"
import apiClient from "../../apiClient"
import HintLoading from "../HintLoading"
import { Message } from "juno-ui-components"

const Row = ({ label, value, children }) => {
  return (
    <DataGridRow>
      <DataGridHeadCell>{label}</DataGridHeadCell>
      <DataGridCell className="tw-break-all">{value || children}</DataGridCell>
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
  console.log("secretDetails: ", secret)

  useEffect(() => {
    if (!secret || !secret?.creator_id) return
    apiClient
      .get(`/username?user_id=${secret?.creator_id}`)
      .then((response) => {
        setCreatorName(response.data)
      })
    return () => setCreatorName(null)
  }, [secret])

  const [secretId, setSecretId] = useState(null)
  const [creatorName, setCreatorName] = useState(null)
  const [secretMetadata, setSecretMetadata] = useState(null)

  const [show, setShow] = useState(!!secret)
  const mounted = useRef(false)

  useEffect(() => {
    if (secret?.secret_ref) {
      const newSecretId = getSecretUuid(secret)
      setSecretId(newSecretId)
      // loadSecret(newSecretId)
      // loadSecretMetadata(newSecretId)
    }
  }, [secret?.secret_ref])

  const { isLoadingMd, isErrorMd, errorMd } = useQuery(
    ["secretMetadata", secretId],
    getSecretMetadata,
    {
      enabled: !!secretId,
      onSuccess: (data) => {
        console.log("secretMetadata onSuccess:", data)
        if (data) return setSecretMetadata(data)
      },
    }
  )

  useEffect(() => {
    mounted.current = true
    setShow(!!params.id)
    console.log("show secret", params.id)
    return () => (mounted.current = false)
  }, [params.id])

  const { isLoading, isError, data, error } = useQuery(
    ["secret", secretId],
    getSecret,
    {
      enabled: !!secretId,
      onSuccess: (data) => {
        console.log("fetchSecret onSuccess:", data)
        dispatch({
          type: "RECEIVE_SECRET",
          data,
        })
      },
      onError: (error) => {
        console.log("fetchSecret onError:", error)
        dispatch({ type: "REQUEST_SECRETS_FAILURE", error: error })
      },
    }
  )

  // TODO: Payload

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
      opened={true}
      onClose={close}
      heading={
        <span className="tw-break-all">{`Secret ${
          secret ? secret.name : ""
        }`}</span>
      }
      size="large"
    >
      <PanelBody>
        {isLoading && !data ? (
          <HintLoading />
        ) : isError ? (
          <Message variant="danger">
            {`${error?.statusCode}, ${error?.message}`}
          </Message>
        ) : secret ? (
          <>
            <DataGrid columns={2}>
              <Row label="Name" value={secret.name} />
              <Row label="Secret Ref" value={secret.secret_ref} />
              <Row label="Type" value={secret.secret_type} />
              <Row label="Created at" value={secret.created} />
              {/* <Row label="Owner" value={creatorName} /> */}
              <DataGridRow>
                <DataGridHeadCell>Owner</DataGridHeadCell>
                <DataGridCell>
                  {creatorName && (
                    <>
                      {creatorName}
                      <br />
                    </>
                  )}
                  <Badge>{secret.creator_id}</Badge>
                </DataGridCell>
              </DataGridRow>
              <Row label="Content Types" value={secret.content_types.default} />
              <Row label="Bit Length" value={secret.bit_length} />
              <Row label="Algorithm" value={secret.algorithm} />
              <Row label="Mode" value={secret.mode} />
              <Row label="Status" value={secret.status} />
              <Row label="Expiration" value={secret.expiration} />
              <DataGridRow>
                <DataGridHeadCell>{"Payload"}</DataGridHeadCell>
                <DataGridCell>
                  <Link
                    className="tw-break-all"
                    to={`/secrets/${secretId}/payload`}
                  >
                    Payload of {secret.name}
                  </Link>
                </DataGridCell>
              </DataGridRow>
            </DataGrid>
            <CodeBlock
              heading="Metadata"
              content={secretMetadata}
              lang="json"
              className="tw-mt-6"
            />
          </>
        ) : (
          <span>Secret {params.id} not found</span>
        )}
      </PanelBody>
    </Panel>
  )
}

export default SecretDetails
