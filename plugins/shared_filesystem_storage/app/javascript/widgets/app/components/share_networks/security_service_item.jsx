import React from "react"
export default ({ handleDelete, securityService }) => (
  <tr className={securityService.isDeleting ? "updating" : ""}>
    <td>{securityService.name}</td>
    <td>{securityService.id}</td>
    <td>{securityService.type}</td>
    <td>{securityService.status}</td>
    <td className="snug">
      <button
        className="btn btn-danger btn-sm"
        onClick={(e) => {
          e.preventDefault()
          handleDelete(securityService.id)
        }}
      >
        <i className="fa fa-minus" />
      </button>
    </td>
  </tr>
)
