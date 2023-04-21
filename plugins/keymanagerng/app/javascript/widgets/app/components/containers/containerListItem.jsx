import React, { useCallback } from "react"
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
import { useMessageStore } from "messages-provider"
import useStore from "../../store"

const ContainerListItem = ({ container }) => {
  const containerUuid = getContainerUuid(container)

  const queryClient = useQueryClient()

  const { isLoading, isError, error, data, mutate } = useMutation(
    deleteContainer,
    100,
    containerUuid
  )
  const addMessage = useMessageStore((state) => state.addMessage)
  const showNewContainer = useStore(useCallback((state) => state.showNewContainer))

  const handleDelete = () => {
    mutate(
      {
        id: containerUuid,
      },
      {
        onSuccess: () => {
          addMessage({
            variant: "success",
            text: `The container ${containerUuid} is successfully deleted.`,
          })
          queryClient.invalidateQueries("containers")
        },
        onError: (error) => {
          addMessage({
            variant: "error",
            text: error.data.error,
          })
        }
      }
    )
  }

  return isLoading && !data ? (
    <HintLoading />
  ) : (
    <DataGridRow>
      <DataGridCell>
        <div>
          <Link
            className="tw-break-all"
            to={`/containers/${containerUuid}/show`}
            onClick={ (event) => showNewContainer && event.preventDefault()}
          >
            {container.name || containerUuid}
          </Link>
          <br />
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
