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
import { getContainerUuid } from "../../../lib/containerHelper"

const ContainerListItem = ({ container, handleDelete }) => {
  // manually push a path onto the react router history
  // once we run on react-router-dom v6 this should be replaced with the useNavigate hook, and the push function with a navigate function
  // like this: const navigate = useNavigate(), the use navigate('this/is/the/path') in the onClick handler of the edit button below
  const { push } = useHistory()
  const containerUuid = getContainerUuid(container)

  return (
    <DataGridRow className={container.isDeleting ? "updating" : ""}>
      <DataGridCell>
        <Link to={`/containers/${containerUuid}/show`}>
          {container.name || containerUuid}
        </Link>
        <br />
        <Badge>{containerUuid}</Badge>
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
