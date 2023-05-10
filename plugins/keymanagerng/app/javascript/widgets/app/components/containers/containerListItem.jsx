import React, { useCallback, useState } from "react"
import { Link } from "react-router-dom"
import { policy } from "lib/policy"
import {
  Badge,
  ButtonRow,
  Icon,
  DataGridRow,
  DataGridCell,
} from "juno-ui-components"
import { getContainerUuid } from "../../../lib/containerHelper"
import { deleteContainer } from "../../containerActions"
import { useMutation, useQueryClient } from "@tanstack/react-query"
import HintLoading from "../HintLoading"
import { useActions } from "messages-provider"
import useStore from "../../store"
import ConfirmationModal from "../ConfirmationModal"

const ContainerListItem = ({ container }) => {
  const containerUuid = getContainerUuid(container)

  const queryClient = useQueryClient()

  const { isLoading, data, mutate } = useMutation(
    deleteContainer,
    100,
    containerUuid
  )
  const { addMessage } = useActions()
  const showNewContainer = useStore(
    useCallback((state) => state.showNewContainer)
  )
  const [show, setShow] = useState(false)

  const handleDelete = () => {
    setShow(true)
  }

  const onConfirm = () => {
    return mutate(
      {
        id: containerUuid,
      },
      {
        onSuccess: () => {
          setShow(false)
          addMessage({
            variant: "success",
            text: `The container ${containerUuid} is successfully deleted.`,
          })
          queryClient.invalidateQueries("containers")
        },
        onError: (error) => {
          setShow(false)
          addMessage({
            variant: "error",
            text: error.data.error,
          })
        },
      }
    )
  }

  const close = () => {
    setShow(false)
  }
  return isLoading && !data ? (
    <DataGridRow>
      <DataGridCell>
        <HintLoading />
      </DataGridCell>
      <DataGridCell></DataGridCell>
      <DataGridCell></DataGridCell>
      <DataGridCell></DataGridCell>
    </DataGridRow>
  ) : (
    <>
      <DataGridRow>
        <DataGridCell>
          <div>
            <Link
              className="tw-break-all"
              to={`/containers/${containerUuid}/show`}
              onClick={(event) => showNewContainer && event.preventDefault()}
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
      <ConfirmationModal
        text={`Are you sure you want to delete the container ${
          container.name || containerUuid
        }?`}
        show={show}
        close={close}
        onConfirm={onConfirm}
      />
    </>
  )
}

export default ContainerListItem
