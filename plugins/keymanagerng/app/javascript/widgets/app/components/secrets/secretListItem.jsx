import React from "react"
import { Link, useHistory } from "react-router-dom"
import { policy } from "lib/policy"
import {
  Badge,
  ButtonRow,
  Icon,
  DataGridRow,
  DataGridCell,
} from "juno-ui-components"
import { getSecretUuid } from "../../../lib/secretHelper"

const SecretListItem = ({ secret, handleDelete }) => {
  // manually push a path onto the react router history
  // once we run on react-router-dom v6 this should be replaced with the useNavigate hook, and the push function with a navigate function
  // like this: const navigate = useNavigate(), the use navigate('this/is/the/path') in the onClick handler of the edit button below
  const { push } = useHistory()
  const secretUuid = getSecretUuid(secret)

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
      <DataGridCell>{secret.content_types.default}</DataGridCell>
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
      </DataGridCell>
    </DataGridRow>
  )
}

export default SecretListItem
