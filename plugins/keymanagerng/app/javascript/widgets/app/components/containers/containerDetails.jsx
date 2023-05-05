import React, { useEffect, useState, useCallback } from "react"
import { useHistory, useLocation, useParams, Link } from "react-router-dom"
import { getSecretUuid } from "../../../lib/secretHelper"
import {
  Panel,
  PanelBody,
  DataGrid,
  DataGridRow,
  DataGridCell,
  DataGridHeadCell,
  Badge,
} from "juno-ui-components"
import { getContainer } from "../../containerActions"
import { getUsername } from "../../helperActions"
import { getContainerUuid } from "../../../lib/containerHelper"
import { useQuery } from "@tanstack/react-query"
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

const ContainerDetails = () => {
  const location = useLocation()
  const history = useHistory()
  const params = useParams()
  const [containerId, setContainerId] = useState(null)
  const [creatorName, setCreatorName] = useState(null)

  const container = useQuery(["container", params.id], getContainer, {
    enabled: !!params.id,
    onSuccess: (data) => {
    },
    onError: (error) => {
    },
  })
  //Todo: find how to can rename data directly there as container

  const [show, setShow] = useState(!!container.data)

  useEffect(() => {
    if (container.data?.container_ref) {
      const newContainerId = getContainerUuid(container.data)
      setContainerId(newContainerId)
    }
  }, [container.data?.container_ref])

  const containerCreator = useQuery(
    ["containerCreator", container.data?.creator_id],
    getUsername,
    {
      enabled: !!container.data?.creator_id,
      onSuccess: (data) => {
        setCreatorName(data)
      },
      onError: () => {
        setCreatorName(null)
      },
    }
  )

  useEffect(() => {
    setShow(!!params.id)
  }, [params.id])

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
        <span className="tw-break-all">{`Container ${
          container.data ? container.data.name : ""
        }`}</span>
      }
      size="large"
    >
      <PanelBody>
        {container.isLoading && !container.data ? (
          <HintLoading />
        ) : container.isError ? (
          <Message variant="danger">
            {`${container.error?.statusCode}, ${container.error?.message}`}
          </Message>
        ) : container.data ? (
          <>
            <DataGrid columns={2}>
              <Row label="Name" value={container.data?.name} />
              <Row
                label="Container Ref"
                value={container.data?.container_ref}
              />
              <Row
                label="Container Type"
                value={container.data?.container_type}
              />
              <Row
                label="Created at"
                value={new Date(container.data?.created).toUTCString()}
              />
              <DataGridRow>
                <DataGridHeadCell>Owner</DataGridHeadCell>
                <DataGridCell>
                  <div>
                    {creatorName ? (
                      <>{creatorName}</>
                    ) : (
                      <Badge className="tw-text-xs">
                        {container.data?.creator_id}
                      </Badge>
                    )}
                  </div>
                </DataGridCell>
              </DataGridRow>
              <Row label="Status" value={container.data?.status} />
            </DataGrid>
            <DataGrid columns={2} minContentColumns={[0]} className="tw-mt-6">
              <DataGridRow>
                <DataGridHeadCell>#</DataGridHeadCell>
                <DataGridHeadCell>Name</DataGridHeadCell>
              </DataGridRow>
              {container.data?.secret_refs &&
              container.data?.secret_refs.length > 0 ? (
                container.data?.secret_refs.map((secret, index) => (
                  <>
                    <DataGridCell key={index}>{index}</DataGridCell>
                    <DataGridCell key={index}>
                      <div>
                        <Link
                          className="tw-break-all"
                          to={`/secrets/${getSecretUuid(secret)}/show`}
                        >
                          {secret.name}
                        </Link>
                        <br />
                        <Badge className="tw-text-xs">
                          {getSecretUuid(secret)}
                        </Badge>
                      </div>
                    </DataGridCell>
                  </>
                ))
              ) : (
                <DataGridRow>
                  <DataGridCell colSpan={2}>No Secrets found.</DataGridCell>
                </DataGridRow>
              )}
            </DataGrid>
          </>
        ) : (
          <span>container {params.id} not found</span>
        )}
      </PanelBody>
    </Panel>
  )
}

export default ContainerDetails
