import { Tooltip, OverlayTrigger } from "react-bootstrap"
import React from "react"

export const MemberIpIcon = () => {
  return (
    <OverlayTrigger
      placement="top"
      overlay={
        <Tooltip id="defalult-pool-tooltip">
          The IP address and the protocol port number the backend member server
          is listening on.
        </Tooltip>
      }
    >
      <i className="fa fa-desktop fa-fw" />
    </OverlayTrigger>
  )
}

export const MemberMonitorIcon = ({ isDefaulted }) => {
  return (
    <OverlayTrigger
      placement="top"
      overlay={
        <Tooltip id="defalult-pool-tooltip">
          Alternate IP address and protocol port used for health monitoring a
          backend member.{" "}
          {isDefaulted && (
            <b>
              If IP address or port is not set this defaults to the respective
              member address or port.
            </b>
          )}
        </Tooltip>
      }
    >
      {isDefaulted ? (
        <i className="fa fa-bullseye fa-fw text-warning" />
      ) : (
        <i className="fa fa-bullseye fa-fw" />
      )}
    </OverlayTrigger>
  )
}

export const MemberRequiredField = () => {
  return (
    <OverlayTrigger
      placement="top"
      overlay={<Tooltip id="defalult-pool-tooltip">Required</Tooltip>}
    >
      <abbr title="required">*</abbr>
    </OverlayTrigger>
  )
}
