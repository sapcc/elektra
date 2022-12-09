import React, { useCallback, useRef } from "react"
import { deleteSecret, fetchSecrets } from "../../secretActions"
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

const SecretListItem = ({ secret }) => {
  // manually push a path onto the react router history
  // once we run on react-router-dom v6 this should be replaced with the useNavigate hook, and the push function with a navigate function
  // like this: const navigate = useNavigate(), the use navigate('this/is/the/path') in the onClick handler of the edit button below
  const { push } = useHistory()
  const secretUuid = getSecretUuid(secret)
  const [{ secrets: secretsState }, dispatch] = useGlobalState()
  const mounted = useRef(false)

  const handleDelete = useCallback(
    (id) => {
      dispatch({ type: "REQUEST_DELETE_SECRETS", id })
      deleteSecret(id)
        .then(() => {
          return mounted.current && dispatch({ type: "DELETE_SECRETS", id })
        })
        .then(() => {
          fetchSecrets().then((data) =>
            dispatch({
              type: "RECEIVE_SECRETS",
              secrets: data.secrets,
              totalNumOfSecrets: data.total,
            })
          )
        })
        .catch(
          (error) =>
            mounted.current &&
            dispatch({
              type: "DELETE_SECRETS_FAILURE",
              id,
              error: error.message,
            })
        )
    },
    [dispatch]
  )

  return (
    <DataGridRow className={secret.isDeleting ? "updating" : ""}>
      <DataGridCell>
        <Link to={`/secrets/${secretUuid}/show`}>
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
