import React from "react"
import Tag from "./Tag"

const AccessService = ({ serviceKey, serviceAttr }) => {
  return (
    <>
      <tr>
        <td>
          <b>{serviceAttr.displayName || serviceKey}</b>
          <div className="info-text">
            <small>{serviceAttr.description}</small>
          </div>
        </td>
        <td>
          {serviceAttr.tags &&
            serviceAttr.tags.map((tag, i) => <Tag key={i} item={tag} />)}
        </td>
      </tr>
    </>
  )
}

export default AccessService
