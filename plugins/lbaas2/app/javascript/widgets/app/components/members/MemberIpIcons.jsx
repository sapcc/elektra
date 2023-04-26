import { Tooltip } from "lib/components/Overlay"
import React from "react"

export const MemberIpIcon = () => {
  return (
    <Tooltip
      placement="top"
      content="The IP address and the protocol port number the backend member server is listening on."
    >
      <i className="fa fa-desktop fa-fw" />
    </Tooltip>
  )
}

export const MemberMonitorIcon = ({ isDefaulted }) => {
  return (
    <Tooltip
      placement="top"
      html
      content={`Alternate IP address and protocol port used for health monitoring a
          backend member.
          ${
            isDefaulted
              ? `
              <b>
                If IP address or port is not set this defaults to the respective
                member address or port.
              </b>
              `
              : ""
          }`}
    >
      {isDefaulted ? (
        <i className="fa fa-bullseye fa-fw text-warning" />
      ) : (
        <i className="fa fa-bullseye fa-fw" />
      )}
    </Tooltip>
  )
}

export const MemberRequiredField = () => {
  return (
    <Tooltip placement="top" content="Required">
      <abbr title="required">*</abbr>
    </Tooltip>
  )
}
