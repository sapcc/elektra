import { Tooltip, OverlayTrigger } from "react-bootstrap";

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
  );
};

export const MemberMonitorIcon = () => {
  return (
    <OverlayTrigger
      placement="top"
      overlay={
        <Tooltip id="defalult-pool-tooltip">
          IP address and protocol port used for health monitoring a backend
          member.
        </Tooltip>
      }
    >
      <i className="fa fa-bullseye fa-fw" />
    </OverlayTrigger>
  );
};

export const MemberRequiredField = () => {
  return (
    <OverlayTrigger
      placement="top"
      overlay={<Tooltip id="defalult-pool-tooltip">Required</Tooltip>}
    >
      <abbr title="required">*</abbr>
    </OverlayTrigger>
  );
};
