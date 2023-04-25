import React from "react"
import { useMemo } from "react"
import { Tooltip } from "lib/components/Overlay"

const StatusLabel = ({ label, textClassName, title }) => {
  return useMemo(() => {
    return (
      <>
        <Tooltip
          placement="top"
          content={`<b>Provisioning Status</b>
              <br />
              ${title}`}
          html
        >
          <b className={`small ${textClassName}`}>{label}</b>
        </Tooltip>
      </>
    )
  }, [label])
}

export default StatusLabel
