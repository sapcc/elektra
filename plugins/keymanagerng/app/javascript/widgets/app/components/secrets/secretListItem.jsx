import React, { useCallback, useRef } from "react"
import { deleteSecret } from "../../secretActions"
import { Link, useHistory } from "react-router-dom"
import { policy } from "lib/policy"
import { useGlobalState } from "../StateProvider"
import {
  Badge,
  ButtonRow,
  Icon,
  DataGridRow,
  DataGridCell,
} from "juno-ui-components"
import { getSecretUuid } from "../../../lib/secretHelper"
import { useMutation, useQueryClient } from "react-query"
import HintLoading from "../HintLoading"
import { Message } from "juno-ui-components"

const SecretListItem = ({ secret }) => {
  // manually push a path onto the react router history
  // once we run on react-router-dom v6 this should be replaced with the useNavigate hook, and the push function with a navigate function
  // like this: const navigate = useNavigate(), the use navigate('this/is/the/path') in the onClick handler of the edit button below
  const { push } = useHistory()
  const secretUuid = getSecretUuid(secret)
  const [{ secrets: secretsState }, dispatch] = useGlobalState()
  const queryClient = useQueryClient()

  const { isLoading, isError, error, data, mutate } = useMutation(
    deleteSecret,
    100,
    secretUuid
  )

  const handleDelete = () => {
    mutate(
      {
        id: secretUuid,
      },
      {
        onSuccess: () => {
          console.log("deleteMutate id: ", secretUuid)
          dispatch({ type: "DELETE_SECRETS", secretUuid })
          queryClient.invalidateQueries("secrets")
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
        <Link className="tw-break-all" to={`/secrets/${secretUuid}/show`}>
          {secret.name || secretUuid}
        </Link>
        <br />
        <Badge>{secretUuid}</Badge>
      </DataGridCell>
      <DataGridCell>{secret.secret_type}</DataGridCell>
      <DataGridCell>{secret?.content_types?.default}</DataGridCell>
      <DataGridCell>{secret.status}</DataGridCell>
      <DataGridCell nowrap>
        <ButtonRow>
          {policy.isAllowed("keymanagerng:secret_delete") && (
            <Icon
              icon="deleteForever"
              onClick={() => handleDelete(secretUuid)}
            />
          )}
        </ButtonRow>
        {/* <Modal></Modal> */}
      </DataGridCell>
    </DataGridRow>
  )
}

export default SecretListItem
