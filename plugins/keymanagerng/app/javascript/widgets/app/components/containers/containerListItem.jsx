import React from "react"
import { Link, useHistory } from "react-router-dom"
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

const ContainerListItem = ({ container }) => {
  // manually push a path onto the react router history
  // once we run on react-router-dom v6 this should be replaced with the useNavigate hook, and the push function with a navigate function
  // like this: const navigate = useNavigate(), the use navigate('this/is/the/path') in the onClick handler of the edit button below
  const { push } = useHistory()
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
          console.log("deleteMutate id: ", containerUuid)
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
        <Link className="tw-break-all" to={`/containers/${containerUuid}/show`}>
          {container.name || containerUuid}
        </Link>
        <Badge className="tw-text-xs">{containerUuid}</Badge>
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
