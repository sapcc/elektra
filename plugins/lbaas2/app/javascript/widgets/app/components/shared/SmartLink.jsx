import React from "react"
import { Tooltip } from "lib/components/Overlay"
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
    <>
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
        <Tooltip placement="top" content={notAllowedText}>
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
        </Tooltip>
      )}
    </>
  )
}

export default SmartLink
