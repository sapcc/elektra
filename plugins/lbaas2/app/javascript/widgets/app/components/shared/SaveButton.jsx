import React from "react"
import { OverlayTrigger, Tooltip } from "react-bootstrap"
import { Link } from "react-router-dom"
import uniqueId from "lodash/uniqueId"

const SaveButton = ({ disabled, text, showTooltip, tooltipText, callback }) => {
  return (
    <>
      {showTooltip ? (
        <OverlayTrigger
          placement="top"
          overlay={<Tooltip id={uniqueId("tooltip-")}>{tooltipText}</Tooltip>}
        >
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
        </OverlayTrigger>
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
