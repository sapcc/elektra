import React from "react"
import { Tooltip } from "lib/components/Overlay"
import { Link } from "react-router-dom"
import uniqueId from "lodash/uniqueId"

const SaveButton = ({ disabled, text, showTooltip, tooltipText, callback }) => {
  return (
    <>
      {showTooltip ? (
        <Tooltip placement="top" content={tooltipText}>
          <Link
            to={""}
            className="btn btn-primary"
            disabled={disabled}
            onClick={(e) => {
              e.preventDefault()
              if (!disabled) callback()
            }}
          >
            {text}
          </Link>
        </Tooltip>
      ) : (
        <Link
          to={""}
          className="btn btn-primary"
          disabled={disabled}
          onClick={(e) => {
            e.preventDefault()
            if (!disabled) callback()
          }}
        >
          {text}
        </Link>
      )}
    </>
  )
}

export default SaveButton
