import React from "react"
import { useMemo } from "react"
import { Tooltip } from "lib/components/Overlay"
import uniqueId from "lodash/uniqueId"

const BooleanLabel = ({ value, tooltipText }) => {
  return useMemo(() => {
    return (
      <>
        {value ? (
          <>
            {tooltipText ? (
              <>
                <Tooltip placement="top" content={tooltipText}>
                  <i className="fa fa-check" />
                </Tooltip>
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
