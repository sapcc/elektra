import React from "react"
import moment from "moment"
import { OverlayTrigger, Tooltip } from "react-bootstrap"

export const PrettyDate = ({ date }) => {
  const m = typeof date == "number" ? moment.unix(date) : moment.utc(date)

  let tooltip = <Tooltip id="dateTooltip">{m.format("LLLL")}</Tooltip>

  return (
    <OverlayTrigger
      overlay={tooltip}
      placement="top"
      delayShow={300}
      delayHide={150}
    >
      <span>{m.fromNow()}</span>
    </OverlayTrigger>
  )
}
