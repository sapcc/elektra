import React from "react";
import { useMemo } from "react";
import { Tooltip, OverlayTrigger } from "react-bootstrap";

const StatusLabel = ({ label, textClassName, title }) => {
  return useMemo(() => {
    return (
      <React.Fragment>
        <OverlayTrigger
          placement="top"
          overlay={
            <Tooltip id="static-label-tooltip">
              <b>Provisioning Status</b>
              <br />
              {title}
            </Tooltip>
          }
        >
          <b className={`small ${textClassName}`}>{label}</b>
        </OverlayTrigger>
      </React.Fragment>
    );
  }, [label]);
};

export default StatusLabel;
