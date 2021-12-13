import React from "react"
import { Tooltip, OverlayTrigger, Button } from "react-bootstrap"
import uniqueId from "lodash/uniqueId"

const SmartLink = ({
  href,
  style,
  size,
  disabled,
  children,
  onClick,
  isAllowed,
  notAllowedText,
}) => {
  const shouldRenderLink = isAllowed == false ? false : true
  return (
    <React.Fragment>
      {shouldRenderLink ? (
        <Button
          href={href}
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
        <OverlayTrigger
          placement="top"
          overlay={
            <Tooltip id={uniqueId("smart-link-")}>{notAllowedText}</Tooltip>
          }
        >
          <Button
            href={href}
            bsSize={size}
            bsStyle={style}
            disabled={true}
            onClick={(e) => {
              e.preventDefault()
            }}
          >
            {children}
          </Button>
        </OverlayTrigger>
      )}
    </React.Fragment>
  )
}

export default SmartLink
