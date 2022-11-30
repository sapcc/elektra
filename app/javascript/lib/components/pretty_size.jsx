import React from "react"
import { byteToHuman } from "lib/tools/size_formatter"
import { OverlayTrigger, Tooltip } from "react-bootstrap"

export const PrettySize = ({ size }) => {
  let tooltip = <Tooltip id="sizeTooltip">{size + " Bytes"}</Tooltip>

  return (
    <OverlayTrigger
      overlay={tooltip}
      placement="top"
      delayShow={300}
      delayHide={150}
    >
      <span>{byteToHuman(size)}</span>
    </OverlayTrigger>
  )
}
