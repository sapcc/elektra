import React from "react";
import { useMemo } from "react";
import { Label, Tooltip, OverlayTrigger } from "react-bootstrap";

const StateLabel = ({ label, labelClassName, title }) => {
  return useMemo(() => {
    return (
      <React.Fragment>
        <OverlayTrigger
          placement="top"
          overlay={
            <Tooltip bsClass="lbaas2 tooltip" id="static-label-tooltip">
              <b>Operating Status</b>
              <br />
              {title}
            </Tooltip>
          }
        >
          <Label className={labelClassName}>{label}</Label>
        </OverlayTrigger>
      </React.Fragment>
    );
  }, [label]);
};

export default StateLabel;
