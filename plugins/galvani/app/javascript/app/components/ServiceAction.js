import React from "react"
import Tag from "./Tag"

const ServiceAction = ({ serviceKey, serviceAttr }) => {
  return (
    <div className="service">
      <div className="service-name">
        <b>{serviceAttr.displayName || serviceKey}</b>
        <div className="info-text">
          <small>{serviceAttr.description}</small>
        </div>
      </div>
      <div className="service-tags">
        {serviceAttr.tags &&
          serviceAttr.tags.map((tag, i) => <Tag key={i} tag={tag} />)}
      </div>
    </div>
  )
}

export default ServiceAction
