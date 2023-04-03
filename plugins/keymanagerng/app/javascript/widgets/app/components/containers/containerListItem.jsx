import React from "react"
import { Link } from "react-router-dom"
import { policy } from "lib/policy"
import {
  Badge,
  ButtonRow,
  Icon,
  DataGridRow,
  DataGridCell,
  Message,
} from "juno-ui-components"
import { getContainerUuid } from "../../../lib/containerHelper"
import { deleteContainer } from "../../containerActions"
import { useMutation, useQueryClient } from "@tanstack/react-query"
import HintLoading from "../HintLoading"
import { useEffect } from "react"

const ContainerListItem = ({ container }) => {
  const containerUuid = getContainerUuid(container)

  const queryClient = useQueryClient()

  const { isLoading, isError, error, data, mutate } = useMutation(
    deleteContainer,
    100,
    containerUuid
  )

  const handleDelete = () => {
    mutate(
      {
        id: containerUuid,
      },
      {
        onSuccess: () => {
          queryClient.invalidateQueries("containers")
        },
      }
    )
  }


  return isLoading && !data ? (
    <HintLoading />
  ) : isError ? (
    <Message variant="danger">
      {`${error.statusCode}, ${error.message}`}
    </Message>
  ) : (
    <DataGridRow>
      <DataGridCell>
        <div>
          <Link className="tw-break-all" to={`/containers/${containerUuid}/show`}>
            {container.name || containerUuid}
          </Link>
          <br/>
            <Badge className="tw-text-xs">{containerUuid}</Badge>
        </div>
      </DataGridCell>
      <DataGridCell>{container.type}</DataGridCell>
      <DataGridCell>{container.status}</DataGridCell>
      <DataGridCell nowrap>
        <ButtonRow>
          {policy.isAllowed("keymanagerng:container_delete") && (
            <Icon
              icon="deleteForever"
              onClick={() => handleDelete(containerUuid)}
            />
          )}
        </ButtonRow>
      </DataGridCell>
    </DataGridRow>
  )
}

export default ContainerListItem
