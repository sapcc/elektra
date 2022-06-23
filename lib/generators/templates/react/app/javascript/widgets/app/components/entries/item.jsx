import React from "react"
import { Link } from "react-router-dom"
import { policy } from "lib/policy"

const Item = ({ entry, handleDelete }) => {
  return (
    <tr className={entry.isDeleting ? "updating" : ""}>
      <td>
        <Link to={`/entries/${entry.id}/show`}>{entry.name || entry.id}</Link>
        <br />
        <span className="info-text small">{entry.id}</span>
      </td>
      <td>{entry.description}</td>
      <td className="snug">
        {(policy.isAllowed("%{PLUGIN_NAME}:entry_delete") ||
          policy.isAllowed("%{PLUGIN_NAME}:entry_update")) && (
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
              {policy.isAllowed("%{PLUGIN_NAME}:entry_delete") && (
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
              {policy.isAllowed("%{PLUGIN_NAME}:entry_update") && (
                <li>
                  <Link to={`/entries/${entry.id}/edit`}>Edit</Link>
                </li>
              )}
            </ul>
          </div>
        )}
      </td>
    </tr>
  )
}

export default Item
