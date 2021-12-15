import React from "react"
import SmartLink from "./shared/SmartLink"

const ServiceActionTag = ({ serviceKey, serviceAttr }) => {
  const canDelete = false

  const onDeleteClick = () => {}

  return (
    <>
      {serviceAttr.tags &&
        serviceAttr.tags.map((tag, i) => (
          <tr key={i}>
            {i == 0 ? (
              <td>
                <b>{serviceAttr.displayName || serviceKey}</b>
                <div className="info-text">
                  <small>{serviceAttr.description}</small>
                </div>
              </td>
            ) : (
              <td className="service-name-empty" />
            )}

            <td className="service-value">{tag.value}</td>
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
        ))}
    </>
  )
}

export default ServiceActionTag
