import React from "react"
import { Link } from "react-router-dom"
import { policy } from "lib/policy"
import { Icon, DataGridRow, DataGridCell } from "juno-ui-components"

const Item = ({ entry, handleDelete }) => {
  return (
    <DataGridRow className={entry.isDeleting ? "updating" : ""}>
      <DataGridCell>
        <Link to={`/entries/${entry.id}/show`}>{entry.name || entry.id}</Link>
        <br />
        <span className="info-text small">{entry.id}</span>
      </DataGridCell>
      <DataGridCell>{entry.description}</DataGridCell>
      <DataGridCell wrap={false}>
        {policy.isAllowed("testikus:entry_delete") && (
          <Icon
            icon="deleteForever"
            onClick={(e) => handleDelete(entry.id)}
          />
        )}
        {policy.isAllowed("testikus:entry_update") && (
            <Link to={`/entries/${entry.id}/edit`}>
              <Icon icon="edit" />
            </Link>
        )}
      </DataGridCell>
    </DataGridRow>
  )
}

export default Item
