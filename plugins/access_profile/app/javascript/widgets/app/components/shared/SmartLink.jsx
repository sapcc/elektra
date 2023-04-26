import React from "react"
import { Button } from "react-bootstrap"
import { Tooltip } from "lib/components/Overlay"
import uniqueId from "lodash/uniqueId"

const SmartLink = ({
  style,
  size,
  disabled,
  children,
  onClick,
  isAllowed,
  notAllowedText,
}) => {
  const isAllowedToClick = isAllowed == false ? false : true

  return (
    <>
      {isAllowedToClick ? (
        <Button
          bsStyle={style}
          bsSize={size}
          disabled={disabled}
          onClick={(e) => {
            if (disabled) {
              e.preventDefault()
            } else {
              if (onClick) {
                onClick(e)
              }
            }
          }}
        >
          {children}
        </Button>
      ) : (
        <Tooltip placement="top" content={notAllowedText}>
          <div style={{ display: "inline-block", cursor: "not-allowed" }}>
            <Button
              style={{ pointerEvents: "none" }}
              bsSize={size}
              bsStyle={style}
              disabled={true}
              onClick={(e) => {
                e.preventDefault()
              }}
            >
              {children}
            </Button>
          </div>
        </Tooltip>
      )}
    </>
  )
}

export default SmartLink
