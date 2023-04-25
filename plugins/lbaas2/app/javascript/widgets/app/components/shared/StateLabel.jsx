import React from "react"
import { useMemo } from "react"
import { Label, Tooltip, OverlayTrigger } from "react-bootstrap"

// label for the operating_status
const StateLabel = ({ label, labelClassName, tooltipContent }) => {
  return useMemo(() => {
    return (
      <>
        <OverlayTrigger
          placement="top"
          overlay={
            <Tooltip bsClass="lbaas2 tooltip" id="static-label-tooltip">
              <b>Operating Status</b>
              <br />
              {tooltipContent}
            </Tooltip>
          }
        >
          <Label className={labelClassName}>{label}</Label>
        </OverlayTrigger>
      </>
    )
  }, [label])
}

export default StateLabel
