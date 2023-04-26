import { Tooltip } from "lib/components/Overlay"
import React from "react"

export const ImageIcon = ({ image }) => {
  let iconType
  switch (image.visibility) {
    case "public":
      iconType = "fa-cloud"
      break
    case "private":
      iconType = "fa-lock"
      break
    case "community":
      iconType = "fa-users"
      break
    case "shared":
      iconType = "fa-share"
      break
  }

  return (
    <Tooltip content={image.visibility} placement="top">
      <i className={`text-primary fa fa-fw ${iconType}`} />
    </Tooltip>
  )
}
