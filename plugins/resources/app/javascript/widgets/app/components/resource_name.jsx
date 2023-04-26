import React from "react"
import { Tooltip } from "lib/components/Overlay"

const ResourceName = ({ name, flavorData, small }) => {
  let columnClasses = "col-md-2 text-right"
  if (small) {
    columnClasses += " small"
  }

  if (!flavorData.primary || !flavorData.secondary) {
    return <div className={columnClasses}>{name}</div>
  }

  return (
    <div className={columnClasses}>
      <Tooltip content={flavorData.secondary} placement="right">
        <span>{name}</span>
      </Tooltip>
      <div className="small text-muted flavor-data">
        {flavorData.primary.map((text) => (
          <span key={text}>{text}</span>
        ))}
      </div>
    </div>
  )
}

export default ResourceName
