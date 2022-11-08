import React from "react"
import { Tooltip, OverlayTrigger } from "react-bootstrap"
import uniqueId from "lodash/uniqueId"
import { Link } from "react-router-dom"

const SmartLink = ({
  to,
  className,
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
        <Link
          to={to || ""}
          className={className}
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
        </Link>
      ) : (
        <OverlayTrigger
          placement="top"
          overlay={
            <Tooltip id={uniqueId("smart-link-")}>{notAllowedText}</Tooltip>
          }
        >
          <Link
            to={to || ""}
            className={`${className ? className : ""} smart-link-disabled`}
            disabled={true}
            onClick={(e) => {
              e.preventDefault()
            }}
          >
            {children}
          </Link>
        </OverlayTrigger>
      )}
    </React.Fragment>
  )
}

export default SmartLink
