import React from "react"
import { OverlayTrigger, Tooltip } from "react-bootstrap"
import { Link } from "react-router-dom"
import uniqueId from "lodash/uniqueId"

const SaveButton = ({ disabled, text, tooltipText, callback }) => {
  return (
    <>
      {disabled ? (
        <OverlayTrigger
          placement="top"
          overlay={<Tooltip id={uniqueId("tooltip-")}>{tooltipText}</Tooltip>}
        >
          <Link
            to={""}
            className="btn btn-primary"
            disabled={true}
            onClick={(e) => {
              e.preventDefault()
            }}
          >
            {text}
          </Link>
        </OverlayTrigger>
      ) : (
        <Link
          to={""}
          className="btn btn-primary"
          onClick={(e) => {
            e.preventDefault()
            callback()
          }}
        >
          {text}
        </Link>
      )}
    </>
  )
}

export default SaveButton
