import React from "react"
import { Link } from "react-router-dom"
import { policy } from "lib/policy"
import { DataGridRow, DataGridCell } from "juno-ui-components"

const Item = ({ entry, handleDelete }) => {
  return (
    <DataGridRow className={entry.isDeleting ? "updating" : ""}>
      <DataGridCell>
        <Link to={`/entries/${entry.id}/show`}>{entry.name || entry.id}</Link>
        <br />
        <span className="info-text small">{entry.id}</span>
      </DataGridCell>
      <DataGridCell>{entry.description}</DataGridCell>
      <DataGridCell className="snug">
        {(policy.isAllowed("testikus:entry_delete") ||
          policy.isAllowed("testikus:entry_update")) && (
          <div className="btn-group">
            <button
              className="btn btn-default btn-sm dropdown-toggle"
              type="button"
              data-toggle="dropdown"
              aria-expanded="true"
            >
              <i className="fa fa-cog"></i>
            </button>
            <ul className="dropdown-menu dropdown-menu-right" role="menu">
              {policy.isAllowed("testikus:entry_delete") && (
                <li>
                  <a
                    href="#"
                    onClick={(e) => {
                      e.preventDefault()
                      handleDelete(entry.id)
                    }}
                  >
                    Delete
                  </a>
                </li>
              )}
              {policy.isAllowed("testikus:entry_update") && (
                <li>
                  <Link to={`/entries/${entry.id}/edit`}>Edit</Link>
                </li>
              )}
            </ul>
          </div>
        )}
      </DataGridCell>
    </DataGridRow>
  )
}

export default Item
