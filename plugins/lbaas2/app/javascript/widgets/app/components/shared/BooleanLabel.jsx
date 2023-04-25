import React from "react"
import { useMemo } from "react"
import { Tooltip, OverlayTrigger } from "react-bootstrap"
import uniqueId from "lodash/uniqueId"

const BooleanLabel = ({ value, tooltipText }) => {
  return useMemo(() => {
    return (
      <>
        {value ? (
          <>
            {tooltipText ? (
              <>
                <OverlayTrigger
                  placement="top"
                  overlay={
                    <Tooltip id={uniqueId("tooltip-")}>{tooltipText}</Tooltip>
                  }
                >
                  <i className="fa fa-check" />
                </OverlayTrigger>
              </>
            ) : (
              <i className="fa fa-check" />
            )}
          </>
        ) : (
          <i className="fa fa-minus custom-fa-minus" />
        )}
      </>
    )
  }, [value, tooltipText])
}

export default BooleanLabel
