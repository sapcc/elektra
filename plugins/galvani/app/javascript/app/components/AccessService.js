import React from "react"
import Tag from "./Tag"
import SmartLink from "./shared/SmartLink"

const AccessService = ({ serviceKey, serviceAttr }) => {
  const canDelete = false

  const onDeleteClick = () => {}

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
        <td className="snug">
          <SmartLink
            onClick={onDeleteClick}
            style="default"
            size="small"
            isAllowed={canDelete}
            notAllowedText="Not allowed to delete access profiles. Please check with your administrator."
          >
            <span className="fa fa-trash fa-fw"></span>
          </SmartLink>
        </td>
      </tr>
    </>
  )
}

export default AccessService
